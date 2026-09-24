// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/ERC223Token.sol";
import "../src/ExampleReceiver.sol";

contract ERC223TokenTest is Test {
    ERC223Token public token;
    GoodReceiver public goodReceiver;
    BadReceiver public badReceiver;
    RejectingReceiver public rejectingReceiver;

    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether;

    function setUp() public {
        vm.prank(alice);
        token = new ERC223Token("TestToken", "TTK", 18, INITIAL_SUPPLY);
        goodReceiver = new GoodReceiver();
        badReceiver = new BadReceiver();
        rejectingReceiver = new RejectingReceiver();
    }

    function test_TransferToEOA() public {
        vm.prank(alice);
        token.transfer(bob, 100 ether);
        assertEq(token.balanceOf(bob), 100 ether);
    }

    function test_TransferToGoodReceiver() public {
        vm.prank(alice);
        token.transfer(address(goodReceiver), 50 ether);
        assertEq(token.balanceOf(address(goodReceiver)), 50 ether);
        assertEq(goodReceiver.getDeposit(alice), 50 ether);
    }

    function test_RevertWhen_TransferToBadReceiver() public {
        vm.prank(alice);
        vm.expectRevert();
        token.transfer(address(badReceiver), 10 ether);
        assertEq(token.balanceOf(alice), INITIAL_SUPPLY);
    }

    function test_RevertWhen_TransferToRejectingReceiver() public {
        vm.prank(alice);
        vm.expectRevert(bytes("RejectingReceiver: I refuse these tokens"));
        token.transfer(address(rejectingReceiver), 10 ether);
    }

    function test_RevertWhen_InsufficientBalance() public {
        vm.prank(alice);
        vm.expectRevert(bytes("ERC223: insufficient balance"));
        token.transfer(bob, INITIAL_SUPPLY + 1);
    }

    function test_RevertWhen_TransferToZeroAddress() public {
        vm.prank(alice);
        vm.expectRevert(bytes("ERC223: transfer to the zero address"));
        token.transfer(address(0), 1 ether);
    }
}
