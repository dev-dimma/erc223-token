// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IERC223.sol";

contract GoodReceiver is IERC223Recipient {
    mapping(address => uint256) public deposits;
    event TokensReceived(address indexed from, uint256 value, bytes data);

    function tokenReceived(address _from, uint256 _value, bytes calldata _data) external override returns (bytes4) {
        deposits[_from] += _value;
        emit TokensReceived(_from, _value, _data);
        return bytes4(keccak256("tokenReceived(address,uint256,bytes)"));
    }

    function getDeposit(address user) external view returns (uint256) {
        return deposits[user];
    }
}

contract BadReceiver {
    uint256 public dummy;

    function doSomething() external {
        dummy = 1;
    }
}

contract RejectingReceiver is IERC223Recipient {
    function tokenReceived(address, uint256, bytes calldata) external pure override returns (bytes4) {
        revert("RejectingReceiver: I refuse these tokens");
    }
}
