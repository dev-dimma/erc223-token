// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IERC223.sol";

contract ERC223Token is IERC223 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 initialSupply) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = initialSupply;
        _balances[msg.sender] = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply, "");
    }

    function name() external view override returns (string memory) { return _name; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function decimals() external view override returns (uint8) { return _decimals; }
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function balanceOf(address _owner) external view override returns (uint256) { return _balances[_owner]; }

    function transfer(address _to, uint256 _value) external override returns (bool) {
        return _transfer(msg.sender, _to, _value, "");
    }

    function transfer(address _to, uint256 _value, bytes calldata _data) external override returns (bool) {
        return _transfer(msg.sender, _to, _value, _data);
    }

    function _transfer(address _from, address _to, uint256 _value, bytes memory _data) internal returns (bool) {
        require(_to != address(0), "ERC223: transfer to the zero address");
        require(_balances[_from] >= _value, "ERC223: insufficient balance");

        _balances[_from] -= _value;
        _balances[_to] += _value;

        if (_isContract(_to)) {
            bytes4 magic = IERC223Recipient(_to).tokenReceived(_from, _value, _data);
            require(magic == bytes4(keccak256("tokenReceived(address,uint256,bytes)")), "ERC223: invalid tokenReceived return value");
        }

        emit Transfer(_from, _to, _value, _data);
        return true;
    }

    function _isContract(address account) private view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}