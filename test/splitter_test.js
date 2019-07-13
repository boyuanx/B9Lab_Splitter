const Splitter = artifacts.require("Splitter");

contract("Splitter", accounts => {
    const sender = accounts[0];
    const dst1 = accounts[1];
    const dst2 = accounts[2];
    const deposit = 10000000000;
    let splitter;

    beforeEach("make a contract and despoit 10000000000 weis", async () => {
        splitter = await Splitter.new(sender);
        await splitter.depositAndStore(dst1, dst2, { from: sender, gas: 3000000, value: deposit });
    });


    it("should accept funds correctly", async () => {
        const splitterBalance = await web3.eth.getBalance(splitter.address);
        assert.equal(splitterBalance, deposit);
    });

    it("should split funds evenly between the two recepients", async () => {
        const dst1Balance = await splitter.balances.call(dst1);
        const dst2Balance = await splitter.balances.call(dst2);
        assert.equal(dst1Balance.toNumber(), dst2Balance.toNumber());
    });

    // This one somehow doesn't work.
    // dst1 never gets his funds, however all logs show that the transfer has taken place...
    it("should let the recepients withdraw their funds", async () => {
        const dst1InitialBalance = await web3.eth.getBalance(dst1);
        const dst1InitialSplitterBalance = await splitter.balances.call(dst1);
        const dst1Receipt = await splitter.withdraw(deposit/2, { from: dst1, gas: 3000000 });
        const gasUsed = dst1Receipt.receipt.gasUsed;
        const tx = await web3.eth.getTransaction(dst1Receipt.tx);
        const gasPrice = tx.gasPrice;
        const dst1FinalBalance = await web3.eth.getBalance(dst1);
        const dst1FinalSplitterBalance = await splitter.balances.call(dst1);
        const evnt = await splitter.getPastEvents("LogFundsWithdrawn", { fromBlock: 0, toBlock: "latest" });
        console.log(dst1InitialBalance);
        console.log(dst1FinalBalance);
        console.log(dst1InitialSplitterBalance);
        console.log(dst1FinalSplitterBalance);
        console.log(gasUsed);
        console.log(gasPrice);
        console.log(evnt);
    });
});