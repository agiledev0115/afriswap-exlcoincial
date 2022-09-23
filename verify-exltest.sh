if ! command -v jq &> /dev/null; then
  if [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    # Do something under 32 bits Windows NT platform
    curl -L -o /usr/bin/jq.exe https://github.com/stedolan/jq/releases/latest/download/jq-win32.exe
    alias jq=/usr/bin/jq.exe
  elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    # Do something under 64 bits Windows NT platform
    curl -L -o /usr/bin/jq.exe https://github.com/stedolan/jq/releases/latest/download/jq-win64.exe
  fi

  # echo "JQ is not installed"
  # exit
fi


shopt -s expand_aliases
alias jq=/usr/bin/jq.exe


# echo "verify smart contracts on goerli"
# for i in `find ../deployments/27082017 -name '*.json'`; do
# echo $i
# address=$(jq -r .address $i)
# echo $address
# verify="npx hardhat verify --network goerli $address 100000"
# echo $verify
# $verify
# # npx hardhat verify --network goerli $address 100000
# done

verify() {
  json="../deployments/27082017/$1"
  echo $json
  echo $2
  address=$(jq -r .address $json)
  echo $address
  verify="npx hardhat verify --network exltest $address --contract '$2' --constructor-args $3"
  # verify="npx hardhat verify --network goerli $address --contract '$2' --show-stack-traces"
  echo $verify
  npx hardhat verify --network exltest $address --contract "$2" --constructor-args $3
  # $verify
}

# verify hardhat-tokens contracts
cd hardhat-token
verify "AFCASH.json" "contracts/ERC20Tokens/AFCASH.sol:AFCASH" "scripts/27082017/none.js"
verify "BAKE.json" "contracts/ERC20Tokens/BAKE.sol:BAKE" "scripts/27082017/none.js"
verify "BUSD.json" "contracts/ERC20Tokens/BUSD.sol:BUSD" "scripts/27082017/none.js"
verify "DAI.json" "contracts/ERC20Tokens/DAI.sol:DAI" "scripts/27082017/none.js"
verify "ETH.json" "contracts/ERC20Tokens/ETH.sol:Ethereum" "scripts/27082017/none.js"
verify "Multicall.json" "contracts/MULTICALL.sol:Multicall2" "scripts/27082017/none.js"
verify "USDT.json" "contracts/ERC20Tokens/USDT.sol:USDT" "scripts/27082017/none.js"
verify "WBNB.json" "contracts/ERC20Tokens/WBNB.sol:WBNB" "scripts/27082017/none.js"
verify "WETH.json" "contracts/ERC20Tokens/WETH.sol:WETH" "scripts/27082017/none.js"
verify "XRP.json" "contracts/ERC20Tokens/XRP.sol:XRP" "scripts/27082017/none.js"

# verify pancake-swap-core contracts
cd ..
cd pancake-swap-core
verify "PancakeFactory.json" "contracts/PancakeFactory.sol:PancakeFactory" "scripts/27082017/pancakeFactory.ts"
verify "PancakePair.json" "contracts/PancakePair.sol:PancakePair" "scripts/27082017/none.js"
verify "CAKE.json" "contracts/MasterChef.sol:CakeToken" "scripts/27082017/none.js"
verify "SyrupBar.json" "contracts/MasterChef.sol:SyrupBar" "scripts/27082017/syrupBar.js"
verify "MasterChef.json" "contracts/MasterChef.sol:MasterChef" "scripts/27082017/masterChef.js"
verify "SousChef.json" "contracts/SousChef.sol:SousChef" "scripts/27082017/sousChef.js"
verify "PancakeProfile.json" "contracts/ClaimBackCake.sol:PancakeProfile" "scripts/27082017/pancakeProfile.js"
verify "AnniversaryAchievement.json" "contracts/ClaimBackCake.sol:AnniversaryAchievement" "scripts/27082017/anniversaryAchievement.js"
verify "ClaimBackCake.json" "contracts/ClaimBackCake.sol:ClaimBackCake" "scripts/27082017/claimBackCake.js"

# # verify pancake-swap-periphery contracts
cd ..
cd pancake-swap-periphery
verify "PancakeRouter.json" "contracts/PancakeRouter.sol:PancakeRouter" "scripts/27082017/pancakeRouter.js"
verify "PancakeRouter01.json" "contracts/PancakeRouter01.sol:PancakeRouter01" "scripts/27082017/pancakeRouter01.js"
