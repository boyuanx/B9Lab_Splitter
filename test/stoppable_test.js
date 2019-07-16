const Stoppable = artifacts.require("Stoppable");

contract("Stoppable", accounts => {
    const owner = accounts[0];
    let stoppable;
    let catchRevert = require("./exceptions.js").catchRevert;

    describe("deploying as running", () => {
        beforeEach("deploy this contract as running", async () => {
            stoppable = await Stoppable.new(true, { from: owner });
        })

        it("should be running", async () => {
            assert.equal(true, await stoppable.isRunning());
        })

        it("should be able to be paused", async () => {
            const pauseReceipt = await stoppable.pauseContract({ from: owner });
            assert.equal(false, await stoppable.isRunning());
            assert.equal(pauseReceipt.logs.length, 1);
            const log = pauseReceipt.logs[0];
            assert.equal(log.event, "LogPausedContract");
            assert.equal(log.args.sender, owner);
        })

        it("should not be able to be resumed", async () => {
            await catchRevert(stoppable.resumeContract({ from: owner }), "E_NP");
        })
    })

    describe("deploying as paused", () => {
        beforeEach("deploy this contract as paused", async () => {
            stoppable = await Stoppable.new(false, { from: owner });
        })

        it("should be paused", async () => {
            assert.equal(false, await stoppable.isRunning());
        })

        it("should be able to be resumed", async () => {
            const resumedReceipt = await stoppable.resumeContract({ from: owner });
            assert.equal(true, await stoppable.isRunning());
            assert.equal(resumedReceipt.logs.length, 1);
            const log = resumedReceipt.logs[0];
            assert.equal(log.event, "LogResumedContract");
            assert.equal(log.args.sender, owner);
        })

        it("should not be able to be paused", async () => {
            await catchRevert(stoppable.pauseContract({ from: owner }), "E_NR");
        })
    })
})