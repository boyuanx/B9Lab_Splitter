pragma solidity ^0.5.0;

contract Ownable {

    address private owner;
    event EventOwnerChanged(address sender, address newOwner);

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
        emit EventOwnerChanged(msg.sender, newOwner);
        return true;
    }

}