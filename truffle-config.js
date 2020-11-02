
const HDWalletProvider = require('@truffle/hdwallet-provider');

const fs = require('fs');
const config = fs.readFileSync('scripts/ganache-cli.properties').toString();
const ganache = {
  host : config.match(/ethereum.host=.*/g)[0].substring(14),
  port : config.match(/ethereum.port=[0-9]*/g)[0].substring(14),
  net : config.match(/ethereum.netVersion=[0-9]*/g)[0].substring(20),
  websocket: false
}

// http://truffleframework.com/docs/advanced/configuration
module.exports = {

  networks: {
    
    development: {
      host: ganache.host,
      port: ganache.port,
      network_id: ganache.net,
      gas: 4E8,
      gasPrice: 2.5E10,
      websockets: ganache.websocket
    }
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
      version: "^0.5.0",
      // version: "^0.6.0",
      settings: {
        optimizer: {
          enabled: false,
          runs: 200
        },
        evmVersion: "petersburg"
      }
    },
  },
};
