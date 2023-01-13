
const {ethers} = require("hardhat");

async function main() {
  
  const BlockCart = await ethers.getContractFactory("BlockCart");
  const blockcart = await BlockCart.deploy();

  await blockcart.deployed();
  console.log(`blockcart addres: ${blockcart.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
