require('dotenv').config();

cakeToken = require("../../../deployments/97/CAKE");
syrupBar = require("../../../deployments/97/SyrupBar");

module.exports = [
  cakeToken.address,
  syrupBar.address,
  process.env.ACCOUNT,
  100,
  0
]