//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "contracts/LiadexLiquidityToken.sol";
import "libraries/SafeMath.sol";
import "interfaces/ITradingPair.sol";

/*
    This contract is automated-market-maker based liquidity pool that can be initialized via constructor
    on any two distinct ERC20-token contracts and lets users add liquidity to the pool, remove it, or swap
    one of the two ERC20s for the other. Anyone intending to use this code should first make sure they
    understand the implemented contracts, interfaces and libraries and the following code itself.
*/
contract TradingPair is LiadexLiquidityToken, ITradingPair {

    event Swap(address tokenSwapped, address tokenObtained, uint256 amountSwapped, uint256 amountObtained);
    event LiquidityAddded(uint256 amountA, uint256 amountB);
    event LiquidityWithdrawn(uint256 amountA, uint256 amountB);

    using SafeMath for uint256;

    address public immutable _tokenA;
    address public immutable _tokenB;
    uint256 private _reserveA = 0;
    uint256 private _reserveB = 0;
    uint256 private _k; //this value represents the ratio between the two token reserves

    constructor (address tokenA, address tokenB) {
        _tokenA = tokenA;
        _tokenB = tokenB;
    }

    function getK() public view returns (uint256) {
        return _k;
    }

    function getTokenA() public view returns (address) {
        return _tokenA;
    }

    function getTokenB() public view returns (address) {
        return _tokenB;
    }

    function getReserves() public view returns (uint256, uint256) {
        return (_reserveA, _reserveB);
    }

    function getBalances() public view returns (uint256, uint256) {
        return (IERC20(_tokenA).balanceOf(address(this)), IERC20(_tokenB).balanceOf(address(this)));
    }

    // given an amount of tokenB, this function returns its equivalent in tokenA
    function calculateTokenAEquivalent(uint256 amountB) public view returns (uint256) {
        return (_reserveA.mul(amountB).div(_reserveB));
    }

    // given an amount of tokenA, this function returns its equivalent in tokenB
    function calculateTokenBEquivalent(uint256 amountA) public view returns (uint256) {
        return (_reserveB.mul(amountA).div(_reserveA));
    }

    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require (amountA > 0 && amountB > 0, "Deposit amounts can't be 0.");

        /*
        The following if statement handles the first liquidity provision of the liquidity pool
        */
        if (totalSupply() == 0) {
            
            IERC20(_tokenA).transferFrom(address(msg.sender), address(this), amountA);
            IERC20(_tokenB).transferFrom(address(msg.sender), address(this), amountB);

            mint(address(msg.sender), 1000*(10**decimals()));
        }

        else {

            bool equalValue = calculateTokenAEquivalent(amountB) == amountA || calculateTokenBEquivalent(amountA) == amountB;
            require(equalValue, "Token amounts provided are not of equal value.");
            
            IERC20(_tokenA).transferFrom(address(msg.sender), address(this), amountA);
            IERC20(_tokenB).transferFrom(address(msg.sender), address(this), amountB);
            uint256 liquidityTokenToMint = amountA.mul(totalSupply()).div(_reserveA);
            mint(address(msg.sender), liquidityTokenToMint);
            emit LiquidityAddded(amountA, amountB);
        }

        sync();
    }

    function withdraw(uint256 amountA, uint256 amountB) external {

        require (amountA > 0 && amountB > 0, "Withdraw amounts can't be 0.");

        bool equalValue = calculateTokenAEquivalent(amountB) == amountA || calculateTokenBEquivalent(amountA) == amountB;
        require(equalValue, "Token withdraw amounts are not of equal value.");

        uint256 liquidityTokenToBurn = amountA.mul(totalSupply()).div(_reserveA);
        require(balanceOf(address(msg.sender)) >= liquidityTokenToBurn, "User doesn't own enough liquidity pool funds.");

        IERC20(_tokenA).transfer(address(msg.sender), amountA);
        IERC20(_tokenB).transfer(address(msg.sender), amountB);

        burn(address(msg.sender), liquidityTokenToBurn);

        emit LiquidityWithdrawn(amountA, amountB);

        sync();
    }

    function swap(uint256 tokenAAmount, uint256 tokenBAmount) external {
        require (tokenAAmount > 0 ? tokenBAmount == 0 : tokenBAmount > 0, "Swap failed.");
        if (tokenAAmount > 0) {
            uint256 amountBGot = calculateTokenBEquivalent(tokenAAmount).mul(995).div(1000);
            require(amountBGot < _reserveB, "Not enough reserves.");
            bool success = IERC20(_tokenA).transferFrom(address(msg.sender), address(this), tokenAAmount);
            require(success, "Swap failed.");
            IERC20(_tokenB).transfer(address(msg.sender), amountBGot);
            sync();
            emit Swap(_tokenA, _tokenB, tokenAAmount, amountBGot);
        }
        if (tokenBAmount > 0) {
            uint256 amountAGot = calculateTokenAEquivalent(tokenBAmount).mul(995).div(1000);
            require(amountAGot < _reserveA, "Not enough reserves.");
            bool success = IERC20(_tokenB).transferFrom(address(msg.sender), address(this), tokenBAmount);
            require(success, "Swap failed.");
            IERC20(_tokenA).transfer(address(msg.sender), amountAGot);
            sync();
            emit Swap(_tokenB, _tokenA, tokenBAmount, amountAGot);
        }
    }

    function sync() private {
        uint256 a = IERC20(_tokenA).balanceOf(address(this));
        uint256 b = IERC20(_tokenB).balanceOf(address(this));
        _reserveA = a;
        _reserveB = b;
        _k = a.mul(b);
    }
}