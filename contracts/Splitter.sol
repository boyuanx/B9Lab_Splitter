pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./Stoppable.sol";

contract Splitter is Stoppable {

    using SafeMath for uint256;

    mapping (address => uint) private balance;
    event FundsWithdrawn(address indexed receiver, uint amount);
    event FundsReceivedAndStored(address indexed sender, address indexed dst1, address indexed dst2, uint amount);

    constructor(bool deployAsRunning) public Stoppable(deployAsRunning) {}

    modifier addressesNonZero(address dst1, address dst2) {
        require(
            (dst1 != address(0)) && (dst2 != address(0)),
            "E_ZA"
        );
        _;
    }

    modifier sufficientIncomingFunds {
        require(
            msg.value > 0,
            "E_IF"
        );
        _;
    }

    modifier incomingFundsEven {
        require(
            msg.value.mod(2) == 0,
            "E_FO"
        );
        _;
    }

    modifier sufficientBalanceForWithdrawal(uint requestedAmount) {
        require(
            balance[msg.sender] >= requestedAmount,
            "E_IB"
        );
        _;
    }

    function depositAndStore(address payable dst1, address payable dst2) public payable
    addressesNonZero(dst1, dst2) onlyIfRunning sufficientIncomingFunds incomingFundsEven returns (bool) {
        uint splitBalance = msg.value.div(2);
        balance[dst1] = balance[dst1].add(splitBalance);
        balance[dst2] = balance[dst2].add(splitBalance);
        emit FundsReceivedAndStored(msg.sender, dst1, dst2, splitBalance);
        return true;
    }

    function withdraw(uint amount) public onlyIfRunning sufficientBalanceForWithdrawal(amount) returns (bool) {
        balance[msg.sender] = balance[msg.sender].sub(amount);
        msg.sender.transfer(amount);
        emit FundsWithdrawn(msg.sender, amount);
        return true;
    }

    function getBalance(address addr) public view onlyIfRunning returns (uint) {
        return balance[addr];
    }

}