require("@nomicfoundation/hardhat-ethers");
require("dotenv").config();


const { SEPOLIA_PRIVATE_KEY, SEPOLIA_RPC_URL } = process.env;

module.exports = {
  solidity: "0.8.20",
  networks: {
    sepolia: {
      url: SEPOLIA_RPC_URL,
      accounts: [SEPOLIA_PRIVATE_KEY]
    }
  }
};
