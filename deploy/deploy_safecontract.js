require('dotenv').config();

async function main() {
   const { PUBLIC_KEY } = process.env;
   const safecontract = await ethers.getContractFactory("safecontract");
   const safecontract_ = await lab3.deploy(PUBLIC_KEY);   
   console.log(Contract deployed to address:, safecontract_.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
