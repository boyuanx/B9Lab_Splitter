const Splitter = artifacts.require("Splitter");

contract("Splitter", accounts => {
    const sender = accounts[0];
    const dst1 = accounts[1];
    const dst2 = accounts[2];

    it("should split input evenly", async () => {
        const contract = await Splitter.deployed();
        await contract.splitAndSend(dst1, dst2, {value: 100000});
    });
});