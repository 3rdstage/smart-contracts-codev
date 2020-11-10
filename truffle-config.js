
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
  timeout: 30000, // ms
  headers: [
    { 
      name: 'Authorization', 
      value: 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJwZXJtaXNzaW9ucyI6WyJuZXQ6KiIsImV0aDoqIiwiZGVidWc6KiIsInR4cG9vbDoqIiwiZWVhOioiXSwiZXhwIjoxNjA3MTQ4MjQ3LCJ0ZWFtIjoiMTAifQ.HJq54uc0QZeoRdzQf-fNT9LsvzgVwFUlXVc1fF1DPh4ktQ6DVNJPYAcSfOeD3K_350LcvnP73xqNGi-6OpM88m6a8O0eDkLrIqYRNVTixB1KbkX4Ka2DGDqy7VK5utLL2s0DcMKW57ONVV_YnjfxYCR76qUwjCl7amEG-y4QCpRfbC_KKhza7g7Byx0OC1vS2TRScSm3t7svXX7cbq54ndHiwKfMHPjddTwyFmcwm6jfillR___aNDo0tpkh0RQ5-C5qSba7Vf0mOmlFLzectSd5eQlK0fAIj5ouC5p2S4FUF7nnuntv140X3sBUvQBLMxvEnK7TC7opnBKKSuQBXg'
     }
  ]
};

// http://truffleframework.com/docs/advanced/configuration
module.exports = {

  networks: {
    
    development: {
      host: ganache.host,
      port: ganache.port,
      network_id: ganache.net,
      gas: 4E7,
      gasPrice: 2E10,
      websockets: ganache.websocket
    },
    
    chainztest: {
      // https://github.com/trufflesuite/truffle-hdwallet-provider#private-keys
      // https://github.com/trufflesuite/truffle/issues/1022
      provider: () => new HDWalletProvider(testKeys, "https://besutest.chainz.network/", 0, testKeys.length),
      network_id: '2020',
      gas: 1E7,
      gasPrice: 0
    },

    chainzprod: {
      
      // https://github.com/trufflesuite/truffle-hdwallet-provider#private-keys
      // https://github.com/trufflesuite/truffle/issues/1022
      provider: () => new HDWalletProvider(testKeys, new Web3HttpProvider("https://besu.chainz.network/", prodHttpOptions), 0, testKeys.length),
      network_id: '*',
      gas: 1E7,
      gasPrice: 0
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
      version: "^0.6.0",
      // version: "^0.6.0",
      //parser: "solcjs",
      settings: {
        optimizer: {
          enabled: false,
          runs: 200
        },
        //evmVersion: "petersburg"
      }
    },
  },
};
