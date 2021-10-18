// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ownable {
    address private owner;
    event OwnershipTransfer(address indexed from, address indexed to); 
    modifier onlyowner (){
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address from, address to) external onlyowner{
        owner = to;
        emit OwnershipTransfer(from,to);
    }
    function Ownable() external {
        owner = msg.sender;
    }
}
contract ManniToken is ERC20, ownable {
    constructor() ERC20("Manni","MNI") {}
    
    function mint(address to, uint256 amount) onlyowner public returns (bool) {
        _mint(to,amount);
        return true;
    }
}