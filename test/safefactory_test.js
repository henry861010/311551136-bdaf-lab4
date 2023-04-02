const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const abi = require('ethereumjs-abi');

describe("Safecontract factory test:", function () {
  async function safecontractFixture() {
  

    const [owner, addr1] = await ethers.getSigners();

    const easy1 = await ethers.getContractFactory("easy1");   //deploy safecontract origin one
    const easy1_ = await easy1.deploy();
    await easy1_.deployed();
    
    const easy2 = await ethers.getContractFactory("easy2");   //deploy safecontract update one
    const easy2_ = await easy2.deploy();
    await easy2_.deployed();
    
    const Factory = await ethers.getContractFactory("SafeFactory");   //deploy proxy
    const Factory_ = await Factory.deploy(easy1_.address,owner.address);
    await Factory_.deployed();

    return { easy1_, easy2_, Factory_, owner, addr1};
  }
  
  it("test [deploySafe()]", async function () {
    const {  easy1_, Factory_, owner, addr1 } = await loadFixture(safecontractFixture);
    const receipt = await Factory_.connect(addr1).deploySafe();
    const receipt_ = await receipt.wait();
    const event = await receipt_.events.filter((event)=>event.event ==="safe_record");
    expect(event[0].args[0]).to.equal(addr1.address);   

  });
 
  it("test [deploySafeProxy()]", async function () {
    const {  easy1_, Factory_, owner, addr1 } = await loadFixture(safecontractFixture);
    const receipt = await Factory_.connect(addr1).deploySafeProxy();
    const receipt_ = await receipt.wait();
    const event = await receipt_.events.filter((event)=>event.event ==="proxy_record");
    expect(event[0].args[0]).to.equal(addr1.address);   
  });
  
   it("test [updateImplementation()]", async function () {
    const {  easy1_, easy2_, Factory_, owner, addr1 } = await loadFixture(safecontractFixture);
    await Factory_.connect(owner).updateImplementation(easy2_.address);
    
    const receipt = await Factory_.connect(addr1).deploySafeProxy();
    const receipt_ = await receipt.wait(); 
    const event = await receipt_.events.filter((event)=>event.event ==="proxy_record");
    
    const Signature1 = await abi.methodID('get_version', []);  //sent transaction to implementation get new version, should be "v1.0.0"
    const Arguments1 = await abi.rawEncode([], []);
    const data1 = '0x' + Signature1.toString('hex') + Arguments1.toString('hex');
    await owner.sendTransaction({
  	to: event[0].args[1],
  	data: data1,
    });
  });
    
}); 
