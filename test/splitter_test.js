const Splitter = artifacts.require("Splitter");

contract("Splitter", accounts => {
    const { BN, toWei } = web3.utils;
    const [sender, dst1, dst2] = accounts;
    const deposit = toWei("10", "GWei");
    let splitter;
    let depositAndStoreReceipt;

    describe("normal case, even input", () => {
        beforeEach("make a contract and deposit 10000000000 weis", async () => {
            splitter = await Splitter.new(true, { from: sender });
            depositAndStoreReceipt = await splitter.depositAndStore(dst1, dst2, { from: sender, gas: 3000000, value: deposit });
        });
    
        it("should accept funds correctly", async () => {
            const splitterBalance = await web3.eth.getBalance(splitter.address);
            assert.strictEqual(splitterBalance, deposit);
        });
    
        it("should split funds evenly between the two recepients", async () => {
            const dst1Balance = await splitter.balances(dst1);
            const dst2Balance = await splitter.balances(dst2);
            assert.notEqual(dst1Balance.toString(10), 0);
            assert.strictEqual(dst1Balance.toString(10), dst2Balance.toString(10));
        });

        it("should emit the proper deposit and storage events", async () => {
            assert.strictEqual(depositAndStoreReceipt.logs.length, 1);
            const log = depositAndStoreReceipt.logs[0];
            assert.strictEqual(log.event, "LogFundsReceivedAndStored");
            assert.strictEqual(log.args.sender, sender);
            assert.strictEqual(log.args.dst1, dst1);
            assert.strictEqual(log.args.dst2, dst2);
            assert.strictEqual(log.args.incomingFunds.toString(10), deposit.toString(10));
            assert.strictEqual(log.args.splitBalance.toString(10), (deposit/2).toString(10));
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

            assert.strictEqual(dst1Receipt.logs.length, 1);
            const log = dst1Receipt.logs[0];
            assert.strictEqual(log.event, "LogFundsWithdrawn");
            assert.strictEqual(log.args.receiver, dst1);
            assert.strictEqual(log.args.amount.toString(10), dst1InitialSplitterBalance.toString(10));

            assert.strictEqual(dst1FinalBalance, (new BN(dst1InitialBalance).add(new BN(dst1InitialSplitterBalance)).sub(new BN(gasPrice*gasUsed))).toString(10));
            assert.strictEqual(dst1FinalSplitterBalance.toString(10), (0).toString(10));
        });
    });

    describe("edge case, odd input", () => {
        beforeEach("make a contract and despoit 10000000001 weis", async () => {
            splitter = await Splitter.new(true, { from: sender });
            depositAndStoreReceipt = await splitter.depositAndStore(dst1, dst2, { from: sender, gas: 3000000, value: deposit+1 });
        });

        it("should detect the odd input and refund 1 wei to the sender", async () => {
            const senderBalance = await splitter.balances(sender);
            assert.strictEqual(senderBalance.toString(10), (1).toString(10));
        });
    });


});