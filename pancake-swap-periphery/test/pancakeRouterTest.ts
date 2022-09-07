import { expect, assert } from "chai";
import { mnemonicToEntropy } from "ethers/lib/utils";
import { ethers, network } from "hardhat"
import "@nomiclabs/hardhat-waffle";

describe("The whole test started!", async function () {
  it("deploy", async function () {
    // const [deployer, addr1, addr2] = await ethers.getSigners()
    // console.log(deployer);
    // const survivor = await ethers.getContractFactory("PancakeRouter");

    const chainid = network.config.chainId;
    const PancakeFactoryAddress = require(`../../deployments/${chainid}/PancakeFactory.json`)
    const WETHAddress = require(`../../deployments/${chainid}/WETH.json`)
    const BUSDAddress = require(`../../deployments/${chainid}/BUSD.json`)
    const AFCASHAddress = require(`../../deployments/${chainid}/AFCASH.json`)

    console.log(`BUSD: ${BUSDAddress.address}`)
    console.log(`AFCASH: ${AFCASHAddress.address}`)

    const _PancakeRouter = await ethers.getContractFactory("PancakeRouter");
    const PancakeRouter = await _PancakeRouter.deploy(PancakeFactoryAddress.address, WETHAddress.address);
    await PancakeRouter.deployed();

    console.log("PancakeRouter address:", PancakeRouter.address);
    const deadline = Date.now()

    console.log(`deadline: ${deadline}`)



    await PancakeRouter.addLiquidity(
      BUSDAddress.address,
      AFCASHAddress.address,
      "1000000000000000000",
      "1000000000000000000",
      "200000000000000000",
      "200000000000000000",
      "0x5d4C7743Cdbe1FbcE73d80F970855F3eac9582AC",
      deadline,
    );

    // const survivors = await survivor.deploy();
    // const survivors_deployed = await survivors.deployed();
    // console.log(`Contract deployed to: ${survivors_deployed.address}`);
  });
});
