/*
	This javascript file deploys a copy of Liadex protocotol according to parameters defined in
	'hardhat.config.js'. Anyone intending to run this code should add in this project directory a '.env'
	file containing the private key of the account from which they intend to deploy the contracts and
	an rpc url for a blockchain endpoint. The 'hardhat.config.js' file provided in this repository is
	designed for Ethereum Sepolia testnet.
*/

async function main() {

	const [deployer] = await ethers.getSigners();

	const wrappedEtherFactory = await ethers.getContractFactory("WrappedEther");
	const liadexErc20Factory = await ethers.getContractFactory("LiadexERC20");
	const tradingPairFactory = await ethers.getContractFactory("TradingPair");

	console.log("Deploying weth contract from address: ", await deployer.getAddress());
	const wethContract = await wrappedEtherFactory.connect(deployer).deploy();
	await wethContract.waitForDeployment();
	const wethAddress = await wethContract.getAddress()
	console.log("Weth contract deployed at address: ", wethAddress);
	console.log();

	console.log("Deploying liadex ERC20 contract from address: ", await deployer.getAddress());
	const liadexErc20Contract = await liadexErc20Factory.connect(deployer).deploy();
	await liadexErc20Contract.waitForDeployment();
	const liadexErc20Address = await liadexErc20Contract.getAddress()
	console.log("Liadex ERC20 contract deployed at address: ", liadexErc20Address);
	console.log();

	console.log("Deploying Trading Pair contract from address: ", await deployer.getAddress());
	const tradingPairContract = await tradingPairFactory.connect(deployer).deploy(wethAddress, liadexErc20Address);
	await tradingPairContract.waitForDeployment();
	console.log("Trading Pair contract deployed at address: ", await tradingPairContract.getAddress());
}
  
main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
});
  