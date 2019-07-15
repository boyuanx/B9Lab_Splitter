const Splitter = artifacts.require("Splitter");

contract("Splitter", accounts => {
    const [sender, dst1, dst2] = accounts;
    const deposit = web3.utils.toWei("10", "GWei");
    let splitter;
    let depositAndStoreReceipt;

    describe("normal case, even input", () => {
        beforeEach("make a contract and despoit 10000000000 weis", async () => {
            splitter = await Splitter.new(true);
            depositAndStoreReceipt = await splitter.depositAndStore(dst1, dst2, { from: sender, gas: 3000000, value: deposit });
        });
    
        it("should accept funds correctly", async () => {
            const splitterBalance = await web3.eth.getBalance(splitter.address);
            assert.equal(splitterBalance, deposit);
        });
    
        it("should split funds evenly between the two recepients", async () => {
            const dst1Balance = await splitter.balances(dst1);
            const dst2Balance = await splitter.balances(dst2);
            assert.equal(dst1Balance.toNumber(), dst2Balance.toNumber());
        });

        it("should emit the proper deposit and storage events", async () => {
            assert.equal(depositAndStoreReceipt.logs.length, 1);
            const log = depositAndStoreReceipt.logs[0];
            assert.equal(log.event, "LogFundsReceivedAndStored");
            assert.equal(log.args.sender, sender);
            assert.equal(log.args.dst1, dst1);
            assert.equal(log.args.dst2, dst2);
            assert.equal(log.args.splitBalance.toNumber(), deposit/2);
        });
    
        it("should correctly let the recepients withdraw their funds and emit the proper events", async () => {
            const dst1InitialBalance = await web3.eth.getBalance(dst1);
            const dst1InitialSplitterBalance = await splitter.balances(dst1);
            const dst1Receipt = await splitter.withdraw(deposit/2, { from: dst1, gas: 3000000 });
            const gasUsed = dst1Receipt.receipt.gasUsed;
            const tx = await web3.eth.getTransaction(dst1Receipt.tx);
            const gasPrice = tx.gasPrice;
            const dst1FinalBalance = await web3.eth.getBalance(dst1);
            const dst1FinalSplitterBalance = await splitter.balances(dst1);

            assert.equal(dst1Receipt.logs.length, 1);
            const log = dst1Receipt.logs[0];
            assert.equal(log.event, "LogFundsWithdrawn");
            assert.equal(log.args.receiver, dst1);
            assert.equal(log.args.amount.toNumber(), dst1InitialSplitterBalance);

            assert.equal(dst1InitialSplitterBalance.toNumber(), dst1FinalBalance - dst1InitialBalance + gasPrice*gasUsed);
            assert.equal(dst1FinalSplitterBalance, 0);
        });
    });

    describe("edge case, odd input", () => {
        beforeEach("make a contract and despoit 10000000001 weis", async () => {
            splitter = await Splitter.new(true);
            depositAndStoreReceipt = await splitter.depositAndStore(dst1, dst2, { from: sender, gas: 3000000, value: deposit+1 });
        });

        it("should detect the odd input and refund 1 wei to the sender", async () => {
            const senderBalance = await splitter.balances(sender);
            assert.equal(senderBalance.toNumber(), 1);
        });

        it("should emit the proper event for the refund", async () => {
            assert.equal(depositAndStoreReceipt.logs.length, 2);
            const log = depositAndStoreReceipt.logs[1];
            assert.equal(log.event, "LogOddFunds1WeiStoredForSender");
            assert.equal(log.args.sender, sender);
        });
    });


});