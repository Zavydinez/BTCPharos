

## BTCPharos - Bitcoin-Backed Lending Protocol

BTCPharos is a decentralized finance (DeFi) lending protocol built on the **Stacks blockchain**, enabling over-collateralized Bitcoin-backed loans with programmable smart contracts written in **Clarity**.

Users can lock Bitcoin as collateral and receive a stablecoin or other assets as a loan, based on their collateral ratio. Liquidation mechanisms protect lenders, while interest rate enforcement and maximum durations ensure platform stability.

---

### ⚙️ Features

* **Over-Collateralized Loans:** Requires 150% initial collateral ratio.
* **Lending and Borrowing:** Peer-to-peer lending system, with borrower and lender roles.
* **Interest & Duration:** Dynamic interest accrual over fixed loan terms.
* **Liquidation Mechanics:** Liquidate loans under 125% collateral with a 10% penalty.
* **Collateral Withdrawals:** Borrowers may withdraw excess collateral safely.
* **Audit-Friendly:** Clear error messages, modular functions, and secure state transitions.

---

### 📚 Smart Contract Overview

| Element                       | Description                                    |
| ----------------------------- | ---------------------------------------------- |
| `create-loan`                 | Initiates a new loan request by borrower.      |
| `fund-loan`                   | Allows a lender to activate a pending loan.    |
| `repay-loan`                  | Allows borrower to repay principal + interest. |
| `check-and-liquidate`         | Liquidates under-collateralized loans.         |
| `withdraw-excess-collateral`  | Lets borrowers withdraw collateral safely.     |
| `get-loan` / `get-user-loans` | View individual or user-specific loans.        |
| `get-liquidation`             | View liquidation record of a loan.             |

---

### 🧠 Technical Constants

| Constant Name           | Value   | Purpose                          |
| ----------------------- | ------- | -------------------------------- |
| `COLLATERAL-RATIO`      | `u150`  | 150% collateralization required  |
| `LIQUIDATION-THRESHOLD` | `u125`  | Liquidation triggered below 125% |
| `LIQUIDATION-PENALTY`   | `u110`  | 10% penalty on liquidation       |
| `MAX-LOAN-DURATION`     | `u2880` | Max 20 days (in blocks)          |
| `MAX-INTEREST-RATE`     | `u1000` | Max 10% (per loan term)          |

---

### 📦 Data Structures

#### `loans` (Map)

Stores all loans by ID.

#### `user-loans` (Map)

Tracks up to 10 loans per user.

#### `liquidations` (Map)

Records details of liquidated loans.

---

### 🚫 Errors

| Code | Description                    |
| ---- | ------------------------------ |
| `u1` | Not authorized                 |
| `u2` | Insufficient collateral        |
| `u3` | Loan not found                 |
| `u4` | Loan already active            |
| `u5` | Invalid input                  |
| `u6` | Insufficient excess collateral |
| `u7` | Loan already liquidated        |

---

### 🔐 Security Considerations

* Only loan owners can repay or withdraw collateral.
* Lenders can’t fund their own loans.
* Safe math and capped lists ensure memory control.
* Liquidation penalties deter misuse and enforce risk coverage.

---
