
const fs = require('fs');
const { ethers, upgrades } = require("hardhat");

async function main() {
	// const NFT = await ethers.getContractFactory("NFT");
	// const nft= await NFT.deploy("nft", "nfttest")
	
    // await nft.deployed();

	// var tokens = ["0x9c2582bf7648dc75825a26758206b6610d7c989c6ac940285503d77e5ad27bdc"];
	// var tx = await storeFront.buy(tokens,0);
	// await tx.wait();

	// const contract = nft.address
	// console.log(contract)
	// const mint = await nft.mint("0xbb489547904ffbabc0687bcf8b79658cfb2848e27df0dd3e3cd16c5a930e3194");
	// const uri = await nft.tokenURI("0xbb489547904ffbabc0687bcf8b79658cfb2848e27df0dd3e3cd16c5a930e3194")
	// console.log(mint, uri)
	// fs.writeFileSync(__dirname + '/../src/config/v1.json', JSON.stringify({ contract }, null, '\t'))

	// // token deploy
	// const USDT = await ethers.getContractFactory("Token");
	// const usdt= await USDT.deploy(1000)
	
    // await usdt.deployed();
	// console.log(usdt.address)

	const multicall = await ethers.getContractFactory("Multicall");
	const multicallContract = await multicall.deploy()
    await multicallContract.deployed();
	console.log("multicall contract", multicallContract.address)

    const Factory = await ethers.getContractFactory("Marketplace");
    marketplace = await upgrades.deployProxy(Factory);
    await marketplace.deployed();
    console.log("marketplae contract", marketplace.address);
    // treasury admin
    var tx = await marketplace.addAdmin("0xf2d5FCAD97047221887DE67A1f4Ce057e6480BEc", "0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470");
    await tx.wait()
    //marketplace manager
    var tx = await marketplace.addAdmin("0x0200704DC88c1AC000B6592288A3E8ee9bb76b04", "0xc5d24673b7bfad8045d85a4707233c927e7db2dca703c0e0186f500b623ca824");
    await tx.wait()
	console.log("success")

	//npx hardhat verify “ADDRESS” --network goerli
}

main().then(() => {
}).catch((error) => {
	console.error(error);
	// process.exit(1);
});
