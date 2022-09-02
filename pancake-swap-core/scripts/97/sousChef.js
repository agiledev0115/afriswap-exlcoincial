require('dotenv').config();

syrupBar = require("../../../deployments/97/SyrupBar");

module.exports = [
  syrupBar.address,
  50,
  0,
  10
]