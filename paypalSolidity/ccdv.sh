clear && cd paypalSolidity
{
	npx hardhat clean && npx hardhat compile
} &&
{
	deployOutput=($(npx hardhat run scripts/deploy.js --network harmony))
} &&
{
	echo "${deployOutput[*]}"
	echo
	echo ${deployOutput[-1]}
 	echo
} &&
{
	npx hardhat verify ${deployOutput[-1]} --network harmony
}
