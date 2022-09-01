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
# for i in `find ../deployments/5 -name '*.json'`; do
# echo $i
# address=$(jq -r .address $i)
# echo $address
# verify="npx hardhat verify --network goerli $address 100000"
# echo $verify
# $verify
# # npx hardhat verify --network goerli $address 100000
# done

verify() {
  json="../deployments/5/$1"
  echo $json
  echo $2
  address=$(jq -r .address $json)
  echo $address
  verify="npx hardhat verify --network goerli $address --contract '$2' --constructor-args $3"
  # verify="npx hardhat verify --network goerli $address --contract '$2' --show-stack-traces"
  echo $verify
  npx hardhat verify --network goerli $address --contract "$2" --constructor-args $3
  # $verify
}

# verify hardhat-tokens contracts
cd hardhat-token
verify "BAKE.json" "contracts/BAKEToken.sol:BakeryToken" "scripts/5/none.js"
verify "BUSD.json" "contracts/BUSDToken.sol:BEP20Token" "scripts/5/none.js"
verify "DAI.json" "contracts/DAIToken.sol:BEP20DAI" "scripts/5/none.js"
verify "ETH.json" "contracts/ETHToken.sol:BEP20Ethereum" "scripts/5/none.js"
verify "Multicall.json" "contracts/MULTICALL.sol:Multicall2" "scripts/5/none.js"
verify "USDT.json" "contracts/USDTToken.sol:BEP20USDT" "scripts/5/none.js"
verify "WBNB.json" "contracts/WBNB.sol:WBNB" "scripts/5/none.js"
verify "WETH.json" "contracts/WETH.sol:WETH" "scripts/5/none.js"
verify "XRP.json" "contracts/XRPToken.sol:BEP20XRP" "scripts/5/none.js"

# verify pancake-swap-core contracts
cd ..
cd pancake-swap-core
verify "PancakeFactory.json" "contracts/PancakeFactory.sol:PancakeFactory" "scripts/5/pancakeFactory.js"
verify "PancakePair.json" "contracts/PancakePair.sol:PancakePair" "scripts/5/none.js"
verify "CAKE.json" "contracts/MasterChef.sol:CakeToken" "scripts/5/none.js"
verify "SyrupBar.json" "contracts/MasterChef.sol:SyrupBar" "scripts/5/syrupBar.js"
verify "MasterChef.json" "contracts/MasterChef.sol:MasterChef" "scripts/5/masterChef.js"
verify "SousChef.json" "contracts/SousChef.sol:SousChef" "scripts/5/sousChef.js"
verify "PancakeProfile.json" "contracts/ClaimBackCake.sol:PancakeProfile" "scripts/5/pancakeProfile.js"
verify "AnniversaryAchievement.json" "contracts/ClaimBackCake.sol:AnniversaryAchievement" "scripts/5/anniversaryAchievement.js"
verify "ClaimBackCake.json" "contracts/ClaimBackCake.sol:ClaimBackCake" "scripts/5/claimBackCake.js"

# verify pancake-swap-periphery contracts
cd ..
cd pancake-swap-periphery
verify "PancakeRouter.json" "contracts/PancakeRouter.sol:PancakeRouter" "scripts/5/pancakeRouter.js"
verify "PancakeRouter01.json" "contracts/PancakeRouter01.sol:PancakeRouter01" "scripts/5/pancakeRouter01.js"
