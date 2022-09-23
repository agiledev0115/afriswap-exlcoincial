import { ethers, network } from "hardhat"
import "@nomiclabs/hardhat-waffle";
import fs from 'fs'
import path from 'path'
import util from 'util'
const writeFile = util.promisify(fs.writeFile);
const INIT_CODE_PAIR_HASH_JSON = require(`../../../deployments/${network.config.chainId}/INIT_CODE_PAIR_HASH`)

async function writeHex(){
    const hexDir = path.join(__dirname, `../../contracts/libraries/PancakeLibrary.sol`);
    const txtStartDir = path.join(__dirname, `/txt/PancakeLibraryTxTStart.txt`);
    const txtEndDir = path.join(__dirname, `/txt/PancakeLibraryTxTEnd.txt`);

    if (!fs.existsSync(hexDir)) {
        console.error()
    }

    let txtStart = ''
    let txtEnd = ''
    let txtHex = ''

    txtHex = INIT_CODE_PAIR_HASH_JSON.INIT_CODE_PAIR_HASH.toString()
    txtHex = txtHex.substring(2)

    txtStart = fs.readFileSync(txtStartDir, 'utf-8');

    txtEnd = fs.readFileSync(txtEndDir, 'utf-8')

    const codeString = txtStart.concat(txtHex ,txtEnd)

    await writeFile(hexDir, codeString).catch((err: any) => {
        console.log(err)
        console.log('successfully writing:')
    })
}

export  {
    writeHex
}