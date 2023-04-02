 // contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";  //to debug!!!!!

contract Token is ERC20 {
    constructor(uint256 initialSupply) ERC20("Gold", "GLD") {
        _mint(msg.sender, initialSupply);
    }
    
    function bb(address account) external view{
    	console.log(balanceOf(account));  //********************
    }
}
