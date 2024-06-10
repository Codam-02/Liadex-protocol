//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface ITradingPair {

        function swap(uint256, uint256) external;
        function addLiquidity(uint256, uint256) external;
        function withdraw(uint256, uint256) external;
        function getTokenA() external view returns (address);
        function getTokenB() external view returns (address);
        function getReserves() external view returns (uint256, uint256);
        function getK() external view returns (uint256);
        function getBalances() external view returns (uint256, uint256);
}