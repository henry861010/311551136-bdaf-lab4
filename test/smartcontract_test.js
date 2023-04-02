const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");


describe("smart contract test:", function () {
  async function safecontractFixture() {
    /*
	for convience, I write a simple erc20 token named "Token" and give the address-owner 1000 token
    */
    const [owner, addr1] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("Token");	//deploy the erc20 Token
    const Token_ = await Token.deploy(1000);
    await Token_.deployed();

    const Safecontract = await ethers.getContractFactory("Safecontract");	//deploy the safecontract
    const Safecontract_ = await Safecontract.deploy(owner.address);
    await Safecontract_.deployed();

    return { Token_, Safecontract_, owner, addr1};
    	// Token_: erc20 token address used totest smart contract
    	// Safecontract_ : smartcontract address
    	// owner: the owner of smartcontract
    	// addr1: client address
  }
  
  
  it("addr1 deposit 1000 token", async function () {
    const { Token_, Safecontract_, owner, addr1 } = await loadFixture(safecontractFixture);
    
    await Token_.transfer(addr1.address,1000);  //transfer token 1000 to addr1
    await expect(await Token_.balanceOf(addr1.address)).to.equal(1000);
    
    await Token_.connect(addr1).approve(Safecontract_.address,1000);  //deposit token to safeconrect - approve at token first
    await Safecontract_.connect(addr1).deposit(Token_.address,1000);  //deposit token to safeconrect
    await expect(await Safecontract_.balanceof(addr1.address,Token_.address)).to.equal(999000);  //check the amunt of token == (deposit token)*0.999*1000  [999000]
    await expect(await Safecontract_.fee(Token_.address)).to.equal(1000);  //check the amunt of fee == (deposit token)*0.001*1000  [1000]
    
    await Safecontract_.connect(owner).takeFee(Token_.address);   //takefee()
    await expect(await Token_.balanceOf(owner.address)).to.equal(1);  //check if there is (deposit token)*0.001 in owner account of Token_
    await expect(await Safecontract_.fee(Token_.address)).to.equal(0);  //check if there is (deposit token)*0.001 in owner account of Token_
    
    await Safecontract_.connect(addr1).withdraw(Token_.address,999);   //takefee()
    await expect(await Token_.balanceOf(addr1.address)).to.equal(999);  //check if there is (deposit token)*0.999+900 in owner account of Token_
    await expect(await Safecontract_.balanceof(addr1.address,Token_.address)).to.equal(0);  //check if there is (deposit token)*0.001 in owner account of Token_
  });
  
  it("addr1 deposit 100 token", async function () {
    const { Token_, Safecontract_, owner, addr1 } = await loadFixture(safecontractFixture);
    
    await Token_.transfer(addr1.address,1000);  //transfer token 1000 to addr1
    await expect(await Token_.balanceOf(addr1.address)).to.equal(1000);
    
    await Token_.connect(addr1).approve(Safecontract_.address,100);  //deposit token to safeconrect - approve at token first
    await Safecontract_.connect(addr1).deposit(Token_.address,100);  //deposit token to safeconrect
    await expect(await Safecontract_.balanceof(addr1.address,Token_.address)).to.equal(99900);  //check the amunt of token == (deposit token)*0.999*1000  [999000]
    await expect(await Safecontract_.fee(Token_.address)).to.equal(100);  //check the amunt of fee == (deposit token)*0.001*1000  [1000]
    
    await Safecontract_.connect(owner).takeFee(Token_.address);   //takefee()
    await expect(await Token_.balanceOf(owner.address)).to.equal(0);  //check if there is (deposit token)*0.001 in owner account of Token_
    await expect(await Safecontract_.fee(Token_.address)).to.equal(100);  //check if there is (deposit token)*0.001 in owner account of Token_
    
    await Safecontract_.connect(addr1).withdraw(Token_.address,99);   //takefee()
    await expect(await Token_.balanceOf(addr1.address)).to.equal(999);  //check if there is (deposit token)*0.999+900 in owner account of Token_
    await expect(await Safecontract_.balanceof(addr1.address,Token_.address)).to.equal(900);  //check if there is (deposit token)*0.001 in owner account of Token_
  });
    
});

