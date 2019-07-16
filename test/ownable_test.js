const Ownable = artifacts.require("Ownable");

contract("Ownable", accounts => {
    const [owner0, owner1] = accounts;
    let ownable;
    let catchRevert = require("./exceptions.js").catchRevert;

    describe("smoke tests", () => {
        beforeEach("deploy this contract as owner0", async () => {
            ownable = await Ownable.new({ from: owner0 });
        });

        it("should return the correct owner", async () => {
            const returnedOwner = await ownable.getOwner();
            assert.equal(returnedOwner, owner0);
        });

        it("should change the owner from 0 to 1 and emit the correct events", async () => {
            const changeOwnerReceipt = await ownable.changeOwner(owner1, { from: owner0 });
            assert.equal(changeOwnerReceipt.logs.length, 1);
            const log = changeOwnerReceipt.logs[0];
            assert.equal(log.event, "LogOwnerChanged");
            assert.equal(log.args.sender, owner0);
            assert.equal(log.args.newOwner, owner1);
            const newOwner = await ownable.getOwner();
            assert.equal(newOwner, owner1);
        });

        it("should disallow ownership change from non-owner", async () => {
            await catchRevert(ownable.changeOwner(owner1, { from: owner1 }), "E_NO");
        });

        it ("should disallow changing owner to 0x0", async () => {
            // Fails, gives 'invalid address (arg="newOwner", coderType="address", value="0x0")'
            // Not too sure how to pass in address(0)...
            await catchRevert(ownable.changeOwner(0, { from: owner0 }), "E_IS");
        });
    })
})