//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";

import "hardhat/console.sol";  //to debug!!!!!


contract Safecontract{

	address owner;
	mapping(address => uint256) Fee; //first: token, second: amount of fee, the tha value is equal to real_amount*1000
	mapping(address => mapping(address => uint256)) balance;  //first: client, second: token(smart contract), the tha value is equal to real_amount*1000
	
	constructor(address owner_) {
    		owner=owner_;
    	}
    	
    	function deposit(address token, uint256 amount) external {  //deposit the token
    		try ERC20(token).transferFrom(msg.sender,address(this),amount){
    			balance[msg.sender][token]+=(amount*1000-amount);  //there is no fp type in solidaty, multiple 1000 to avoid the error because of round down
    			Fee[token]+=amount;
    		}catch{
    			revert("transfer failed");
    		}

    	}

	function withdraw(address token, uint256 amount) external {  //withdraw the token
		require(balance[msg.sender][token]>=amount*1000,"the amount of token in the account is not enough!");  //he balance must be larger than the amount want to withdraw
		ERC20(token).transfer(msg.sender,amount);
		balance[msg.sender][token]-=amount*1000;
	}
	
		
	//deposit the amount of (Fee/1000) Fee from contract will cause there is Fee smaller than 1000 leaves in the contract implicitly
	//so i add instruction "Fee=Fee%1000;" to make sure there is no Fee disappear
	function takeFee(address token) external {
		require(msg.sender==owner,"only the owner can take Fee");
		ERC20(token).transfer(msg.sender,Fee[token]/1000);
		Fee[token]=Fee[token]%1000;
	}
	
	
	function fee(address token) external view returns(uint256){   //check how many fee remain in contract
		return Fee[token];
	}
	function balanceof(address account, address token) external view returns(uint256){  //check balance of accounct in token
		return balance[account][token];
	}
	function safecontract_owner() external view returns(address){   //check how many fee remain in contract
		return owner;
	}
}



contract SafeUpgradeable{

	bool isInitialized;
	address owner;
	mapping(address => uint256) Fee; //first: token, second: amount of fee, the tha value is equal to real_amount*1000
	mapping(address => mapping(address => uint256)) balance;  //first: client, second: token(smart contract), the tha value is equal to real_amount*1000
	
	constructor(address owner_) {
    		owner=owner_;
    	}
    	
    	function initialize(address owner_) external{   //for the proxy pattern, there is need initialize() to initialize contract
    		require(!isInitialized,"already initialized");
    		isInitialized = true;
    		owner =owner_;
    	}
    	
    	
    	function deposit(address token, uint256 amount) external {  //deposit the token
    		try ERC20(token).transferFrom(msg.sender,address(this),amount){
    			balance[msg.sender][token]+=(amount*1000-amount);  //there is no fp type in solidaty, multiple 1000 to avoid the error because of round down
    			Fee[token]+=amount;
    		}catch{
    			revert("transfer failed");
    		}

    	}

	function withdraw(address token, uint256 amount) external {  //withdraw the token
		require(balance[msg.sender][token]>=amount*1000,"the amount of token in the account is not enough!");  //he balance must be larger than the amount want to withdraw
		ERC20(token).transfer(msg.sender,amount);
		balance[msg.sender][token]-=amount*1000;
	}
	
		
	//deposit the amount of (Fee/1000) Fee from contract will cause there is Fee smaller than 1000 leaves in the contract implicitly
	//so i add instruction "Fee=Fee%1000;" to make sure there is no Fee disappear
	function takeFee(address token) external {
		require(msg.sender==owner,"only the owner can take Fee");
		ERC20(token).transfer(msg.sender,Fee[token]/1000);
		Fee[token]=Fee[token]%1000;
	}
	
	
	function fee(address token) external view returns(uint256){   //check how many fee remain in contract
		return Fee[token];
	}
	function balanceof(address account, address token) external view returns(uint256){  //check balance of accounct in token
		return balance[account][token];
	}
	function safecontract_owner() external view returns(address){   //check how many fee remain in contract
		return owner;
	}
}

contract proxy{
	bytes32 private constant IMPLEMENTATION_SLOT_NUMBER = keccak256("implementation");
	bytes32 private constant OWNER_SLOT_NUMBER = keccak256("owner");
	
	constructor(address newImp,address owner_){ 
		//set the proxy information [implementation address, owner]
		set_implementation(newImp);                  //set implementation
		set_owner(owner_);                           //set owner
		initialize_safecontract(owner_);     //initialize the implementation contract
	}
	
	
	// private function to initialize the implementation when construct proxy
	function initialize_safecontract(address owner_) private{
		address inplementation = get_implementation();
        	(bool success,bytes memory data) = inplementation.delegatecall(abi.encodeWithSignature("initialize(address)",owner_)); 
	}
	

	// private function to be convenint to access owner and implement contract address	
	function get_implementation() private view returns(address){
		return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT_NUMBER).value;
	}
	
	function set_implementation(address newImp) private{
		StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT_NUMBER).value = newImp;
	}
	
	function get_owner() private view returns(address){
		return StorageSlot.getAddressSlot(OWNER_SLOT_NUMBER).value;
	}
	
	function set_owner(address newOwner) private{
		StorageSlot.getAddressSlot(OWNER_SLOT_NUMBER).value = newOwner;
	}
	
	
	//the function provided to administer to update and maintain the implementation contract
	function update_implementation(address newImp) external{  //update the implementation
		require(msg.sender==get_owner(),"only the owner can update the implementation contract");
		set_implementation(newImp);
	}
	
	function owner() external view returns(address){  //who is the owner of proxy
		return get_owner();
	}
	
	function implementation() external view returns(address){  //what the implementation right now
		return get_implementation();
	}
	
	
	fallback(bytes calldata callData) external returns (bytes memory resultData){
		address _implementation = get_implementation();
		(bool success, bytes memory resultData) = _implementation.delegatecall(callData);
	}
}




contract SafeFactory{
	address owner;
	address implementation;
	
	event proxy_record(address proxy_owner,address proxy_add);  //record the owner of the proxy contract
	event safe_record(address proxy_owner,address safe_add);    //recorf the owner of the safe contract
	
	
	constructor(address implementation_,address owner_){
		owner = owner_;
		implementation = implementation_;
	}

	function updateImplementation(address newImp) external{  //The Safe implementation address can only be updated by the owner of the Factory contract.
		require(msg.sender==owner,"only the owner of factory can update the implementation");
		implementation = newImp;
	}
	
	function deploySafeProxy() external{    //Deploys a proxy, points the proxy to the current Safe Implementation.Initializes the proxy so that the message sender is the owner of the new Safe.
    		proxy proxy_ = new proxy(implementation,msg.sender);  
    		emit proxy_record(msg.sender,address(proxy_));
    	}
    
	function deploySafe() external{  //Deploys the original Safe contract. Note that you might need to modify the Safe contract so that the original caller of the deploySafe contract will be the owner of the deployed "Safe” contract.
		Safecontract Safecontract_ = new Safecontract(msg.sender);
		emit safe_record(msg.sender,address(Safecontract_));
	}
	
}

















 
