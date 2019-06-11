pragma solidity ^0.5.0;

contract Ownable {

    address owner;
    event eventOwnerChanged(address sender, address newOwner);

    modifier onlyOwnerAccess {
        require(
            msg.sender == owner,
            "E_NO"
        );
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function changeOwner(address newOwner) public onlyOwnerAccess returns(bool) {
        owner = newOwner;
        emit eventOwnerChanged(msg.sender, newOwner);
        return true;
    }

}

contract Stoppable is Ownable {

    bool isRunning;
    event eventPausedContract(address sender);
    event eventResumedContract(address sender);

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
        emit eventPausedContract(msg.sender);
        return true;
    }

    function resumeContract() public onlyOwnerAccess onlyIfPaused returns(bool) {
        isRunning = true;
        emit eventResumedContract(msg.sender);
        return true;
    }

}