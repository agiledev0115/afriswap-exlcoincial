require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require('dotenv').config();

// The next line is part of the sample project, you don't need it in your
// project. It imports a Hardhat task definition, that can be used for
// testing the frontend.

module.exports = {
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
      chainId: 5
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  },
  mocha: {
    timeout: 10000000
  }
};
