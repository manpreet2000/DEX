import { expect } from "chai";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import {ManniToken,ManniToken__factory,Swap,Swap__factory} from "../typechain";

describe("Contract", function () {
  let token:ManniToken;
  let pool:Swap;
  let owner:SignerWithAddress;
  let add:SignerWithAddress[];
  let tokenaddress:string;
  beforeEach(async ()=>{
    [owner, ...add] = await ethers.getSigners();
    const tokenfactory = (await ethers.getContractFactory("ManniToken", owner)) as unknown as ManniToken__factory;
    
    token = await tokenfactory.deploy();
    await token.deployed();
    await token.Ownable();
    const poolfactory = (await ethers.getContractFactory("Swap",owner)) as unknown as Swap__factory;
    tokenaddress=token.address;
    pool = await poolfactory.deploy(tokenaddress);
    await pool.deployed();
    await pool.Ownable();
    const pooladdress = pool.address;
    console.log("token signer",await tokenfactory.signer.getAddress());
    console.log("pool signer",await poolfactory.signer.getAddress());
    console.log("owner",owner.address);
    console.log("tokenadd",tokenaddress);
    console.log("pooladd",pooladdress);
  });
  it("token minting",async()=>{
    await token.mint(tokenaddress,1000);
    const totalsupply = await token.totalSupply();
    expect(totalsupply).to.equal(1000);
  });
  it("token transfer",async ()=>{
    await token.mint(owner.address,1000);
    const totalsupply = await token.totalSupply();
    expect(totalsupply).to.equal(1000);
    await token.approve(owner.address,10);
    await token.transferFrom(owner.address,add[0].address,10);
    const balanceOfowner = await token.balanceOf(owner.address);
    expect(balanceOfowner).to.equal(990);
  });
  it("initiate swap with mni token",async()=>{
    let overrides = {
      from: owner.address,
      value: ethers.utils.parseEther("10.0")
  };
  await pool.OwnerdepositEth(overrides);
  const totaleth = await pool.totaleth();
  console.log(totaleth.toNumber()===10);

  })
  
  
});
