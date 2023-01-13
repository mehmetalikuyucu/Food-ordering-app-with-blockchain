require("@nomicfoundation/hardhat-toolbox");
// require('@nomiclabs/hardhat-ganache')
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.14",
  networks: {
    goerli: {
      url: "https://eth-goerli.g.alchemy.com/v2/Zj0b5kK8LTb5II_LyUpcPTZgK7R8MNde",
      accounts: ["f98a2cbd30f91915a70293af6af1afd64594d35f34ebc2b58688ce893c92c603"],
    },
    localGanache: {
      url: "http://127.0.0.1:7545",
      accounts:["ccdc32ea72546a7a2a5c831f2c9924d36c8cc31b47b5227c6c17f84dce9913de"]
    }
  },
  etherscan: {
    apiKey: {
      goerli:'R1A22NN58AYCUF9BX9H3DK8HEU3KIT6S2G'
    }
  }
  
  };
