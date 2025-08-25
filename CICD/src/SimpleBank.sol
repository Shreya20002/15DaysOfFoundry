// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SimpleBank {
    mapping(address => uint256) public balances;
    uint256 public totalDeposits;

    function deposit() public payable {
        require(msg.value > 0, "Deposit amount should be greater than zero!");
        balances[msg.sender] += msg.value; 
        totalDeposits += msg.value;
    }


    function withdraw(uint256 _amount) public {
        require(_amount > 0, "Must withdraw something");
        require(balances[msg.sender] >= _amount, "Not enough balance!");

        balances[msg.sender] -= _amount;
        totalDeposits -= _amount;

        (bool success,) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");
    }

    function getBalance(address _user) public view returns (uint256) {
        return balances[_user];
    }
}