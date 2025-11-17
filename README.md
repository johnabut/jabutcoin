# Jabutcoin

Jabutcoin is a fungible token smart contract built for the Stacks blockchain using the [Clarinet](https://github.com/hirosystems/clarinet) development environment.

This repository contains:

- A Clarinet project configuration (`Clarinet.toml`)
- The main Jabutcoin token contract (`contracts/jabutcoin.clar`)
- This README with setup and usage instructions

## Prerequisites

- Linux or macOS
- Git
- A recent version of `bash`
- Curl and OpenSSL (for installing Clarinet), or another supported installation method

## Installing Clarinet

> Note: Automated installation from this environment encountered TLS/SSL issues. You may need to install Clarinet manually following the official instructions below on your machine.

1. Visit the Clarinet repository: <https://github.com/hirosystems/clarinet>
2. Follow the installation instructions for your platform (they may involve downloading a prebuilt binary or running an installer script).
3. Confirm installation:

   ```bash path=null start=null
   clarinet --version
   ```

   You should see a version string like `clarinet 2.x.x`.

Ensure that `clarinet` is available on your `PATH` when running in this project directory.

## Project structure

- `Clarinet.toml` – Clarinet project configuration defining the `jabutcoin` contract
- `contracts/jabutcoin.clar` – Jabutcoin fungible token smart contract (Clarity)
- `LICENSE` – Project license

## Smart contract overview

The `jabutcoin.clar` contract implements a simple fungible token with the following characteristics:

- **Name:** `Jabutcoin`
- **Symbol:** `JAB`
- **Decimals:** `6`
- **State:**
  - `contract-owner` – the deploying principal, stored in a data-var
  - `total-supply` – total number of minted tokens
  - `balances` – map from `principal` → `balance` (uint)

### Read-only functions

- `get-name` → `(response (string-ascii 32) uint)` – returns the token name
- `get-symbol` → `(response (string-ascii 32) uint)` – returns the token symbol
- `get-decimals` → `(response uint uint)` – returns the decimals
- `get-total-supply` → `(response uint uint)` – returns the total supply
- `get-balance (owner principal)` → `(response uint uint)` – returns the balance of `owner`
- `get-owner` → `(response principal uint)` – returns the current contract owner

### Public functions

- `transfer (amount uint) (sender principal) (recipient principal)`
  - Moves `amount` tokens from `sender` to `recipient`
  - Requires `sender` to be equal to `tx-sender`
  - Fails with error `u101` if the sender does not have enough balance

- `mint (amount uint) (recipient principal)`
  - Mints `amount` new tokens to `recipient`
  - Only callable by `contract-owner`
  - Increases `total-supply` by `amount`

- `burn (amount uint)`
  - Burns `amount` tokens from `tx-sender`'s balance
  - Decreases `total-supply` by `amount`
  - Fails with error `u101` if the caller does not have enough balance

### Error codes

- `u100` – Not authorized (e.g., mint called by non-owner, transfer not initiated by sender)
- `u101` – Insufficient balance

## Using this project with Clarinet

Once Clarinet is installed and available on your `PATH`:

1. Navigate to the project directory:

   ```bash path=null start=null
   cd /home/anthony/Documents/GitHub/jabutcoin
   ```

2. Run Clarinet's static analysis to verify the contract:

   ```bash path=null start=null
   clarinet check
   ```

   This command will parse the project configuration from `Clarinet.toml` and analyze `contracts/jabutcoin.clar`.

3. (Optional) Open the Clarinet console for interactive testing (if supported by your Clarinet version):

   ```bash path=null start=null
   clarinet console
   ```

   From the console you can call contract functions, such as:

   ```clarity path=null start=null
   (contract-call? .jabutcoin get-total-supply)
   (contract-call? .jabutcoin mint u1000 'ST3...OWNER)
   (contract-call? .jabutcoin transfer u100 'ST3...OWNER 'ST3...RECIPIENT)
   ```

   Replace `ST3...OWNER` and `ST3...RECIPIENT` with real Stacks principals for local testing.

## Running `clarinet check`

Once Clarinet is properly installed, run:

```bash path=null start=null
cd /home/anthony/Documents/GitHub/jabutcoin
clarinet check
```

If everything is set up correctly, Clarinet should report that the `jabutcoin` contract parses and analyzes successfully.

## Next steps

- Add tests using Clarinet's testing tools (e.g., JavaScript/TypeScript tests or Clarinet console scripts)
- Extend the contract to fully conform to the SIP-010 fungible token standard (including traits and additional read-only functions)
- Integrate Jabutcoin into your broader application or protocol on Stacks
