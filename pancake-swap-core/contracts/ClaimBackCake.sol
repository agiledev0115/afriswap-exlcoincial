// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/access/AccessControl.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721Holder.sol';

// File: contracts/PancakeProfile.sol

pragma solidity ^0.6.0;

/** @title PancakeProfile.
@dev It is a contract for users to bind their address 
to a customizable profile by depositing a NFT.
*/
contract PancakeProfile is AccessControl, ERC721Holder {
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public cakeToken;

    bytes32 public constant NFT_ROLE = keccak256('NFT_ROLE');
    bytes32 public constant POINT_ROLE = keccak256('POINT_ROLE');
    bytes32 public constant SPECIAL_ROLE = keccak256('SPECIAL_ROLE');

    uint256 public numberActiveProfiles;
    uint256 public numberCakeToReactivate;
    uint256 public numberCakeToRegister;
    uint256 public numberCakeToUpdate;
    uint256 public numberTeams;

    mapping(address => bool) public hasRegistered;

    mapping(uint256 => Team) private teams;
    mapping(address => User) private users;

    // Used for generating the teamId
    Counters.Counter private _countTeams;

    // Used for generating the userId
    Counters.Counter private _countUsers;

    // Event to notify a new team is created
    event TeamAdd(uint256 teamId, string teamName);

    // Event to notify that team points are increased
    event TeamPointIncrease(uint256 indexed teamId, uint256 numberPoints, uint256 indexed campaignId);

    event UserChangeTeam(address indexed userAddress, uint256 oldTeamId, uint256 newTeamId);

    // Event to notify that a user is registered
    event UserNew(address indexed userAddress, uint256 teamId, address nftAddress, uint256 tokenId);

    // Event to notify a user pausing her profile
    event UserPause(address indexed userAddress, uint256 teamId);

    // Event to notify that user points are increased
    event UserPointIncrease(address indexed userAddress, uint256 numberPoints, uint256 indexed campaignId);

    // Event to notify that a list of users have an increase in points
    event UserPointIncreaseMultiple(address[] userAddresses, uint256 numberPoints, uint256 indexed campaignId);

    // Event to notify that a user is reactivating her profile
    event UserReactivate(address indexed userAddress, uint256 teamId, address nftAddress, uint256 tokenId);

    // Event to notify that a user is pausing her profile
    event UserUpdate(address indexed userAddress, address nftAddress, uint256 tokenId);

    // Modifier for admin roles
    modifier onlyOwner() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'Not the main admin');
        _;
    }

    // Modifier for point roles
    modifier onlyPoint() {
        require(hasRole(POINT_ROLE, _msgSender()), 'Not a point admin');
        _;
    }

    // Modifier for special roles
    modifier onlySpecial() {
        require(hasRole(SPECIAL_ROLE, _msgSender()), 'Not a special admin');
        _;
    }

    struct Team {
        string teamName;
        string teamDescription;
        uint256 numberUsers;
        uint256 numberPoints;
        bool isJoinable;
    }

    struct User {
        uint256 userId;
        uint256 numberPoints;
        uint256 teamId;
        address nftAddress;
        uint256 tokenId;
        bool isActive;
    }

    constructor(
        IERC20 _cakeToken,
        uint256 _numberCakeToReactivate,
        uint256 _numberCakeToRegister,
        uint256 _numberCakeToUpdate
    ) public {
        cakeToken = _cakeToken;
        numberCakeToReactivate = _numberCakeToReactivate;
        numberCakeToRegister = _numberCakeToRegister;
        numberCakeToUpdate = _numberCakeToUpdate;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /**
     * @dev To create a user profile. It sends the NFT to the contract
     * and sends CAKE to burn address. Requires 2 token approvals.
     */
    function createProfile(
        uint256 _teamId,
        address _nftAddress,
        uint256 _tokenId
    ) external {
        require(!hasRegistered[_msgSender()], 'Already registered');
        require((_teamId <= numberTeams) && (_teamId > 0), 'Invalid teamId');
        require(teams[_teamId].isJoinable, 'Team not joinable');
        require(hasRole(NFT_ROLE, _nftAddress), 'NFT address invalid');

        // Loads the interface to deposit the NFT contract
        IERC721 nftToken = IERC721(_nftAddress);

        require(_msgSender() == nftToken.ownerOf(_tokenId), 'Only NFT owner can register');

        // Transfer NFT to this contract
        nftToken.safeTransferFrom(_msgSender(), address(this), _tokenId);

        // Transfer CAKE tokens to this contract
        cakeToken.safeTransferFrom(_msgSender(), address(this), numberCakeToRegister);

        // Increment the _countUsers counter and get userId
        _countUsers.increment();
        uint256 newUserId = _countUsers.current();

        // Add data to the struct for newUserId
        users[_msgSender()] = User({
            userId: newUserId,
            numberPoints: 0,
            teamId: _teamId,
            nftAddress: _nftAddress,
            tokenId: _tokenId,
            isActive: true
        });

        // Update registration status
        hasRegistered[_msgSender()] = true;

        // Update number of active profiles
        numberActiveProfiles = numberActiveProfiles.add(1);

        // Increase the number of users for the team
        teams[_teamId].numberUsers = teams[_teamId].numberUsers.add(1);

        // Emit an event
        emit UserNew(_msgSender(), _teamId, _nftAddress, _tokenId);
    }

    /**
     * @dev To pause user profile. It releases the NFT.
     * Callable only by registered users.
     */
    function pauseProfile() external {
        require(hasRegistered[_msgSender()], 'Has not registered');

        // Checks whether user has already paused
        require(users[_msgSender()].isActive, 'User not active');

        // Change status of user to make it inactive
        users[_msgSender()].isActive = false;

        // Retrieve the teamId of the user calling
        uint256 userTeamId = users[_msgSender()].teamId;

        // Reduce number of active users and team users
        teams[userTeamId].numberUsers = teams[userTeamId].numberUsers.sub(1);
        numberActiveProfiles = numberActiveProfiles.sub(1);

        // Interface to deposit the NFT contract
        IERC721 nftToken = IERC721(users[_msgSender()].nftAddress);

        // tokenId of NFT redeemed
        uint256 redeemedTokenId = users[_msgSender()].tokenId;

        // Change internal statuses as extra safety
        users[_msgSender()].nftAddress = address(0x0000000000000000000000000000000000000000);

        users[_msgSender()].tokenId = 0;

        // Transfer the NFT back to the user
        nftToken.safeTransferFrom(address(this), _msgSender(), redeemedTokenId);

        // Emit event
        emit UserPause(_msgSender(), userTeamId);
    }

    /**
     * @dev To update user profile.
     * Callable only by registered users.
     */
    function updateProfile(address _nftAddress, uint256 _tokenId) external {
        require(hasRegistered[_msgSender()], 'Has not registered');
        require(hasRole(NFT_ROLE, _nftAddress), 'NFT address invalid');
        require(users[_msgSender()].isActive, 'User not active');

        address currentAddress = users[_msgSender()].nftAddress;
        uint256 currentTokenId = users[_msgSender()].tokenId;

        // Interface to deposit the NFT contract
        IERC721 nftNewToken = IERC721(_nftAddress);

        require(_msgSender() == nftNewToken.ownerOf(_tokenId), 'Only NFT owner can update');

        // Transfer token to new address
        nftNewToken.safeTransferFrom(_msgSender(), address(this), _tokenId);

        // Transfer CAKE token to this address
        cakeToken.safeTransferFrom(_msgSender(), address(this), numberCakeToUpdate);

        // Interface to deposit the NFT contract
        IERC721 nftCurrentToken = IERC721(currentAddress);

        // Transfer old token back to the owner
        nftCurrentToken.safeTransferFrom(address(this), _msgSender(), currentTokenId);

        // Update mapping in storage
        users[_msgSender()].nftAddress = _nftAddress;
        users[_msgSender()].tokenId = _tokenId;

        emit UserUpdate(_msgSender(), _nftAddress, _tokenId);
    }

    /**
     * @dev To reactivate user profile.
     * Callable only by registered users.
     */
    function reactivateProfile(address _nftAddress, uint256 _tokenId) external {
        require(hasRegistered[_msgSender()], 'Has not registered');
        require(hasRole(NFT_ROLE, _nftAddress), 'NFT address invalid');
        require(!users[_msgSender()].isActive, 'User is active');

        // Interface to deposit the NFT contract
        IERC721 nftToken = IERC721(_nftAddress);
        require(_msgSender() == nftToken.ownerOf(_tokenId), 'Only NFT owner can update');

        // Transfer to this address
        cakeToken.safeTransferFrom(_msgSender(), address(this), numberCakeToReactivate);

        // Transfer NFT to contract
        nftToken.safeTransferFrom(_msgSender(), address(this), _tokenId);

        // Retrieve teamId of the user
        uint256 userTeamId = users[_msgSender()].teamId;

        // Update number of users for the team and number of active profiles
        teams[userTeamId].numberUsers = teams[userTeamId].numberUsers.add(1);
        numberActiveProfiles = numberActiveProfiles.add(1);

        // Update user statuses
        users[_msgSender()].isActive = true;
        users[_msgSender()].nftAddress = _nftAddress;
        users[_msgSender()].tokenId = _tokenId;

        // Emit event
        emit UserReactivate(_msgSender(), userTeamId, _nftAddress, _tokenId);
    }

    /**
     * @dev To increase the number of points for a user.
     * Callable only by point admins
     */
    function increaseUserPoints(
        address _userAddress,
        uint256 _numberPoints,
        uint256 _campaignId
    ) external onlyPoint {
        // Increase the number of points for the user
        users[_userAddress].numberPoints = users[_userAddress].numberPoints.add(_numberPoints);

        emit UserPointIncrease(_userAddress, _numberPoints, _campaignId);
    }

    /**
     * @dev To increase the number of points for a set of users.
     * Callable only by point admins
     */
    function increaseUserPointsMultiple(
        address[] calldata _userAddresses,
        uint256 _numberPoints,
        uint256 _campaignId
    ) external onlyPoint {
        require(_userAddresses.length < 1001, 'Length must be < 1001');
        for (uint256 i = 0; i < _userAddresses.length; i++) {
            users[_userAddresses[i]].numberPoints = users[_userAddresses[i]].numberPoints.add(_numberPoints);
        }
        emit UserPointIncreaseMultiple(_userAddresses, _numberPoints, _campaignId);
    }

    /**
     * @dev To increase the number of points for a team.
     * Callable only by point admins
     */

    function increaseTeamPoints(
        uint256 _teamId,
        uint256 _numberPoints,
        uint256 _campaignId
    ) external onlyPoint {
        // Increase the number of points for the team
        teams[_teamId].numberPoints = teams[_teamId].numberPoints.add(_numberPoints);

        emit TeamPointIncrease(_teamId, _numberPoints, _campaignId);
    }

    /**
     * @dev To remove the number of points for a user.
     * Callable only by point admins
     */
    function removeUserPoints(address _userAddress, uint256 _numberPoints) external onlyPoint {
        // Increase the number of points for the user
        users[_userAddress].numberPoints = users[_userAddress].numberPoints.sub(_numberPoints);
    }

    /**
     * @dev To remove a set number of points for a set of users.
     */
    function removeUserPointsMultiple(address[] calldata _userAddresses, uint256 _numberPoints) external onlyPoint {
        require(_userAddresses.length < 1001, 'Length must be < 1001');
        for (uint256 i = 0; i < _userAddresses.length; i++) {
            users[_userAddresses[i]].numberPoints = users[_userAddresses[i]].numberPoints.sub(_numberPoints);
        }
    }

    /**
     * @dev To remove the number of points for a team.
     * Callable only by point admins
     */

    function removeTeamPoints(uint256 _teamId, uint256 _numberPoints) external onlyPoint {
        // Increase the number of points for the team
        teams[_teamId].numberPoints = teams[_teamId].numberPoints.sub(_numberPoints);
    }

    /**
     * @dev To add a NFT contract address for users to set their profile.
     * Callable only by owner admins.
     */
    function addNftAddress(address _nftAddress) external onlyOwner {
        require(IERC721(_nftAddress).supportsInterface(0x80ac58cd), 'Not ERC721');
        grantRole(NFT_ROLE, _nftAddress);
    }

    /**
     * @dev Add a new teamId
     * Callable only by owner admins.
     */
    function addTeam(string calldata _teamName, string calldata _teamDescription) external onlyOwner {
        // Verify length is between 3 and 16
        bytes memory strBytes = bytes(_teamName);
        require(strBytes.length < 20, 'Must be < 20');
        require(strBytes.length > 3, 'Must be > 3');

        // Increment the _countTeams counter and get teamId
        _countTeams.increment();
        uint256 newTeamId = _countTeams.current();

        // Add new team data to the struct
        teams[newTeamId] = Team({
            teamName: _teamName,
            teamDescription: _teamDescription,
            numberUsers: 0,
            numberPoints: 0,
            isJoinable: true
        });

        numberTeams = newTeamId;
        emit TeamAdd(newTeamId, _teamName);
    }

    /**
     * @dev Function to change team.
     * Callable only by special admins.
     */
    function changeTeam(address _userAddress, uint256 _newTeamId) external onlySpecial {
        require(hasRegistered[_userAddress], "User doesn't exist");
        require((_newTeamId <= numberTeams) && (_newTeamId > 0), "teamId doesn't exist");
        require(teams[_newTeamId].isJoinable, 'Team not joinable');
        require(users[_userAddress].teamId != _newTeamId, 'Already in the team');

        // Get old teamId
        uint256 oldTeamId = users[_userAddress].teamId;

        // Change number of users in old team
        teams[oldTeamId].numberUsers = teams[oldTeamId].numberUsers.sub(1);

        // Change teamId in user mapping
        users[_userAddress].teamId = _newTeamId;

        // Change number of users in new team
        teams[_newTeamId].numberUsers = teams[_newTeamId].numberUsers.add(1);

        emit UserChangeTeam(_userAddress, oldTeamId, _newTeamId);
    }

    /**
     * @dev Claim CAKE to burn later.
     * Callable only by owner admins.
     */
    function claimFee(uint256 _amount) external onlyOwner {
        cakeToken.safeTransfer(_msgSender(), _amount);
    }

    /**
     * @dev Make a team joinable again.
     * Callable only by owner admins.
     */
    function makeTeamJoinable(uint256 _teamId) external onlyOwner {
        require((_teamId <= numberTeams) && (_teamId > 0), 'teamId invalid');
        teams[_teamId].isJoinable = true;
    }

    /**
     * @dev Make a team not joinable.
     * Callable only by owner admins.
     */
    function makeTeamNotJoinable(uint256 _teamId) external onlyOwner {
        require((_teamId <= numberTeams) && (_teamId > 0), 'teamId invalid');
        teams[_teamId].isJoinable = false;
    }

    /**
     * @dev Rename a team
     * Callable only by owner admins.
     */
    function renameTeam(
        uint256 _teamId,
        string calldata _teamName,
        string calldata _teamDescription
    ) external onlyOwner {
        require((_teamId <= numberTeams) && (_teamId > 0), 'teamId invalid');

        // Verify length is between 3 and 16
        bytes memory strBytes = bytes(_teamName);
        require(strBytes.length < 20, 'Must be < 20');
        require(strBytes.length > 3, 'Must be > 3');

        teams[_teamId].teamName = _teamName;
        teams[_teamId].teamDescription = _teamDescription;
    }

    /**
     * @dev Update the number of CAKE to register
     * Callable only by owner admins.
     */
    function updateNumberCake(
        uint256 _newNumberCakeToReactivate,
        uint256 _newNumberCakeToRegister,
        uint256 _newNumberCakeToUpdate
    ) external onlyOwner {
        numberCakeToReactivate = _newNumberCakeToReactivate;
        numberCakeToRegister = _newNumberCakeToRegister;
        numberCakeToUpdate = _newNumberCakeToUpdate;
    }

    /**
     * @dev Check the user's profile for a given address
     */
    function getUserProfile(address _userAddress)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            address,
            uint256,
            bool
        )
    {
        require(hasRegistered[_userAddress], 'Not registered');
        return (
            users[_userAddress].userId,
            users[_userAddress].numberPoints,
            users[_userAddress].teamId,
            users[_userAddress].nftAddress,
            users[_userAddress].tokenId,
            users[_userAddress].isActive
        );
    }

    /**
     * @dev Check the user's status for a given address
     */
    function getUserStatus(address _userAddress) external view returns (bool) {
        return (users[_userAddress].isActive);
    }

    /**
     * @dev Check a team's profile
     */
    function getTeamProfile(uint256 _teamId)
        external
        view
        returns (
            string memory,
            string memory,
            uint256,
            uint256,
            bool
        )
    {
        require((_teamId <= numberTeams) && (_teamId > 0), 'teamId invalid');
        return (
            teams[_teamId].teamName,
            teams[_teamId].teamDescription,
            teams[_teamId].numberUsers,
            teams[_teamId].numberPoints,
            teams[_teamId].isJoinable
        );
    }
}

// File: contracts/ClaimBackCake.sol

pragma solidity ^0.6.12;

contract ClaimBackCake is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public cakeToken;
    PancakeProfile pancakeProfile;

    uint256 public numberCake;
    uint256 public thresholdUser;

    mapping(address => bool) public hasClaimed;

    constructor(
        IERC20 _cakeToken,
        address _pancakeProfileAddress,
        uint256 _numberCake,
        uint256 _thresholdUser
    ) public {
        cakeToken = _cakeToken;
        pancakeProfile = PancakeProfile(_pancakeProfileAddress);
        numberCake = _numberCake;
        thresholdUser = _thresholdUser;
    }

    function getCakeBack() external {
        // 1. Check if she has registered
        require(pancakeProfile.hasRegistered(_msgSender()), 'not active');

        // 2. Check if she has claimed
        require(!hasClaimed[_msgSender()], 'has claimed CAKE');

        // 3. Check if she is active
        uint256 userId;
        (userId, , , , , ) = pancakeProfile.getUserProfile(_msgSender());

        require(userId < thresholdUser, 'not impacted');

        // Update status
        hasClaimed[_msgSender()] = true;

        // Transfer CAKE tokens from this contract
        cakeToken.safeTransfer(_msgSender(), numberCake);
    }

    /**
     * @dev Claim CAKE back.
     * Callable only by owner admins.
     */
    function claimFee(uint256 _amount) external onlyOwner {
        cakeToken.safeTransfer(_msgSender(), _amount);
    }

    function canClaim(address _userAddress) external view returns (bool) {
        if (!pancakeProfile.hasRegistered(_userAddress)) {
            return false;
        } else if (hasClaimed[_userAddress]) {
            return false;
        } else {
            uint256 userId;
            (userId, , , , , ) = pancakeProfile.getUserProfile(_userAddress);
            if (userId < thresholdUser) {
                return true;
            } else {
                return false;
            }
        }
    }
}

// File: contracts/AnniversaryAchievement.sol

pragma solidity ^0.6.12;

/**
 * @title AnniversaryAchievement.
 * @notice It is a contract to distribute points for 1st anniversary.
 */
contract AnniversaryAchievement is Ownable {
    PancakeProfile public pancakeProfile;

    uint256 public campaignId;
    uint256 public numberPoints;
    uint256 public thresholdPoints;
    uint256 public endBlock;

    // Map if address has already claimed points
    mapping(address => bool) public hasClaimed;

    event NewCampaignId(uint256 campaignId);
    event NewEndBlock(uint256 endBlock);
    event NewNumberPointsAndThreshold(uint256 numberPoints, uint256 thresholdPoints);

    /**
     * @notice Constructor
     * @param _pancakeProfile: Pancake Profile
     * @param _numberPoints: number of points to give
     * @param _thresholdPoints: number of points required to claim
     * @param _campaignId: campaign id
     * @param _endBlock: end block for claiming
     */
    constructor(
        address _pancakeProfile,
        uint256 _numberPoints,
        uint256 _thresholdPoints,
        uint256 _campaignId,
        uint256 _endBlock
    ) public {
        pancakeProfile = PancakeProfile(_pancakeProfile);
        numberPoints = _numberPoints;
        thresholdPoints = _thresholdPoints;
        campaignId = _campaignId;
        endBlock = _endBlock;
    }

    /**
     * @notice Get anniversary points
     * @dev Users can claim these once.
     */
    function claimAnniversaryPoints() external {
        require(canClaim(msg.sender), 'Claim: Cannot claim');

        hasClaimed[msg.sender] = true;

        pancakeProfile.increaseUserPoints(msg.sender, numberPoints, campaignId);
    }

    /**
     * @notice Change campaignId
     * @dev Only callable by owner.
     * @param _campaignId: campaign id
     */
    function changeCampaignId(uint256 _campaignId) external onlyOwner {
        campaignId = _campaignId;

        emit NewCampaignId(_campaignId);
    }

    /**
     * @notice Change end block for distribution
     * @dev Only callable by owner.
     * @param _endBlock: end block for claiming
     */
    function changeEndBlock(uint256 _endBlock) external onlyOwner {
        endBlock = _endBlock;

        emit NewEndBlock(_endBlock);
    }

    /**
     * @notice Change points and threshold
     * @dev Only callable by owner.
     * @param _numberPoints: number of points to give
     * @param _thresholdPoints: number of points required to claim
     */
    function changeNumberPointsAndThreshold(uint256 _numberPoints, uint256 _thresholdPoints) external onlyOwner {
        numberPoints = _numberPoints;
        thresholdPoints = _thresholdPoints;

        emit NewNumberPointsAndThreshold(_numberPoints, _thresholdPoints);
    }

    /**
     * @notice Checks the claim status by user
     * @dev Only callable by owner.
     * @param _user: user address
     */
    function canClaim(address _user) public view returns (bool) {
        if (!pancakeProfile.getUserStatus(_user)) {
            return false;
        }

        (, uint256 numberUserPoints, , , , ) = pancakeProfile.getUserProfile(_user);

        return (!hasClaimed[_user]) && (block.number < endBlock) && (numberUserPoints >= thresholdPoints);
    }
}
