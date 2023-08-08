require("@nomiclabs/hardhat-waffle");
require("@eaglewalker/hardhat-cronoscan");
const dotenv = require("dotenv");

dotenv.config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
	solidity: "0.8.9",
	networks: {
		harmony: {
			url: "https://api.s0.b.hmny.io",
			chainId: 1666700000,
			accounts: [process.env["PRIVATE_KEY"]]
		},
		cronosTestnet: {
			url: "https://evm-t3.cronos.org/",
			chainId: 338,
			accounts: [process.env["PRIVATE_KEY"]]
		}
	},
	etherscan: {
		apiKey: process.env.API_KEY
	}
};
