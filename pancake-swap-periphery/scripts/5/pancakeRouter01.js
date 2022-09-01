pancakeFactory = require("../../../deployments/5/PancakeFactory");
weth = require("../../../deployments/5/WETH");

module.exports = [
    pancakeFactory.address,
    weth.address,
]