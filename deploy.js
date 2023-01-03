const walletProvider = require('@truffle/hdwallet-provider');
const Web3 = require('web3');
const { abi, evm } = require('./compile');
const secrets = require('./app-settings');

const provider = new walletProvider(secrets.accountMnemonic, secrets.infuraUrl);

const web3 = new Web3(provider);

(async () => {
    const accounts = await web3.eth.getAccounts();
    console.log('Attempting to deploy from account', accounts[0]);
    const result = await new web3.eth.Contract(abi)
        .deploy({ data: evm.bytecode.object, arguments: ['initial value'] })
        .send({ gas: '1000000', from: accounts[0] });

    console.log(`Contract deployed to: ${result.options.address}`);
    provider.engine.stop();
})();

