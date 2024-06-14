# Liadex protocol

This project is a network of smart contracts for an automated-market-maker based decentralized exchange.
All the contracts have already been deployed on Ethereum Sepolia testnet and users can interact with them
on this website: //.

## test/test.js

This file is a script that runs tests for the correct functioning of all smart contracts in this project.
The testing environment is hre (Hardhat Runtime Environment), and libraries implemented are 'chai' and 'mocha'.
To run these tests, use this command in the project directory: 
`npx hardhat test`

## scripts/deploy.js

This file is a script that deploys a new copy of the protocol on Ethereum Sepolia testnet, using Ethers.js.
To run this file, use this command in the project directory: 
`npx hardhat run scripts/deploy.js --network sepolia`


