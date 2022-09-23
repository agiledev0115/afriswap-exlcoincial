import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-etherscan";
import dotenv from "dotenv";
import { HardhatUserConfig } from "hardhat/config";
dotenv.config();

// The next line is part of the sample project, you don't need it in your
// project. It imports a Hardhat task definition, that can be used for
// testing the frontend.

const config = {
  solidity: {
    compilers: [
          {version: "0.4.18"},
          {version: "0.5.16"},
          {version: "0.6.12"},
          {version: "0.6.6"},
          {version: "0.8.4"}
      ]
  },
  networks: {
    dev: {
      url: "http://127.0.0.1:8545",
      chainId: 31337
    },
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY || ''}`,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      chainId: 5,
    },
    bsctest: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
    exltest: {
      url: "https://testnet-rpc.exlscan.com/",
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      chainId: 27082017,
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  },
  mocha: {
    timeout: 10000000000
  }
};

export default config;