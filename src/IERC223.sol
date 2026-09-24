// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC223 {
    function totalSupply() external view returns (uint256);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transfer(address _to, uint256 _value, bytes calldata _data) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value, bytes data);
}

interface IERC223Recipient {
    function tokenReceived(address _from, uint256 _value, bytes calldata _data) external returns (bytes4);
}
