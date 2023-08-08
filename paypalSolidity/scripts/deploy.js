const hre = require("hardhat");

async function main() {
	const currentTimestampInSeconds = Math.round(Date.now() / 1000);
	const unlockTime = currentTimestampInSeconds + 60;
	
	const Paypal = await hre.ethers.getContractFactory("Paypal");
	const paypal = await Paypal.deploy();

	console.log(`Paypal with timestamp ${unlockTime} deployed 
 		to ${paypal.target} at address ${paypal.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
