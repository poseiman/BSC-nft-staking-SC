import 'dotenv/config'

export const privateKey = process.env.PRIVATE_KEY!
export const apiKey = process.env.ETHER_SCAN_API_KEY!

export const USDTData = {
    tokenName: 'Test USD',
    tokenSymbol: 'TUSD',
}

export const NFTData = {
    nftName: 'Test NFT',
    nftSymbol: 'TNFT',
    baseURI: 'ipfs://QmZcH4YvBVVRJtdn4RdbaqgspFU8gH6P9vomDpBVpAL3u4/',
    period: '10',
}