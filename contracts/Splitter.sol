pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./Stoppable.sol";

contract Splitter is Stoppable {

    using SafeMath for uint256;

    mapping (address => uint) private balances;
    event LogOddFunds1WeiSentBack(address indexed sender);
    event LogFundsReceivedAndStored(address indexed sender, address indexed dst1, address indexed dst2, uint amount);
    event LogFundsWithdrawn(address indexed receiver, uint amount);

    constructor(bool initialRunState) public Stoppable(initialRunState) {}

    modifier sufficientIncomingFunds {
        require(msg.value > 0, "E_IF");
        _;
    }

    function depositAndStore(address dst1, address dst2) public payable
    addressNonZero(dst1) addressNonZero(dst2) onlyIfRunning sufficientIncomingFunds returns (bool success) {
        if (msg.value.mod(2) == 1) {
            emit LogOddFunds1WeiSentBack(msg.sender);
            msg.sender.transfer(1);
        }
        uint splitBalance = msg.value.div(2);
        balances[dst1] = balances[dst1].add(splitBalance);
        balances[dst2] = balances[dst2].add(splitBalance);
        emit LogFundsReceivedAndStored(msg.sender, dst1, dst2, splitBalance);
        return true;
    }

    function withdraw(uint amount) public onlyIfRunning returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(amount);
        emit LogFundsWithdrawn(msg.sender, amount);
        msg.sender.transfer(amount);
        return true;
    }

    function getBalance(address recipient) public view onlyIfRunning returns (uint balance) {
        return balances[recipient];
    }

}