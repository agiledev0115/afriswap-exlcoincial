import { network } from "hardhat"
import fs from 'fs'
import path from 'path'
import util from 'util'
const writeFile = util.promisify(fs.writeFile);

async function addTokens(name: string, symbol: string, address: any, chainId: number | undefined, decimals: number, logoURI: string){
    
    const tokensDir = path.resolve(__dirname, `../../pancake-frontend/src/config/constants/tokenLists/pancake-default.tokenlist.json`);

    if (!fs.existsSync(tokensDir)) {
        console.error()
    }
    
    const tokenlists = require('../../pancake-frontend/src/config/constants/tokenLists/pancake-default.tokenlist.json')
    const token =  {
        "name": name,
        "symbol": symbol,
        "address": address,
        "chainId": chainId,
        "decimals": decimals,
        "logoURI": logoURI
    }
    tokenlists.tokens = []
    tokenlists.tokens.push(token)
    await writeFile(tokensDir, JSON.stringify(tokenlists)).catch((err: any) => {
        console.log(err)
        console.log('successfully writing:', name)
    })
}

export {
    addTokens
}
