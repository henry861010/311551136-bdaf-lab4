require('dotenv').config();

async function main() {
   const { PUBLIC_KEY } = process.env;
   const SafeUpgradeable = await ethers.getContractFactory("SafeUpgradeable");
   const SafeUpgradeable_ = await SafeUpgradeable.deploy(PUBLIC_KEY);   
   const proxy = await ethers.getContractFactory("proxy");
   const proxy_ = await proxy.deploy(SafeUpgradeable_.address,PUBLIC_KEY);   
   console.log(Contract deployed to address:, proxy_.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
