async function main() {
   const lab3 = await ethers.getContractFactory("lab4");
   const lab3_ = await lab3.deploy();   
   console.log("Contract deployed to address:", lab3_.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
