require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.14",
  networks: {
    goerli: {
      url: "https://eth-goerli.g.alchemy.com/v2/Zj0b5kK8LTb5II_LyUpcPTZgK7R8MNde",
      accounts: ["f98a2cbd30f91915a70293af6af1afd64594d35f34ebc2b58688ce893c92c603"],
    }
  },
  etherscan: {
    apiKey: {
      goerli:'R1A22NN58AYCUF9BX9H3DK8HEU3KIT6S2G'
    }
  }
  
  };
