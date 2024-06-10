// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/*
    This contract is an ERC20 token that lets any user swap their Ether for a "Wrapped Ether" ERC20 and
    viceversa. The string inputs in the ERC20 constructor stand as the name and the symbol for the ERC20 token.
    Anyone intending to use this code should first make sure they understand the implemented 
    @openzeppelin libraries and the following code itself.
*/
contract WrappedEther is ERC20 {
    constructor() ERC20("Sepolia Wrapped Ether", "WETH") {}

    event Wrapped(address indexed user, uint256 amount);
    event Unwrapped(address indexed user, uint256 amount);

    function mint(address to, uint256 amount) private {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) private {
        _burn(from, amount);
    }

    function wrap() public payable {
        require(msg.value > 0, "No Ether sent");
        
        mint(msg.sender, msg.value);
        emit Wrapped(msg.sender, msg.value);
    }

    function unwrap(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient WETH balance");

        burn(msg.sender, amount);
        
        payable(msg.sender).transfer(amount);
        
        emit Unwrapped(msg.sender, amount);
    }

    //fallback function 
    receive() external payable {
        wrap();
    }
}
