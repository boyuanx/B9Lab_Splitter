pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./BaseContract.sol";

contract Splitter is Stoppable {

    using SafeMath for uint256;

    mapping (address => uint) balance;
    event fundsReceived(address indexed sender, uint amount);
    event fundsSplit(address indexed sender, uint amount);
    event fundsSent(address indexed receiver, uint amount);

    constructor(bool deployAsRunning) public Stoppable(deployAsRunning) {}

    modifier addressNonZero(address dst1, address dst2) {
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

    function splitAndSend(address payable dst1, address payable dst2) public payable
    addressNonZero(dst1, dst2) sufficientIncomingFunds incomingFundsEven
    returns (bool) {
        emit fundsReceived(msg.sender, msg.value);
        balance[msg.sender] = balance[msg.sender].add(msg.value);
        uint splitBalance = balance[msg.sender].div(2);
        emit fundsSplit(msg.sender, splitBalance);
        sendFunds(dst1, splitBalance);
        sendFunds(dst2, splitBalance);
        return true;
    }

    function sendFunds(address payable dst, uint amount) private {
        dst.transfer(amount);
        emit fundsSent(dst, amount);
        balance[msg.sender] = balance[msg.sender].sub(amount);
        balance[dst] = balance[dst].add(amount);
    }

}