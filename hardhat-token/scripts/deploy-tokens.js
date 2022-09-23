const { writeAddr, writeJson } = require("./artifact_log")

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

    // // AFCASH
    // const _AFCASH = await ethers.getContractFactory("AFCASH");
    // const AFCASH = await _AFCASH.deploy();
    // await AFCASH.deployed();
    // console.log("AFCASH address:", AFCASH.address);
    // // save token address
    // await writeAddr(AFCASH.address, "AFCASH");

    // // BUSD
    // const _BUSD = await ethers.getContractFactory("BUSD");
    // const BUSD = await _BUSD.deploy();
    // await BUSD.deployed();
    // console.log("BUSD address:", BUSD.address);
    // // save token address
    // await writeAddr(BUSD.address, "BUSD");

    // BAKE
    const _BAKE = await ethers.getContractFactory("BAKE");
    const BAKE = await _BAKE.deploy();
    await BAKE.deployed();
    console.log("BAKE address:", BAKE.address);
    // save token address
    await writeAddr(BAKE.address, "BAKE");

    // CAKE
    const _CAKE = await ethers.getContractFactory("AFCASH");
    const CAKE = await _CAKE.deploy();
    await CAKE.deployed();
    console.log("CAKE address:", CAKE.address);
    // save token address
    await writeAddr(CAKE.address, "CAKE");

    // DAI
    const _DAI = await ethers.getContractFactory("DAI");
    const DAI = await _DAI.deploy();
    await DAI.deployed();
    console.log("DAI address:", DAI.address);
    // save token address
    await writeAddr(DAI.address, "DAI");

    // ETH
    const _ETH = await ethers.getContractFactory("Ethereum");
    const ETH = await _ETH.deploy();
    await ETH.deployed();
    console.log("ETH address:", ETH.address);
    // save token address
    await writeAddr(ETH.address, "ETH");

    // USDT
    const _USDT = await ethers.getContractFactory("USDT");
    const USDT = await _USDT.deploy();
    await USDT.deployed();
    console.log("USDT address:", USDT.address);
    // save token address
    await writeAddr(USDT.address, "USDT");

    // XRP
    const _XRP = await ethers.getContractFactory("XRP");
    const XRP = await _XRP.deploy();
    await XRP.deployed();
    console.log("XRP address:", XRP.address);
    // save token address
    await writeAddr(XRP.address, "XRP");

    // We also save the contract's artifacts and address in the frontend directory
    // saveFrontendFiles(token);
  }

  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  