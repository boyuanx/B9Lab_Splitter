pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./BaseContract.sol";

contract Splitter is Stoppable {

    using SafeMath for uint256;

    event FundsReceived(address indexed sender, uint amount);
    event FundsSplit(address indexed sender, uint amount);
    event FundsSent(address indexed receiver, uint amount);

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
    addressNonZero(dst1, dst2) sufficientIncomingFunds incomingFundsEven onlyIfRunning
    returns (bool) {
        emit FundsReceived(msg.sender, msg.value);
        uint splitBalance = msg.value.div(2);
        emit FundsSplit(msg.sender, splitBalance);
        sendFunds(dst1, splitBalance);
        sendFunds(dst2, splitBalance);
        return true;
    }

    function sendFunds(address payable dst, uint amount) private {
        dst.transfer(amount);
        emit FundsSent(dst, amount);
    }

}