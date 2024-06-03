import hre from "hardhat";

import { USDTData, NFTData } from "../config";

async function main() {
  const { tokenName, tokenSymbol } = USDTData
  const USDT = await hre.ethers.getContractFactory("USDT");
  const usdt = await USDT.deploy(tokenName, tokenSymbol);
  await usdt.waitForDeployment()
  const usdtAddress = await usdt.getAddress()

  console.table(`USDT: ${usdtAddress}`)

  const { nftName, nftSymbol, baseURI, period } = NFTData
  const NFT = await hre.ethers.getContractFactory("NFT_Staking");
  const nft = await NFT.deploy(nftName, nftSymbol, usdtAddress, baseURI, period);
  await nft.waitForDeployment()
  const nftAddress = await nft.getAddress()

  console.table(`NFT: ${nftAddress}`)

  // default settings
  await usdt.transferOwnership(await nft.getAddress())

}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });