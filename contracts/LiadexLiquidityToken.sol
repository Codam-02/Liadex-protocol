//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "libraries/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
    This contract is an ERC20 token that's been deployed and used as liquidity token for a decentralized
    exchanges's liquidity pool. The string inputs in the ERC20 constructor stand as the name and the symbol
    for the ERC20 token. Anyone intending to use this code should first make sure they understand the
    implemented @openzeppelin and SafeMath libraries and the following code itself.
*/
contract LiadexLiquidityToken is ERC20 {
    constructor() ERC20("Liadex Liquidity Token", "LLT") {}

    function mint(address to, uint256 amount) internal {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) internal {
        _burn(from, amount);
    }
}