require('dotenv').config();

syrupBar = require("../../../deployments/5/SyrupBar");

module.exports = [
  syrupBar.address,
  50,
  0,
  10
]