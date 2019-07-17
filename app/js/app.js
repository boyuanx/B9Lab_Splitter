import Web3 from "web3";
import truffleContract from "truffle-contract";
import $ from "jquery";
import splitterJson from "../../build/contracts/Splitter.json";
import "file-loader?name=../index.html!../index.html";

const App = {
    web3: null,
    account: null,
    splitter: null,

    start: async function() {
        const { web3 } = this;

        try {
            const networkId = await web3.eth.getId();
            const deployedNetwork = splitterJson.networks[networkId];
            this.splitter = new web3.eth.Contract(
                splitterJson.abi,
                deployedNetwork.address
            );

            const accounts = await web3.eth.getAccounts();
            this.account = accounts[2];

            this.loadBalance();
        } catch (error) {
            console.log(error);
        }
    },

    loadBalance: async function() {
        const contractBalance = await this.web3.eth.getBalance(this.splitter.address);
        $("#contractBalance").html(contractBalance.toString());

        const { balances } = this.splitter.methods;
        const accountBalance = await balances(this.account).call();
        $("#accountBalance").html(accountBalance.toString());
    },

    split: async function() {
        const depositAmount = $("input[name='depositAmount']").val();
        const dst1 = $("input[name='dst1']").val();
        const dst2 = $("input[name='dst2']").val();
        
        const { depositAndStore } = this.splitter.methods;
        await depositAndStore(dst1, dst2).send({ from: this.account, value: depositAmount })

        this.loadBalance();
    },

    withdrawFunds: async function() {
        const withdrawAmount = $("input[name='withdrawAmount']").val();
        
        const { withdraw } = this.splitter.methods;
        await withdraw(withdrawAmount).send({ from: this.account });

        this.loadBalance();
    }

}

window.App = App;

window.addEventListener('load', function() {
    if (window.ethereum) {
        // Use the Mist/wallet/Metamask provider.
        App.web3 = new Web3(currentProvider);
        window.ethereum.enable();
    } else {
        console.warn(
            "No web3 detected. Falling back to http://127.0.0.1:8545.",
          );
        App.web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545')); 
    }
    App.start();
});