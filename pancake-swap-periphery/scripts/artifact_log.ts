import { network } from "hardhat"
import fs from 'fs'
import path from 'path'
import util from 'util'
const writeFile = util.promisify(fs.writeFile);

/**
 * @param {*} deployments json
 * @param {*} name
 */
async function writeAddr(addr: string, name: string){
  const chainid = network.config.chainId;
  const saveDir = path.resolve(__dirname, `../../deployments/${chainid}/`);

  if (!fs.existsSync(saveDir)) {
    fs.mkdirSync(saveDir);
  }

  const deploymentPath = saveDir + `/${name}.json`; 

  const deployments = {
    address: addr
  };
  // deployments["address"] = addr;

  await writeFile(deploymentPath, JSON.stringify(deployments, null, 2));
  console.log(`Exported deployments into ${deploymentPath}`);
}

async function writeJson(key: string, value: any, name: string){
  const chainid = network.config.chainId;
  const saveDir = path.resolve(__dirname, `../../deployments/${chainid}/`);

  if (!fs.existsSync(saveDir)) {
    fs.mkdirSync(saveDir);
  }

  const deploymentPath = saveDir + `/${name}.json`; 

  const deployments = {
    [key]: value
  };
  // deployments[key] = value;

  await writeFile(deploymentPath, JSON.stringify(deployments, null, 2));
  console.log(`Exported deployments into ${deploymentPath}`);
}

export {
  writeAddr,
  writeJson
}