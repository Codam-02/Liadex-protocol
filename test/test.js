const {loadFixture} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const {expect} = require("chai"); 

describe("Ether wrapper contract tests", function() {

    async function wrapperFixture() {
        const weth = await hre.ethers.deployContract("WrappedEther");
        await weth.waitForDeployment();
        const [signer1] = await ethers.getSigners();
        return { weth , signer1 };
    }

    it ("user balances should be as expected after both wrap and unwrap function calls", async function() {
        const { weth , signer1 } = await loadFixture(wrapperFixture);

        const wethAddress = await weth.getAddress();
        const amount = ethers.parseEther("1.0");
            
        const tx = {
            to: wethAddress,
            value: amount,
        };
        await signer1.sendTransaction(tx);
        expect(await weth.balanceOf(signer1)).to.equal(amount);
        await weth.connect(signer1).unwrap(ethers.parseEther("0.6"));
        expect(await weth.balanceOf(signer1)).to.equal(ethers.parseEther("0.4"));
    });

    it ("attempting to unwrap a WETH amount that exceeds balance should result in a reverted transaction", async function() {
        const { weth , signer1 } = await loadFixture(wrapperFixture);
        
        await expect(weth.connect(signer1).unwrap(1)).to.be.revertedWith("Insufficient WETH balance");
    });
});

//--------------------------------------------------------------------------

describe("ERC20 contract tests", function() {

    async function ERC20Fixture() {
        const [deployer, signer1] = await ethers.getSigners();
        const tokenContractFactory = await hre.ethers.getContractFactory("LiadexERC20");
        await tokenContractFactory.connect(deployer);
        const ERC20Contract = await tokenContractFactory.deploy();
        await ERC20Contract.waitForDeployment();
        return { ERC20Contract, deployer, signer1 };
    }

    it("attempting to mint tokens from a non-deployer account should result in a reverted transaction", async function() {
        const { ERC20Contract, deployer, signer1 } = await loadFixture(ERC20Fixture);
        await ERC20Contract.connect(deployer).mint(signer1.getAddress(), 1);
        await expect(ERC20Contract.connect(signer1).mint(deployer.getAddress(), 1)).to.be.reverted;
    });

    it("attempting to burn tokens to an account with lower balance than burn amount should result in a reverted transaction", async function() {
        const { ERC20Contract, deployer, signer1 } = await loadFixture(ERC20Fixture);
        await expect(ERC20Contract.connect(deployer).burn(signer1.getAddress(), 1)).to.be.reverted;
    });

    it("owner attempting to mint tokens past the maximum supply should result in a reverted transaction", async function() {
        const { ERC20Contract, deployer, signer1 } = await loadFixture(ERC20Fixture);
        await expect(ERC20Contract.connect(deployer).mint(signer1.getAddress(), ethers.parseEther("1000001"))).to.be.revertedWith("ERC20: minting exceeds max supply");
    });

});

//--------------------------------------------------------------------------

describe("Trading pair contract tests", function() {

    async function tradingPairFixture() {
        const [deployer, signer1] = await ethers.getSigners();

        const wethContract = await hre.ethers.deployContract("WrappedEther");
        await wethContract.waitForDeployment();
        const wethAddress = await wethContract.getAddress();
        const amount = ethers.parseEther("1.0");
        const tx = {
            to: wethAddress,
            value: amount,
        };
        await signer1.sendTransaction(tx);
        
        const tokenContractFactory = await hre.ethers.getContractFactory("LiadexERC20");
        await tokenContractFactory.connect(deployer);
        const tokenContract = await tokenContractFactory.deploy();
        await tokenContract.connect(deployer).mint(signer1.getAddress(), 10**9);
        
        const tradingPairContract = await hre.ethers.deployContract("TradingPair", [wethAddress, tokenContract.getAddress()]);
        await tradingPairContract.waitForDeployment();
        
        return { signer1, wethContract, tokenContract, tradingPairContract };
    }

    it("trading pair contract's balances should be as expected after liquidity provision", async function() {
        const { signer1, wethContract, tokenContract, tradingPairContract } = await loadFixture(tradingPairFixture);
        
        await wethContract.connect(signer1).approve(tradingPairContract.getAddress(), ethers.parseEther("100"));
        await tokenContract.connect(signer1).approve(tradingPairContract.getAddress(), ethers.parseEther("100"));
        
        await tradingPairContract.connect(signer1).addLiquidity(ethers.parseEther("1.0"), 10**9);
        const [reserveA, reserveB] = await tradingPairContract.getReserves();
        
        expect(await tradingPairContract.balanceOf(signer1.getAddress())).to.equal(ethers.parseEther("1000"));
        expect(reserveA).to.equal(ethers.parseEther("1"));
        expect(reserveB).to.equal(BigInt(10**9));
    });

    it("trading pair contract's balances should be as expected after liquidity withdrawal", async function() {
        const { signer1, wethContract, tokenContract, tradingPairContract } = await loadFixture(tradingPairFixture);
        
        await wethContract.connect(signer1).approve(tradingPairContract.getAddress(), ethers.parseEther("100"));
        await tokenContract.connect(signer1).approve(tradingPairContract.getAddress(), ethers.parseEther("100"));
        
        await tradingPairContract.connect(signer1).addLiquidity(ethers.parseEther("1.0"), 10**9);

        await tradingPairContract.connect(signer1).withdraw(ethers.parseEther("0.4"), (10**8)*4);
        expect(await tradingPairContract.balanceOf(signer1.getAddress())).to.equal(ethers.parseEther("600"));

        const [reserveA, reserveB] = await tradingPairContract.getReserves();
        expect(reserveA).to.equal(ethers.parseEther("0.6"));
        expect(reserveB).to.equal(BigInt((10**8)*6));
    });

    it("user balances should be as expected after swap", async function() {
        const { signer1, wethContract, tokenContract, tradingPairContract } = await loadFixture(tradingPairFixture);
        await wethContract.connect(signer1).approve(tradingPairContract.getAddress(), ethers.parseEther("100"));
        await tokenContract.connect(signer1).approve(tradingPairContract.getAddress(), ethers.parseEther("100"));
        
        await tradingPairContract.connect(signer1).addLiquidity(ethers.parseEther("0.1"), 10**9);
        await tradingPairContract.connect(signer1).swap(ethers.parseEther("0.01"), 0);

        expect(await tokenContract.balanceOf(signer1.getAddress())).to.equal(BigInt((10**8)*0.995));
    });

});