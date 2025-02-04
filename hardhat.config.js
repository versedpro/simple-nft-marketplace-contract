require("dotenv").config();
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require('@openzeppelin/hardhat-upgrades');


// require("./tasks");
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
    const accounts = await ethers.getSigners();

    for (const account of accounts) {
        console.log(account.address);
    }
});

// task("check-price", "", async (taskArgs, hre) => {
//     const [owner] = await ethers.getSigners();
//     const Factory = await ethers.getContractFactory("Marketplace");
//     const marketplace = await Factory.attach("0x19c82A352995424Ec6783D18a52c78220A7E60A9");
//     let data = await marketplace.orderByAssetId("0x5017a7f8B89b1eE16DEeE58A8a17Ba4e35060378", "5");
//     console.log(data);

// })

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    networks: {
        localhost: {
            url: "http://127.0.0.1:8545",
        },
        ganache: {
            url: "http://127.0.0.1:7545",
        },
        fantom_test: {
            url: "https://fantom-testnet.public.blastapi.io",
            accounts: [process.env.PRIVATEKEY, process.env.PRIVATEKEY1, process.env.PRIVATEKEY2],
        },
        arbitrum_goerli: {
            url: "https://goerli-rollup.arbitrum.io/rpc",
            accounts: [process.env.PRIVATEKEY, process.env.PRIVATEKEY1, process.env.PRIVATEKEY2],
        },
        ethereum: {
            url: "https://main-light.eth.linkpool.io/",
            accounts: [process.env.PRIVATEKEY, process.env.PRIVATEKEY1, process.env.PRIVATEKEY2],
        },
        ICICB: {
            url: "http://3.17.193.52/",
            accounts: [process.env.PRIVATEKEY, process.env.PRIVATEKEY1, process.env.PRIVATEKEY2],
        },
        ICICBtestnet: {
            url: "http://13.58.153.103/",
            accounts: [process.env.PRIVATEKEY, process.env.PRIVATEKEY1, process.env.PRIVATEKEY2],
        },
        bsc: {
            url: "https://bsc-dataseed1.ninicoin.io/",
            accounts: [process.env.PRIVATEKEY, process.env.PRIVATEKEY1, process.env.PRIVATEKEY2],
        },
        matic: {
            url: "https://rpc-mainnet.matic.quiknode.pro",
            accounts: [process.env.PRIVATEKEY, process.env.PRIVATEKEY1, process.env.PRIVATEKEY2],
        },
        fantom: {
            url: "https://rpc.ftm.tools/",
            accounts: [process.env.PRIVATEKEY, process.env.PRIVATEKEY1, process.env.PRIVATEKEY2],
        },
        rinkeby: {
            url: "http://85.206.160.196",
            accounts: [process.env.PRIVATEKEY, process.env.PRIVATEKEY1, process.env.PRIVATEKEY2],
        },
        sepolia: {
            url: "https://endpoints.omniatech.io/v1/eth/sepolia/public",
            accounts: [process.env.PRIVATEKEY, process.env.PRIVATEKEY1, process.env.PRIVATEKEY2],
        }
    },
    etherscan: {
        // Your API key for Etherscan
        // Obtain one at https://etherscan.io/
        // apiKey: "CGPDXGVTQXTQVQV4JZ9CTTXUE21IXAGKVB",
        apiKey: "CXFNGNMRDZP8XW4N5PWGXX55PB98DQAHNQ" //sepolia 
    },
    solidity: {
        compilers: [
            {
                version: "0.6.12",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
            {
                version: "0.8.4",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
        ],
    },
    mocha: {
        timeout: 200000,
    },
};
