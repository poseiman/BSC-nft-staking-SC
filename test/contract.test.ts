import {
  time,
  loadFixture,
  setBalance,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai";
import hre from "hardhat";
import { USDT, NFT_Staking } from "../typechain-types";
import { USDTData, NFTData } from "../config";
import { MaxUint256, ZeroAddress } from "ethers";

let signers: HardhatEthersSigner[]
let nft: NFT_Staking
let usdt: USDT
const day = 86400

describe("USDT contract", function () {
  const { tokenName, tokenSymbol } = USDTData

  async function deployUsdt() {
    signers = await hre.ethers.getSigners();

    const Usdt = await hre.ethers.getContractFactory("USDT");
    usdt = await Usdt.deploy(tokenName, tokenSymbol);
  }

  describe("Deployment", async function () {
    it("Should set the right params", async function () {
      await deployUsdt();
      expect(await usdt.owner()).to.equal(signers[0].address);
    });
  });

});

describe("NFT Contract", function () {
  const { nftName, nftSymbol, baseURI, period } = NFTData
  async function deployNft() {
    const Nft = await hre.ethers.getContractFactory("NFT_Staking");
    nft = await Nft.deploy(nftName, nftSymbol, await usdt.getAddress(), baseURI, period);

    await usdt.transferOwnership(await nft.getAddress())
  }

  describe("Deployment", async function () {
    it("Should set the right params", async function () {
      await deployNft()
      expect(await nft.owner()).to.equal(signers[0].address);
    });

    it("Should provide nft", async function () {
      await nft.provideNFT(signers[1].address)
      await nft.provideNFT(signers[2].address)
      await nft.provideNFT(signers[1].address)
      await nft.provideNFT(signers[2].address)
      await nft.provideNFT(signers[1].address)
      await nft.provideNFT(signers[1].address)
      await nft.provideNFT(signers[2].address)
      await nft.provideNFT(signers[1].address)
      await nft.provideNFT(signers[2].address)
      await nft.provideNFT(signers[2].address)
      await nft.provideNFT(signers[1].address)
      console.log(await nft.balanceOf(signers[1].address))
      console.log(await nft.tokenOfOwnerByIndex(signers[1].address, 3))
    });

    it("Should get owned nft list", async function () {
      console.log(await nft.connect(signers[1]).userOwnedTokens(signers[1].address))
    });

    it("Should stake nft", async function () {
      await nft.connect(signers[1]).setApprovalForAll(await nft.getAddress(), true)
      await nft.connect(signers[1]).stakeNFT([0, 2])
    });

    it("Should get staked nft list", async function () {
      console.log(await nft.getStakedNFTList(signers[1].address))
      console.log(await nft.getStakedTokenIds(signers[1].address))
    });

    it("Should calc claimable amount", async function () {
      await time.increase(600)
      console.log(await nft.claimableAmount(signers[1].address, 2))
    });

    it("Should claim exact amount", async function () {
      expect(await nft.connect(signers[1]).claim(2)).to.changeTokenBalance(usdt, signers[1].address, 60)

      // console.log(await nft.getStakedNFTList(signers[1].address))
    });

    it("Should unstake and get exact reward", async function () {
      expect(await nft.connect(signers[1]).unStakeNFT(2)).to.changeTokenBalance(usdt, signers[1].address, 60)
    });
  })

});
