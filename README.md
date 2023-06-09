# 311551136-bdaf-lab4  
There are three contract:
* 1. Safecontract: it is like a bank, which you can deposit and withdraw the different ERC20-token in. it provides the following function:  
      1. deploy: `Safecontract.deplot([OWNER_ADDRESS])`  
      2. `get_version()`: get the version of the contract  
      3. `deposit(address token, uint256 amount)`: deposit the token to the contract. there is the 0.1% fee  
      4. `withdraw(address token, uint256 amount)`: withdraw the token from the contract  
      5. `takeFee(address token)`: take fee from the contract. only the owner can execute this function
      6. `fee(address token)`: get the fee which stores in the contract  
      7. `balanceof(address account, address token)`: get the balance 
      8. `safecontract_owner()`: get the owner of the safe contract  
* 2. Proxy: a proxy contract which let the owner update the implmentation contract. it provides the following function:  
      1. deploy: `proxy.deplot([IMPLEMENTATION_ADDRESS], [OWNER_ADDRESS])`  
      2. `update_implementation(address newImp)`: used to updata the implementation  
      3. `update_owner(address newOwner)`:used to updata the owner of proxy  
      4. `owner()`:used to get the owner of this proxy  
* 3. SafeFactory: it is a factory of Safecontract, which let the user get the proxy or safec ontract from it. it provides the following function:  
      deploy: `SafeFactory.deplot([IMPLEMENTATION_CONTRACT])`  
      1. `updateImplementation(address newImp)`: update the Safecontract in the factory    
      2. `deploySafeProxy()`:deploy the proxy contract which delegates Safecontract and the owners of the both Smartcontact and proxy are function caller  
      3. `deploySafe()`:deploy the Safecontract contract whose owner is function caller   
      4. `proxy_search(address owner)`: get the caller's proxy contract which was generated by factoy.
      5. `safecontract_search(address owner)`: get the caller's Smartcontract whish is generated by factoy.

Please note, When use `deposit(token,amount)` method, you need to set the `allowance(THIS_CONTRACT_ADRESS,amount)` method blong to what the token you want to store, to allow the contract transfer token from your account.

## 1. set the enviroment  
going to the folder of the program and running the following instructions in the shell:  
* 1. install or upgrade the package: `npm install`  
* 2. add the following enviroment variable into `.env` file:  
      1. API_URL = [YOUR_API_URL]   
      2. API_KEY = [YOUR_API_KEY]   
      3. PRIVATE_KEY = [YOUR_PRIVATE_KEY]   
      4. ETHERSCAN_API_KEY = [YOUR_ETHERSCAN_API_KEY]   
      5. PUBLIC_KEY = [YOUR_PUBLIC_KEY]   
* 3. make sure the version of node.js up to v16.0.0
## 2. run program  
* 1. compile the contract with hardhat: `npx hardhat compile`
* 2. deploy the contract to the goerli network, and then get the address of the deployed contract:   
      1. deploy the safecontract: `npx hardhat run deploy/deploy_safecontract.js --network goerli` 
      2. deploy the proxy:`npx hardhat run deploy/deploy_proxy.js --network goerli`  
      3. deploy the safefactory:`npx hardhat run deploy/safefactory.js --network goerli` 
* 3. verify the contract on the goerli network with hardhat: `npx hardhat verify --network goerli [DEPLOYED_CONTRACT_ADDRESS]` 

## 3. reference
* 1. how to deploy the contract with hardhat: https://docs.alchemy.com/docs/hello-world-smart-contract
* 2. how to verify the contract with hardhat: https://docs.alchemy.com/docs/submitting-your-smart-contract-to-etherscan
* 3. https://bdaf.notion.site/Lab4-Proxies-Proxies-everywhere-0191cd4bfc0547eaaaae952226fd1ca3

## 4. gas report and coverage
![螢幕擷取畫面 (100)](https://user-images.githubusercontent.com/98812000/229415865-04864c3c-927d-47d2-8e58-6133e9db34b4.png)

 

