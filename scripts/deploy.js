// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
// const hre = require("hardhat");

// const hre = import("hardhat");
import {config as dotenv} from "dotenv";
dotenv();

const hre = require("hardhat");
async function main() {

  const votingToken = await hre.ethers.deployContract("VotingTokenV2" );
  await votingToken.waitForDeployment();

  const votingContract = await hre.ethers.deployContract("VotingContract", [ votingToken.target ]);
  await votingContract.waitForDeployment();


   console.log(
    `Voting Token deployed at address: ${await votingToken.getAddress()} \n `  + 
    `Voting Contract deployed at: ${await votingContract.getAddress()}`
  )

  //old version of hardhat-tools use this: 
  // const vTFactory = await hre.ethers.getContractFactory("VotingTokenV2");
  // const vtToken = await vTFactory.deploy();
  // await vtToken.deployed();

}
const privateKey = process.env.WALLET_PRIV_KEY // Enter your private key;

module.exports = {
  networks: {
    klaytnTestnet: {
      provider: () => new HDWalletProvider(privateKey, "https://public-node-api.klaytnapi.com/v1/baobab"),
      network_id: '1001', //Klaytn baobab testnet's network id
      gas: '8500000',
      gasPrice: null
    }
  }
};

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
