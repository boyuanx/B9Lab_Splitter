pragma solidity ^0.5.0;

import "./Ownable.sol";

contract Stoppable is Ownable {

    bool private _isRunning;
    event LogPausedContract(address indexed sender);
    event LogResumedContract(address indexed sender);

    modifier onlyIfRunning {
        require(_isRunning, "E_NR");
        _;
    }
    
    modifier onlyIfPaused {
        require(!_isRunning, "E_NP");
        _;
    }

    constructor(bool initialRunState) public {
        _isRunning = initialRunState;
    }

    function isRunning() public view returns(bool) {
        return _isRunning;
    }

    function pauseContract() public onlyOwnerAccess onlyIfRunning returns(bool success) {
        _isRunning = false;
        emit LogPausedContract(msg.sender);
        return true;
    }

    function resumeContract() public onlyOwnerAccess onlyIfPaused returns(bool success) {
        _isRunning = true;
        emit LogResumedContract(msg.sender);
        return true;
    }

}