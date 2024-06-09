//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "libraries/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LiadexLiquidityToken is ERC20 {
    constructor() ERC20("Liadex Liquidity Token", "LLT") {}

    function mint(address to, uint256 amount) internal {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) internal {
        _burn(from, amount);
    }
}