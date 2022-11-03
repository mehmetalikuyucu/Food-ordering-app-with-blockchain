const { ethers } = require("hardhat")
const {expect}=require("chai")

describe("blockcart contract", function () {
beforeEach('deploy edildi', async () => {
  const Blockcart = await ethers.getContractFactory('BlockCart')
  const blockcart = await Blockcart.deploy()
  const isDeployed = await blockcart.deployed()
  expect(isDeployed.to.equal(true))
})
    it('createCustomer', async () => {
  
})


     
});