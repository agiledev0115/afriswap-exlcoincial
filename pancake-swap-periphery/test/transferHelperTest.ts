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

    const _TransferHelper = await ethers.getContractFactory("TransferHelperTest");
    const TransferHelper = await _TransferHelper.deploy();
    await TransferHelper.deployed();

    console.log("TransferHelper address:", TransferHelper.address);

    await TransferHelper.safeTransferFromEx(
      BUSDAddress.address,
      "0x5d4C7743Cdbe1FbcE73d80F970855F3eac9582AC",
      "0x19c03964f154e70B59A05748f28CBcb3ccF6C4D4",
      "1000000000000000000"
    )

    // const survivors = await survivor.deploy();
    // const survivors_deployed = await survivors.deployed();
    // console.log(`Contract deployed to: ${survivors_deployed.address}`);
  });
});
