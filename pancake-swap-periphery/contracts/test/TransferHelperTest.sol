// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

import '@nomiclabs/buidler/console.sol';

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
contract TransferHelperTest {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        // console.log('TransferHelper testing');
        // console.log('TransferHelper::success: %s', success);
        // console.log('TransferHelper::data.length: %s', data.length);
        // console.log('TransferHelper::abi.decode(data, (bool)): %s', abi.decode(data, (bool)));
        require(success, 'TransferHelper::transferFrom: call success is false');
        if (data.length != 0) {
            require(abi.decode(data, (bool)), 'TransferHelper::transferFrom: abi.decode(data, (bool) error');
        }
        // require(
        //     success && (data.length == 0 || abi.decode(data, (bool))),
        //     'TransferHelper::transferFrom: transferFrom failed'
        // );
    }

    function safeTransferFromEx(
        address token,
        address from,
        address to,
        uint256 value
    ) external {
        return safeTransferFrom(token, from, to, value);
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}
