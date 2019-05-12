pragma solidity ^0.5.3;

contract Ownable {

    address public owner;
    event eventOwnerChanged(address sender, address newOwner);
    string notOwnerErrorMsg = "Unauthorized: You are not the owner!";

    modifier onlyOwnerAccess {
        require(
            msg.sender == owner,
            notOwnerErrorMsg
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
    string notRunningErrorMsg = "Error: This contract is currently not running!";
    string notPausedErrorMsg = "Error: This contract is currently not paused!";

    modifier onlyIfRunning {
        require(
            isRunning,
            notRunningErrorMsg
        );
        _;
    }
    
    modifier onlyIfPaused {
        require(
            !isRunning,
            notPausedErrorMsg
        );
        _;
    }

    constructor() public {
        isRunning = true;
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

contract BaseContract is Stoppable {

    bool isAlive;
    address owner;
    /*
        The logs for events will have something like this:
        {
            ...
            "event": "eventAliveStateChanged"
            "args": [
                "0x......." (sender's address),
                "false" (or whatever we set in setIsAlive(bool))
            ]
        }

        The "indexed" keyword makes it searchable using the indexed parameters as filters.
    */
    event eventAliveStateChanged(address indexed sender, bool newState);

    constructor() public {
        isAlive = true;
        isRunning = true;
        owner = msg.sender;
    }

    function getAlive() public view returns(bool) {
        return isAlive;
    }

    function setIsAlive(bool state) public onlyOwnerAccess onlyIfRunning returns(bool) {
        isAlive = state;
        emit eventAliveStateChanged(msg.sender, state);
        return true;
    }

}