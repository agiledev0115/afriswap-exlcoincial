require('dotenv').config();

syrupBar = require("../../../deployments/27082017/SyrupBar");

module.exports = [
  syrupBar.address,
  50,
  0,
  10
]