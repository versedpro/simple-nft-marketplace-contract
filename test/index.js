const { ethers, upgrades } = require("hardhat");
var owner, userWallet, userWallet1;


describe("marketplace", function () {
    it("Create account", async function () {
        [owner, userWallet, userWallet1] = await ethers.getSigners();
        console.log("deployer address:: ", owner.address, userWallet.address, userWallet1.address);
    });

    it("token-create", async () => {
        const USDT = await ethers.getContractFactory("Token");
        const usdt = await USDT.deploy(10000000000000)

        await usdt.deployed();
        console.log(usdt.address)
    })
});


// (async () => {

// })()