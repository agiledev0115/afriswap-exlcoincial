pancakeFactory = require("../../../deployments/97/PancakeFactory");
weth = require("../../../deployments/97/WETH");

module.exports = [
    pancakeFactory.address,
    weth.address,
]