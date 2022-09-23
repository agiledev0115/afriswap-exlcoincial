import { ChainId } from 'local-pancakeswap-libs/sdk'

const NETWORK_URLS: { [chainId in ChainId]: string } = {
  [ChainId.MAINNET]: 'https://bsc-dataseed1.defibit.io',
  [ChainId.TESTNET]: 'https://eth-goerli.g.alchemy.com/v2/JdKOdAStLeMRpbWl8zUC9lAih9H4fM7e',
}

export default NETWORK_URLS
