pragma solidity ^0.5.0;

import "./Ownable.sol";

contract Stoppable is Ownable {

    bool isRunning;
    event EventPausedContract(address sender);
    event EventResumedContract(address sender);

    modifier onlyIfRunning {
        require(
            isRunning,
            "E_NR"
        );
        _;
    }
    
    modifier onlyIfPaused {
        require(
            !isRunning,
            "E_NP"
        );
        _;
    }

    constructor(bool deployAsRunning) public {
        isRunning = deployAsRunning;
    }

    function pauseContract() public onlyOwnerAccess onlyIfRunning returns(bool) {
        isRunning = false;
        emit EventPausedContract(msg.sender);
        return true;
    }

    function resumeContract() public onlyOwnerAccess onlyIfPaused returns(bool) {
        isRunning = true;
        emit EventResumedContract(msg.sender);
        return true;
    }

}