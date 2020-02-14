const Web3 = require('web3');
const HDWalletProvider = require('truffle-hdwallet-provider');
const { INFURA, MNEMONIC } = process.env;
const provider = new HDWalletProvider(MNEMONIC, INFURA, 0, 10);
const web3 = new Web3(provider);

const abi = require('./abi')

const factory = new web3.eth.Contract(abi, '0x7B21b1fAa6663bE1b01515f00Ba9838771c152aB')

async function start() {
  const events = await factory.getPastEvents('CreateAccount', { fromBlock: 1, toBlock: 'latest' })
  console.log(events)
}

start()
