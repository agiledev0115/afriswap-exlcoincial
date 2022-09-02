const { writeAddr,writeJson } = require("./artifact_log")

// This is a script for deploying your contracts. You can adapt it to deploy
// yours, or create new ones.
async function main() {
    let BUSDJSON = ""
    let WBNBJSON = ""
    // This is just a convenience check
    if (network.name === "hardhat") {
      console.warn(
        "You are trying to deploy a contract to the Hardhat Network, which" +
          "gets automatically created and destroyed every time. Use the Hardhat" +
          " option '--network localhost'"
      );
    }
    
    if (network.name === "dev") {
      BUSDJSON = require("../../deployments/31337/BUSD");
      WBNBJSON = require("../../deployments/31337/WBNB");
    }
    
    if (network.name === "goerli") {
      BUSDJSON = require("../../deployments/5/BUSD");
      WBNBJSON = require("../../deployments/5/WBNB");
    }
  
    if (network.name === "bsctest") {
      BUSDJSON = require("../../deployments/97/BUSD");
      WBNBJSON = require("../../deployments/97/WBNB");
    }
  
  
    // ethers is avaialble in the global scope
    const [deployer] = await ethers.getSigners();
    console.log(
      "Deploying the contracts with the account:",
      await deployer.getAddress()
    );
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
     
    // deployer address as feeToSetter
    feeToSetter = await deployer.getAddress()
    // Fill your address as feeToSetter in constructor -> Deploy
    const PancakeFactory = await ethers.getContractFactory("UniswapV2Factory");
    const Factory = await PancakeFactory.deploy(feeToSetter);
    await Factory.deployed();
  
    console.log("UniswapV2Factory address:", Factory.address);
    
    // save contract address
    await writeAddr(Factory.address, "UniswapV2Factory");

    // Pancakepair
    const _PancakePair = await ethers.getContractFactory("UniswapV2Pair");
    const PancakePair = await _PancakePair.deploy();
    await PancakePair.deployed();
    console.log("UniswapV2Pair address:", PancakePair.address);
    // save contract address
    await writeAddr(PancakePair.address, "UniswapV2Pair");
  }
  
//   function saveFrontendFiles(token) {
//     const fs = require("fs");
//     const contractsDir = __dirname + "/../frontend/src/contracts";
  
//     if (!fs.existsSync(contractsDir)) {
//       fs.mkdirSync(contractsDir);
//     }
  
//     fs.writeFileSync(
//       contractsDir + "/contract-address.json",
//       JSON.stringify({ Token: token.address }, undefined, 2)
//     );
  
//     const TokenArtifact = artifacts.readArtifactSync("Token");
  
//     fs.writeFileSync(
//       contractsDir + "/Token.json",
//       JSON.stringify(TokenArtifact, null, 2)
//     );
//   }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  