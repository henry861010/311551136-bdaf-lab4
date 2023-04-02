/**
* @type import('hardhat/config').HardhatUserConfig
*/
require("@nomiclabs/hardhat-waffle");
require("chai").use(require("chai-as-promised")).should();
require("solidity-coverage");
require("hardhat-gas-reporter");

require('dotenv').config();
require("@nomiclabs/hardhat-ethers");

const { API_URL, PRIVATE_KEY } = process.env;

module.exports = {
   solidity: "0.8.9",
   //defaultNetwork: "goerli",
   defaultNetwork: "hardhat",
   networks: {
      hardhat: {},
      goerli: {
         url: API_URL,
         accounts: [`0x${PRIVATE_KEY}`]
      }
   },
}
