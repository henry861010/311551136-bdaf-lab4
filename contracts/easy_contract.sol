 // contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";  

contract easy1 {

	bool isInitialized;
	address owner;
	mapping(address => uint256) Fee; //first: token, second: amount of fee
	mapping(address => mapping(address => uint256)) balance;  //first: client, second: token(smart contract)
	string constant version = "v 1.0,0";
	
	constructor() {
    		owner=msg.sender;
    	}
    	
    	function initialize(address owner_) external{
    		require(!isInitialized,"already initialized");
    		isInitialized = true;
    		owner =owner_;
    	}
    	
    	function get_version() external view returns(string memory){
    		console.log("      ",version);
    		return version;
    	}
    	
    	function test_proxy_pattern(string memory tap) external view returns(string memory){
    		console.log("       successfully - ",tap);
    		return "    successfully - ";
    	}
    	
    	function deposit(address token, uint256 amount) external {
    		try ERC20(token).transferFrom(msg.sender,address(this),amount){
    			balance[msg.sender][token]+=(amount*1000-amount);  //there is no fp type in solidaty, multiple 1000 to avoid the error because of round down
    			Fee[token]+=amount;
    		}catch{
    			revert("transfer failed");
    		}

    	}

	function withdraw(address token, uint256 amount) external {
		require(balance[msg.sender][token]>=amount,"the amount of token in the account is not enough!");
		try ERC20(token).transfer(msg.sender,amount){
			balance[msg.sender][token]-=amount*1000;
		}catch{
			revert("transfer failed");
		}
	}
	
	function takeFee(address token) external {
		require(msg.sender==owner,"only the owner can take Fee");
console.log("takefee");
		try ERC20(token).transfer(msg.sender,Fee[token]/1000){
			// deposit the amount of (Fee/1000) Fee from contract will cause there is Fee smaller than 1000 leaves in the contract implicitly
			// so i add instruction "Fee=Fee%1000;" to make sure there is no Fee disappear
			Fee[token]=Fee[token]%1000;
		}catch{
			revert("transfer failed");
		}
	}
	
	
	function fee(address token) external view returns(uint256){   //check how many fee remain in contract
		console.log("      Fee: ",Fee[token]);
		return Fee[token];
	}
	function balanceof(address account, address token) external view returns(uint256){  //check balance of accounct in token
		console.log("      balance: ",balance[account][token]);
		return balance[account][token];
	}
	function safecontract_owner() external view returns(address){   //check how many fee remain in contract
		console.log("      owner: ",owner);
		return owner;
	}
}

contract easy2 {

	bool isInitialized;
	address owner;
	mapping(address => uint256) Fee; //first: token, second: amount of fee
	mapping(address => mapping(address => uint256)) balance;  //first: client, second: token(smart contract)
	string constant version = "v 2.0,0";
	
	constructor() {
    		owner=msg.sender;
    	}
    	
    	function initialize(address owner_) external{
    		require(!isInitialized,"already initialized");
    		isInitialized = true;
    		owner =owner_;
    	}
    	
    	function get_version() external view returns(string memory){
    		console.log("      ",version);
    		return version;
    	}
    	
    	function test_proxy_pattern(string memory tap) external view returns(string memory){
    		console.log("    successfully - ",tap);
    		return "    successfully - ";
    	}
    	
    	function deposit(address token, uint256 amount) external {
    		try ERC20(token).transferFrom(msg.sender,address(this),amount){
    			balance[msg.sender][token]+=(amount*1000-amount);  //there is no fp type in solidaty, multiple 1000 to avoid the error because of round down
    			Fee[token]+=amount;
    		}catch{
    			revert("transfer failed");
    		}

    	}

	function withdraw(address token, uint256 amount) external {
		require(balance[msg.sender][token]>=amount,"the amount of token in the account is not enough!");
		try ERC20(token).transfer(msg.sender,amount){
			balance[msg.sender][token]-=amount*1000;
		}catch{
			revert("transfer failed");
		}
	}
	
	function takeFee(address token) external {
		require(msg.sender==owner,"only the owner can take Fee");
		try ERC20(token).transfer(msg.sender,Fee[token]/1000){
			// deposit the amount of (Fee/1000) Fee from contract will cause there is Fee smaller than 1000 leaves in the contract implicitly
			// so i add instruction "Fee=Fee%1000;" to make sure there is no Fee disappear
			Fee[token]=Fee[token]%1000;
		}catch{
			revert("transfer failed");
		}
	}
	
	
	function fee(address token) external view returns(uint256){   //check how many fee remain in contract
		console.log("      Fee: ",Fee[token]);
		return Fee[token];
	}
	function balanceof(address account, address token) external view returns(uint256){  //check balance of accounct in token
		console.log("      balance: ",balance[account][token]);
		return balance[account][token];
	}
	function safecontract_owner() external view returns(address){   //check how many fee remain in contract
		console.log("       owner: ",owner);
		return owner;
	}
}
