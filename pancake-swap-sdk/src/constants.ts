import JSBI from 'jsbi';
// const FACTORY_ADDRESS_JSON = require('../../../../../deployments/5/PancakeFactory.json')
// const INIT_CODE_HASH_JSON = require('../../../../../deployments/5/INIT_CODE_PAIR_HASH.json')

// exports for external consumption
export type BigintIsh = JSBI | bigint | string

export enum ChainId {
  MAINNET = 27082022,
  TESTNET = 5
}

export enum TradeType {
  EXACT_INPUT,
  EXACT_OUTPUT
}

export enum Rounding {
  ROUND_DOWN,
  ROUND_HALF_UP,
  ROUND_UP
}


export  const FACTORY_ADDRESS = "0x34F3e6A6695E98B370b58984FbdCA14222117403";
export  const INIT_CODE_HASH = "0xb7098b3d882ce29e7f9104fcfb5853e10b7997c1a70018c521997d41a3feb4f9";



export const MINIMUM_LIQUIDITY = JSBI.BigInt(1000)

// exports for internal consumption
export const ZERO = JSBI.BigInt(0)
export const ONE = JSBI.BigInt(1)
export const TWO = JSBI.BigInt(2)
export const THREE = JSBI.BigInt(3)
export const FIVE = JSBI.BigInt(5)
export const TEN = JSBI.BigInt(10)
export const _100 = JSBI.BigInt(100)
export const FEES_NUMERATOR = JSBI.BigInt(9975)
export const FEES_DENOMINATOR = JSBI.BigInt(10000)

export enum SolidityType {
  uint8 = 'uint8',
  uint256 = 'uint256'
}

export const SOLIDITY_TYPE_MAXIMA = {
  [SolidityType.uint8]: JSBI.BigInt('0xff'),
  [SolidityType.uint256]: JSBI.BigInt('0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff')
}
