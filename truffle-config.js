
const HDWalletProvider = require('@truffle/hdwallet-provider');
const Web3HttpProvider = require('web3-providers-http');

const fs = require('fs');
const config = fs.readFileSync('scripts/ganache-cli.properties').toString();
const ganache = {
  host : config.match(/ethereum.host=.*/g)[0].substring(14),
  port : config.match(/ethereum.port=[0-9]*/g)[0].substring(14),
  net : config.match(/ethereum.netVersion=[0-9]*/g)[0].substring(20),
  websocket: false
}

const testKeys = config.match(/ethereum.keys.[0-9]*=.*/g).map(x => x.replace(/^ethereum.keys.[0-9]*=/, ''));
// https://web3js.readthedocs.io/en/v1.3.0/web3.html#configuration
const prodHttpOptions = { 
  keepAlive: true,
  timeout: 70000, // ms
  headers: [
    { 
      name: 'Authorization', 
      value: 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJwZXJtaXNzaW9ucyI6WyJuZXQ6KiIsImV0aDoqIiwiZGVidWc6KiIsInR4cG9vbDoqIiwiZWVhOioiXSwiZXhwIjoxNjA3MTQ4MjQ3LCJ0ZWFtIjoiMTAifQ.HJq54uc0QZeoRdzQf-fNT9LsvzgVwFUlXVc1fF1DPh4ktQ6DVNJPYAcSfOeD3K_350LcvnP73xqNGi-6OpM88m6a8O0eDkLrIqYRNVTixB1KbkX4Ka2DGDqy7VK5utLL2s0DcMKW57ONVV_YnjfxYCR76qUwjCl7amEG-y4QCpRfbC_KKhza7g7Byx0OC1vS2TRScSm3t7svXX7cbq54ndHiwKfMHPjddTwyFmcwm6jfillR___aNDo0tpkh0RQ5-C5qSba7Vf0mOmlFLzectSd5eQlK0fAIj5ouC5p2S4FUF7nnuntv140X3sBUvQBLMxvEnK7TC7opnBKKSuQBXg'
     }
  ]
};

const testHttpOptions = { keepAlive: true, timeout: 150000, withCredentials: false }


// http://truffleframework.com/docs/advanced/configuration
module.exports = {

  networks: {
    
    // https://www.trufflesuite.com/docs/truffle/reference/choosing-an-ethereum-client#truffle-develop
    builtin: {    // truffle built-in client : aka `truffle develop`
      host: '127.0.0.1',
      port: 9545,
      network_id: "*"
    },
    
    development: {
      host: ganache.host,
      port: ganache.port,
      network_id: "*",
      //gas: 4E7,
      gasPrice: 2E10,
    },
    
    chainztest: {
      // https://github.com/trufflesuite/truffle-hdwallet-provider#private-keys
      // https://github.com/trufflesuite/truffle/issues/1022
      provider: () => new HDWalletProvider(testKeys, new Web3HttpProvider("https://besutest.chainz.network/", testHttpOptions), 0, testKeys.length),
      network_id: "*",
      //gas: 200000000,
      gasPrice: 0,
      websockets: false,
      skipDryRun: true
    },

    chainzprod: {
      
      // https://github.com/trufflesuite/truffle-hdwallet-provider#private-keys
      // https://github.com/trufflesuite/truffle/issues/1022
      provider: () => new HDWalletProvider(testKeys, new Web3HttpProvider("https://besu.chainz.network/", prodHttpOptions), 0, testKeys.length),
      network_id: '*',
      //gas: 200000000,
      gasPrice: 0,
      websockets: false,
      skipDryRun: true,
      deploymentPollingInterval: 10000  // in milli-sec
    },
  },

  // https://github.com/mochajs/mocha/blob/v5.2.0/lib/mocha.js#L64
  // https://mochajs.org/#command-line-usage
  mocha: {
    useColors: true,
    enableTimeouts: true,
    timeout: 180000
  },

  // http://truffleframework.com/docs/advanced/configuration
  compilers: {
    solc: {
      version: "0.6.12",
      //version: "0.6.12",
      //parser: "solcjs",
      settings: {
        optimizer: {
          enabled: false,
          runs: 200
        },
        evmVersion: "constantinople"   // berlin, istanbul, petersburg, constantinople, byzantium
      }
    },
  },
};
