
## Development Environment

### Preparing

You will need [***`Node.js`***](https://nodejs.org/), ***`npm`***, [***`Truffle`***](https://github.com/trufflesuite/truffle), 
[***`Ganache CLI`***](https://github.com/trufflesuite/ganache-cli)  and optionally [***`remixd`***](https://github.com/ethereum/remixd)
 to develop this project effectively and efficiently.

You can check whether `Node.js` is installed or not using the following command.<br/>
Equal or higher than `v10` version is recommanded.

```bash
$ node --version
```

[**`Truffle`**](https://github.com/trufflesuite/truffle) is one of the powerful development baseline along with `Embark`.<br/>
You can check whether `Truffle` is installed or not using the following command.<br/>
`Truffle` is expected be installed globally 

```bash
$ npm ls -g truffle
```

If the output of the above command includes `"(empty)"`, it means `Truffle` is not yet installed globally.<br/>
Then you can install it using the following `npm` command. Version `5.1.x` is recommaned. 

```bash
$ npm install -g truffle@^5.1.0
```

[**`Ganache CLI`**](https://github.com/trufflesuite/ganache-cli) is one of the most convenient stand-alone Ethereum client
for test purpose<br/>
It is expected to be installed globally. You can check whether it is installed or not using the command beneath.<br/>
Equal or higher than `6.10` version is recommaned.

```bash
$ npm ls -g ganache-cli
```

If it is not installed yet or the installed version is too low, you can install or upgrade it using the following command(s).

```bash
$ npm uninstall -g ganache-cli    # upgrade only
$ npm install ganache-cli@latest
```

[**`remixd`**](https://github.com/ethereum/remixd) is a tool to connect loal file system with remote [**`Remix-IDE`***](https://github.com/ethereum/browser-solidity)
This module is recommanded to be installed ***locally***.
Try to find installed one at the project base directory.

```bash
dapp-codev-contract$ npm ls remixd
```

Install it if not installed yet.

```bash
dapp-codev-contract$ npm install remixd@latest
```

Finally install dependent modules specified in `package.json`, such as `web3`, `@truffle/hdwallet-provider`
`@openzeppelin/contracts`, `chance` and so on, using just `npm install`.<br/>
The command should be executed at the project base directory.

```bash
dapp-codev-contract$ npm install
...

dapp-codev-contract$ npm ls --depth 0
...
```

----

### Launching

During development, you will probably need to run `Ganache CLI`(local standalone Ethereum node), `remixd` and
remote `Remix IDE`

To launch ***`Ganache CLI`***, execute the provided script `scripts/ganache-cli-start.sh` at the project base directory.

```
dapp-codev-contract$ ./scripts/ganache-cli-start.sh 
....
```

If you have any problem to execute the above script, you can try direct command like the following.

```bash
dapp-codev-contract$ mkdir -p ./run/ganache    # fist time only
dapp-codev-contract$ ganache-cli --networkId 31 --host '127.0.0.1' --port 8545 --gasPrice 2.5E10 --gasLimit 4E8 --account="0x052fdb8f5af8f2e4ef5c935bcacf1338ad0d8abe30f45f0137943ac72f1bba1e,10000000000000000000000" --account="0x6006fc64218112913e638a2aec5bd25199178cfaf9335a83b75c0e264e7d9cee,10000000000000000000000" --account="0x724443258d598ee09e79bdbdc4af0792a69bd80082f68180157208aa6c5437de,10000000000000000000000" --account="0x00f84e1eaf2918511f4690fb396c89928bebfbe5d96cd821069ecf16e921a4ee,10000000000000000000000" --account="0x78394a06447e6688317ee920cefd3b992dee3d9ee9cb2462f22ab730723fab4a,10000000000000000000000" --account="0x4f7b71565f80821fbad1e4a3c7b8c7a28297d40d5179e4aad5c071c0370a956d,10000000000000000000000" --account="0x3410f72766f9be720638f02a0047b6cb2da3265f393d032caccdb0bd13854a58,10000000000000000000000" --account="0x964a24a416c75097cfbc3d96ba06dadd8f6c8c7503fa5e95dd738241f4f01c3d,10000000000000000000000" --unlock 0 --unlock 1 --unlock 2 --unlock 3 --unlock 4 --hardfork 'petersburg' --blockTime 0 --db ./run/ganache/data >> ./run/ganache/ganache.log 2>&1
...
```

The commandline includes predefined private keys for Ethereum accounts. The keys are also stated in `scripts/ganache-cli.properties` file.<br/>
***These private keys are definitely test purpose only. Never use these keys in production environment.***

Launch ***`remixd`*** before using remote `Remix IDE` using provided script.

```bash
dapp-codev-contract$ ./scripts/remixd-start.sh 
[WARN] You may now only use IDE at https://remix.ethereum.org to connect to that instance
[WARN] Any application that runs on your computer can potentially read from and write to all files in the directory.
[WARN] Symbolic links are not forwarded to Remix IDE

Thu Nov 05 2020 13:47:20 GMT+0900 (Korean Standard Time) Remixd is listening on 127.0.0.1:65520 
```

You can also execute `remixd` command directly like the following.<br/>
As explained above section, `remixd` module is expected to be already installed locally.
Executables of local npm modules are located `./node_modules/.bin/` directory.
 

```bash
dapp-codev-contract$ ./node_modules/.bin/remixd -s ./ --remix-ide https://remix.ethereum.org
...
```

Now you can use ***`Remix IDE`*** to edit your smart contracts located at your local filesystem.<br/>
Access `https://remix.ethereum.org` using your browser.<br/>
At first page, find and click ***`Connect to Localhost`*** link.<br/>
After another confirmation, you can find that your project base directory is appended to `File Explorers`(lef pane of Remix IDE page) and expanded.


