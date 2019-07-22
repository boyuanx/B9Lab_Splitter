pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./Stoppable.sol";

contract Splitter is Stoppable {

    using SafeMath for uint256;

    mapping (address => uint) public balances;
    event LogFundsReceivedAndStored(address indexed sender, address indexed dst1, address indexed dst2, uint incomingFunds, uint splitBalance);
    event LogFundsWithdrawn(address indexed receiver, uint amount);

    constructor(bool initialRunState) public Stoppable(initialRunState) {}

    modifier sufficientIncomingFunds {
        require(msg.value > 0, "E_IF");
        _;
    }
    
    modifier nonZeroWithdrawal(uint amount) {
        require(amount > 0, "E_ZA");
        _;
    }

    function depositAndStore(address dst1, address dst2) public payable
    addressNonZero(dst1) addressNonZero(dst2) onlyIfRunning sufficientIncomingFunds returns (bool success) {
        uint splitBalance = msg.value.div(2);
        balances[dst1] = balances[dst1].add(splitBalance);
        balances[dst2] = balances[dst2].add(splitBalance);
        emit LogFundsReceivedAndStored(msg.sender, dst1, dst2, msg.value, splitBalance);
        if (msg.value.mod(2) == 1) {
            balances[msg.sender] = balances[msg.sender].add(1);
        }
        return true;
    }

    function withdraw(uint amount) public onlyIfRunning nonZeroWithdrawal(amount) returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(amount);
        emit LogFundsWithdrawn(msg.sender, amount);
        msg.sender.transfer(amount);
        return true;
    }

}