require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  
};

const privateKey = process.env.WALLET_PRIV_KEY // Enter your private key;
console.log("priv key: " + privateKey);

// module.exports = {
//   networks: {
//     klaytnTestnet: {
//       url: "https://api.baobab.klaytn.net:8651",
//       chainId: '1001', //Klaytn baobab testnet's network id
//       gasPrice: '8500000',
//       accounts: [privateKey]
//     }
//   }
// };
