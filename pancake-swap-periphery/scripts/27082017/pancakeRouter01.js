pancakeFactory = require("../../../deployments/27082017/PancakeFactory");
weth = require("../../../deployments/27082017/WETH");

module.exports = [
    pancakeFactory.address,
    weth.address,
]