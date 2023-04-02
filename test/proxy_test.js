const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const abi = require('ethereumjs-abi');

describe("proxy contract test:", function () {
  async function safecontractFixture() {  
    /*
    	for convience, adding additional attribute-"version", function-"get_version()" and function-"test_proxy_pattern(string)" in the test_safecontract.
    		version: the version of the immplemenation
    		get_version(): get the version
    		test_proxy_pattern(string): after input "string", show the "string in the console"  
    	Nothing else is different between safecontract and test_safecontract except before.
    	using "easy1" and "easy2" constract name to represent the v1.0.0 and v2.0.0 test_safecontract
    */

    const [owner, addr1] = await ethers.getSigners();         //get the address to test

    const easy1 = await ethers.getContractFactory("easy1");   //deploy safecontract (version 1.0.0)
    const easy1_ = await easy1.deploy();
    await easy1_.deployed();
    
    const easy2 = await ethers.getContractFactory("easy2");   //deploy safecontract (version 2.0.0)
    const easy2_ = await easy2.deploy();
    await easy2_.deployed();
    
    const Proxy = await ethers.getContractFactory("proxy");   //deploy proxy
    const Proxy_ = await Proxy.deploy(easy1_.address,owner.address);
    await Proxy_.deployed();

    return { easy1_, easy2_, Proxy_, owner, addr1};
  }
  
  it("test [initialize_safecontract()] if update owner of implementation contract successfully", async function () {
    const {  easy1_, Proxy_, owner ,addr1} = await loadFixture(safecontractFixture);

    await console.log("       addr1 add:",addr1.address);                 //display the addr1 on the console
    
    const Signature1 = await abi.methodID('safecontract_owner', []);      //sent transaction to get the owner of implementation and show the owner on the console
    const Arguments1 = await abi.rawEncode([], []);
    const data1 = '0x' + Signature1.toString('hex') + Arguments1.toString('hex');
    await owner.sendTransaction({
  	to: Proxy_.address,
  	data: data1,
    });
    
  });
  
  it("test [owner()] if get the owner successfully", async function () {  
    const {  Proxy_, owner } = await loadFixture(safecontractFixture); 
    expect(await Proxy_.owner()).to.equal(owner.address);
  });
  
  it("test [implementation()] if get the owner successfully", async function () {  
    const {  easy1_, Proxy_, owner } = await loadFixture(safecontractFixture);
    expect(await Proxy_.implementation()).to.equal(easy1_.address);
  });
  
  it("Can execute the function in implementation by proxy pattern", async function () {  
    const {  easy1_, Proxy_, owner } = await loadFixture(safecontractFixture);
    
    const Signature1 = await abi.methodID('test_proxy_pattern', ['string']);  //sent transaction to execute "test_proxy_pattern()", and expect to se "lab4"
    const Arguments1 = await abi.rawEncode(['string'], ["lab4"]);
    const data1 = '0x' + Signature1.toString('hex') + Arguments1.toString('hex');
    await owner.sendTransaction({
  	to: Proxy_.address,
  	data: data1,
    });
  });
  
  it("test [update_implement()] if update delegate construct successfully", async function () {
    const {  easy1_, easy2_, Proxy_, owner, addr1} = await loadFixture(safecontractFixture);
    
    const Signature1 = await abi.methodID('get_version', []);  //sent transaction to implementation get new version, should be "v1.0.0" on the console
    const Arguments1 = await abi.rawEncode([], []);
    const data1 = '0x' + Signature1.toString('hex') + Arguments1.toString('hex');
    await owner.sendTransaction({
  	to: Proxy_.address,
  	data: data1,
    });
    
    await Proxy_.connect(owner).update_implementation(easy2_.address); //upgrade implementation
    
    const Signature2 = await abi.methodID('get_version', []);  //sent transaction to implementation get new version, should be "v2.0.0" on the console
    const Arguments2 = await abi.rawEncode([], []);
    const data2 = '0x' + Signature2.toString('hex') + Arguments2.toString('hex');
    await owner.sendTransaction({
  	to: Proxy_.address,
  	data: data2,
    });
  });

    
});
 
