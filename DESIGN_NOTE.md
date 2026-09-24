# Design Note: ERC-223 Token Implementation (Scoped)

**Spec:** [EIP-223](https://eips.ethereum.org/EIPS/eip-223)

---

## 1. Which ERC and Which Scope Was Implemented

I implemented **Option D: ERC-223 Token Standard**.

**In-scope requirements:**

- A token where `transfer` to a **contract address** requires that contract to implement a receiver hook (`tokenReceived`).
- The transfer **reverts** if the hook is missing or rejects the transfer.
- `transfer` to a regular wallet (EOA – no code) works normally.
- A simple example “receiver” contract that correctly implements the hook.
- A second example contract that deliberately does **not** implement the hook (to demonstrate the revert).
- Explanation of the real ERC-20 failure mode this design prevents, with a concrete example.

I did **not** implement the full optional surface (approve/transferFrom, payable ether-with-tokens, etc.). Only the core transfer + receiver safety mechanism required by the scoped task.

---

## 2. Mapping of Functions to Exact Spec Sections

| Function / Event | Spec location | Notes |
|------------------|---------------|-------|
| `totalSupply()`, `name()`, `symbol()`, `decimals()`, `balanceOf()` | EIP-223 § “Token Methods” | Identical semantics to ERC-20. |
| `transfer(address _to, uint256 _value)` | EIP-223 § `transfer(address, uint)` | Must call `tokenReceived` on contract recipients. |
| `transfer(address _to, uint256 _value, bytes calldata _data)` | EIP-223 § `transfer(address, uint, bytes)` | Same logic + optional data payload. |
| `event Transfer(address, address, uint256, bytes)` | EIP-223 § Events | Extended ERC-20-compatible Transfer. |
| `tokenReceived(address, uint256, bytes) → bytes4` | EIP-223 § “ERC-223 Token Receiver” | Magic return value `0x8943ec02`. |
| Contract detection via `extcodesize` | EIP-223 reference implementation | Standard way to distinguish EOA vs contract. |

---

## 3. The ERC-20 Failure Mode This Design Prevents

### The problem

With classic **ERC-20**, the `transfer(to, value)` function simply:

1. Debits the sender’s balance.
2. Credits the recipient’s balance.
3. Emits a `Transfer` event.

It **never** notifies the recipient.  

If a user calls `token.transfer(someContract, amount)` and `someContract` was never written to accept that token, the tokens sit in the contract forever with no way to recover them.

**Concrete example:**

```solidity
// User wants to deposit into a staking contract that only supports approve + transferFrom.
// User mistakenly does:
TokenA.transfer(stakingContract, 1000e18);

// Result:
// - User’s balance decreases
// - stakingContract’s balance increases
// - stakingContract has no idea it received anything
// - Tokens are permanently stuck