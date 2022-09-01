require('dotenv').config();

cakeToken = require("../../../deployments/5/CAKE");
syrupBar = require("../../../deployments/5/SyrupBar");

module.exports = [
  cakeToken.address,
  syrupBar.address,
  process.env.ACCOUNT,
  100,
  0
]