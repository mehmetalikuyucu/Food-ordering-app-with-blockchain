const { ethers } = require("hardhat")
const {expect}=require("chai")

describe("blockcart contract", function () {
    it("deploy ediliyor",
        async () => {
            const Blockcart = await ethers.getContractFactory("BlockCart");

            const blockcart = await Blockcart.deploy(owner);
            await blockcart.deployed();
            console.log(owner);
        }
    )
});