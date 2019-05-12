pragma solidity 0.5.8;

import "./SafeMath.sol";
import "./BaseContract.sol";

contract Splitter is BaseContract {

    using SafeMath for uint256;

    mapping (address => uint) balance;
    string destination0ErrorMsg = "Error: Destination address is 0x0!";
    string insufficientFundsErrorMsg = "Error: Insufficient funds!";
    string incomingFundsNotEvenErrorMsg = "Error: Funds cannot be split evenly!";
    event fundsReceived(address indexed sender, uint amount, string message);
    event fundsSplit(address indexed sender, uint amount, string message);
    event fundsSent(address indexed receiver, uint amount, string message);
    string fundsReceivedInfoMsg = "Info: Funds have been received by the contract.";
    string fundsSplitInfoMsg = "Info: Funds have been split evenly by the contract.";
    string fundsSentInfoMsg = "Info: Funds have been sent to the designated address.";

    modifier addressNonZero(address dst1, address dst2) {
        require(
            (dst1 != address(0)) && (dst2 != address(0)),
            destination0ErrorMsg
        );
        _;
    }

    modifier sufficientIncomingFunds {
        require(
            msg.value > 0,
            insufficientFundsErrorMsg
        );
        _;
    }

    modifier incomingFundsEven {
        require(
            msg.value.mod(2) == 0,
            incomingFundsNotEvenErrorMsg
        );
        _;
    }

    function splitAndSend(address payable dst1, address payable dst2) public payable
    addressNonZero(dst1, dst2) sufficientIncomingFunds incomingFundsEven
    returns (bool) {
        emit fundsReceived(msg.sender, msg.value, fundsReceivedInfoMsg);
        balance[msg.sender] = balance[msg.sender].add(msg.value);
        uint splitBalance = balance[msg.sender].div(2);
        emit fundsSplit(msg.sender, splitBalance, fundsSplitInfoMsg);
        sendFunds(dst1, splitBalance);
        sendFunds(dst2, splitBalance);
        return true;
    }

    function sendFunds(address payable dst, uint amount) private {
        dst.transfer(amount);
        emit fundsSent(dst, amount, fundsSentInfoMsg);
        balance[msg.sender] = balance[msg.sender].sub(amount);
        balance[dst] = balance[dst].add(amount);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

}