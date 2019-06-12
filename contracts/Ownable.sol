pragma solidity ^0.5.0;

contract Ownable {

    address private owner;
    event EventOwnerChanged(address indexed sender, address indexed newOwner);

    modifier onlyOwnerAccess {
        require(
            msg.sender == owner,
            "E_NO"
        );
        _;
    }

    modifier addressNonZero(address addr) {
        require(
            addr != address(0),
            "E_IS"
        );
        _;
    }

    constructor() public addressNonZero(msg.sender) {
        owner = msg.sender;
    }

    function changeOwner(address newOwner) public addressNonZero(newOwner) onlyOwnerAccess returns(bool) {
        owner = newOwner;
        emit EventOwnerChanged(msg.sender, newOwner);
        return true;
    }

}