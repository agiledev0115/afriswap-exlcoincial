require('dotenv').config();

cakeToken = require("../../../deployments/27082017/CAKE");
syrupBar = require("../../../deployments/27082017/SyrupBar");

module.exports = [
  cakeToken.address,
  syrupBar.address,
  process.env.ACCOUNT,
  100,
  0
]