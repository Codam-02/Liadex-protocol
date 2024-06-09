// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LiadexERC20 is ERC20, Ownable {
    uint256 private _maxSupply;

    constructor() ERC20("Liadex", "LDX") Ownable(msg.sender) {
        _maxSupply = 10**24;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        require(totalSupply() + amount <= _maxSupply, "ERC20: minting exceeds max supply");
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }

    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }
}
