import Web3 from "web3";
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
            this.account = accounts[0];

            await this.loadBalance();
        } catch (error) {
            alert(error);
        }
    },

    loadBalance: async function() {
        const contractBalance = await this.web3.eth.getBalance(this.splitter.address);
        $("#contractBalance").html(contractBalance.toString(10));

        const { balances } = this.splitter.methods;
        const accountBalance = await balances(this.account).call();
        $("#accountBalance").html(accountBalance.toString(10));
    },

    split: async function() {
        const depositAmount = $("input[name='depositAmount']").val();
        const dst1 = $("input[name='dst1']").val();
        const dst2 = $("input[name='dst2']").val();
        const { depositAndStore } = this.splitter.methods;

        try {
            await depositAndStore(dst1, dst2).call({ from: this.account, value: depositAmount });
            // I have determined the root cause of this issue is some kind of bug in web3.js:
            // https://github.com/ethereum/web3.js/issues/2661
            // This is a temperary workaround which IMO isn't too bad either.
            depositAndStore(dst1, dst2).send({ from: this.account, value: depositAmount })
                .on("transactionHash", txHash => {
                    alert("Transaction pending, you can use this hash to look it up: " + txHash);
                })
                .on("confirmation", async (confNumber, receipt) => {
                    if (confNumber == 1) {
                        alert("Your deposit has been confirmed on the blockchain!")
                    }
                    await this.loadBalance();
                })
        } catch (error) {
            alert(error);
            console.log("error");
        }
    },

    withdrawFunds: async function() {
        const withdrawAmount = $("input[name='withdrawAmount']").val();
        try {
            const { withdraw } = this.splitter.methods;
            await withdraw(withdrawAmount).call({ from: this.account });
            withdraw(withdrawAmount).send({ from: this.account })
                .on("transactionHash", txHash => {
                    alert("Transaction pending, you can use this hash to look it up: " + txHash);
                })
                .on("confirmation", async (confNumber, receipt) => {
                    if (confNumber == 1) {
                        alert("Your withdrawal has been confirmed on the blockchain!")
                    }
                    await this.loadBalance();
                })
        } catch (error) {
            alert(error);
        }
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