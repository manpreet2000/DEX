// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
import { Contract, ContractFactory } from 'ethers';

async function main(): Promise<void> {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const tokenfactory:ContractFactory = await ethers.getContractFactory("ManniToken");
  const token = await tokenfactory.deploy();
  
  await token.deployed();
  await token.Ownable();

  const swapfactory:ContractFactory = await ethers.getContractFactory("Swap");
  const swap = await swapfactory.deploy(token.address);
  await swap.deployed();
  await swap.Ownable();

  console.log("token deployed to:", token.address);
  console.log("swap deployed to:", swap.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
