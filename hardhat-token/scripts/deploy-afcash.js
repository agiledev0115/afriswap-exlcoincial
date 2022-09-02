const { writeAddr,writeJson } = require("./artifact_log")
// This is a script for deploying your contracts. You can adapt it to deploy
// yours, or create new ones.
async function main() {
    // This is just a convenience check
    if (network.name === "hardhat") {
      console.warn(
        "You are trying to deploy a contract to the Hardhat Network, which" +
          "gets automatically created and destroyed every time. Use the Hardhat" +
          " option '--network localhost'"
      );
    }
  
    // ethers is avaialble in the global scope
    const [deployer] = await ethers.getSigners();
    console.log(
      "Deploying the contracts with the account:",
      await deployer.getAddress()
    );
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
      
    // AFCASH
    const _AFCASH = await ethers.getContractFactory("AFCASH");
    const AFCASH = await _AFCASH.deploy();
    await AFCASH.deployed();
    console.log("AFCASH address:", AFCASH.address);
    // save token address
    await writeAddr(AFCASH.address, "AFCASH");

    // BUSD
    const _BUSD = await ethers.getContractFactory("BUSD");
    const BUSD = await _BUSD.deploy();
    await BUSD.deployed();
    console.log("BUSD address:", BUSD.address);
    // save token address
    await writeAddr(BUSD.address, "BUSD");

    // We also save the contract's artifacts and address in the frontend directory
    // saveFrontendFiles(token);
  }

  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  