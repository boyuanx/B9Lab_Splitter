pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./Stoppable.sol";

contract Splitter is Stoppable {

    using SafeMath for uint256;

    mapping (address => uint) private balances;
    event LogFundsReceivedAndStored(address indexed sender, address indexed dst1, address indexed dst2, uint amount);
    event LogFundsWithdrawn(address indexed receiver, uint amount);

    constructor(bool initialRunState) public Stoppable(initialRunState) {}

    modifier addressesNonZero(address dst1, address dst2) {
        require((dst1 != address(0)) && (dst2 != address(0)), "E_ZA");
        _;
    }

    modifier sufficientIncomingFunds {
        require(msg.value > 0, "E_IF");
        _;
    }

    modifier incomingFundsEven {
        require(msg.value.mod(2) == 0, "E_FO");
        _;
    }

    modifier sufficientBalanceForWithdrawal(uint requestedAmount) {
        require(balances[msg.sender] >= requestedAmount, "E_IB");
        _;
    }

    function depositAndStore(address payable dst1, address payable dst2) public payable
    addressesNonZero(dst1, dst2) onlyIfRunning sufficientIncomingFunds incomingFundsEven returns (bool) {
        uint splitBalance = msg.value.div(2);
        balances[dst1] = balances[dst1].add(splitBalance);
        balances[dst2] = balances[dst2].add(splitBalance);
        emit LogFundsReceivedAndStored(msg.sender, dst1, dst2, splitBalance);
        return true;
    }

    function withdraw(uint amount) public onlyIfRunning sufficientBalanceForWithdrawal(amount) returns (bool) {
        uint currentBalance = balances[msg.sender];
        require(currentBalance >= amount, "E_IB");
        balances[msg.sender] = currentBalance.sub(amount);
        msg.sender.transfer(amount);
        emit LogFundsWithdrawn(msg.sender, amount);
        return true;
    }

    function getBalance(address addr) public view onlyIfRunning returns (uint) {
        return balances[addr];
    }

}