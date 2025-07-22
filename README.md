# Vault Design

### Purpose:
- Accept and securely store ETH from multiple users.
- Allow users to withdraw only their own ETH.
- Prevent reentrancy and incorrect balance accounting.

### Rules:
- Any user can deposit ETH.
- Deposits are tracked via `mapping(address => uint256)`.
- Users can withdraw their full balance at any time.
- The vault maintains a `totalAssets()` getter which must always equal `address(this).balance`.

### Attack Surfaces:
- Reentrancy on withdraw
- Incorrect balance updates (underflow/overflow or missed update)
- External contract behavior (selfdestructs, fallback gas griefing)

### Prevention:
- Follow checks-effects-interactions pattern
- Use `ReentrancyGuard`
- Ensure test coverage via unit, fuzz, and invariant tests
