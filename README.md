# ChronoVote: Dynamic Time-Weighted Governance System

ChronoVote is a decentralized governance system where voting power is dynamically weighted based on the duration of token ownership. This system ensures that long-term token holders have a greater influence on governance decisions, promoting stability and commitment within the community.

---

## Features

- **Time-Weighted Voting Power**: Voting power scales with the duration of token holding, rewarding long-term stakeholders.
- **Proposal Creation**: Users can create governance proposals if they meet the minimum token threshold.
- **Voting**: Token holders can vote on proposals with their time-weighted voting power.
- **Proposal Execution**: Proposals are executed automatically if they meet quorum and pass the vote.
- **Token Staking and Unstaking**: Users can stake and unstake tokens to participate in governance.

---

## Smart Contract Overview

The ChronoVote smart contract is written in Clarity, a decidable language for smart contracts on the Stacks blockchain. Below is a high-level overview of the contract's functionality:

### Key Components

1. **Governance Token Interface**:
   - Defines the interface for interacting with the governance token contract.
   - Includes functions for transferring tokens and checking balances.

2. **Proposal Management**:
   - Users can create proposals with a title and description.
   - Proposals have a defined voting period and quorum requirement.

3. **Voting Mechanism**:
   - Voting power is calculated based on the amount of tokens held and the duration of ownership.
   - Users can vote "for" or "against" proposals.

4. **Proposal Execution**:
   - Proposals are automatically executed if they meet the quorum and pass the vote.

5. **Token Staking**:
   - Users can stake tokens to participate in governance.
   - Staked tokens are locked until unstaked.

---

## Contract Functions

### Public Functions

- **`set-token-contract`**: Sets the governance token contract address (admin-only).
- **`stake-tokens`**: Allows users to stake tokens to participate in governance.
- **`unstake-tokens`**: Allows users to unstake their tokens.
- **`submit-proposal`**: Creates a new governance proposal.
- **`cast-vote`**: Allows users to vote on a proposal.
- **`finalize-proposal`**: Executes a proposal if it meets the quorum and passes the vote.

### Private Functions

- **`compute-voting-power`**: Calculates the voting power of a user based on their staked tokens and holding duration.
- **`validate-proposal`**: Validates whether a proposal can be executed.

---

## Constants

- **`VOTING_DURATION`**: The duration of the voting period in blocks (~24 hours).
- **`MIN_PROPOSAL_TOKENS`**: The minimum number of tokens required to create a proposal.
- **`BASE_POWER_MULTIPLIER`**: The base multiplier for voting power calculations.
- **`MAX_TIME_BONUS`**: The maximum voting power bonus for long-term token holders.
- **`QUORUM_REQUIREMENT`**: The minimum total votes required for a proposal to pass.

---

## Error Codes

- **`ERROR_UNAUTHORIZED`**: Unauthorized action.
- **`ERROR_INVALID_PROPOSAL`**: Invalid proposal ID.
- **`ERROR_PROPOSAL_ACTIVE`**: Proposal is still active.
- **`ERROR_PROPOSAL_ENDED`**: Proposal voting period has ended.
- **`ERROR_ALREADY_VOTED`**: User has already voted on the proposal.
- **`ERROR_INSUFFICIENT_TOKENS`**: Insufficient tokens to perform the action.
- **`ERROR_TOKEN_NOT_SET`**: Governance token contract address not set.
- **`ERROR_PROPOSAL_NOT_ENDED`**: Proposal voting period has not ended.
- **`ERROR_QUORUM_NOT_MET`**: Quorum requirement not met.
- **`ERROR_PROPOSAL_ALREADY_EXECUTED`**: Proposal has already been executed.
- **`ERROR_NO_VOTE_TO_CANCEL`**: No vote to cancel.
- **`ERROR_WITHDRAWAL_EXCEEDS_BALANCE`**: Withdrawal amount exceeds staked balance.

---

## Getting Started

### Prerequisites

- A Stacks-compatible wallet (e.g., Hiro Wallet).
- Access to a Stacks blockchain node or testnet.

### Deployment

1. Compile the Clarity smart contract using the [Clarity Tools](https://docs.stacks.co/docs/clarity-tools).
2. Deploy the contract to the Stacks blockchain using the [Stacks CLI](https://docs.stacks.co/docs/stacks-cli) or a deployment tool like Hiro.
3. Set the governance token contract address using the `set-token-contract` function.

### Usage

1. Stake tokens using the `stake-tokens` function.
2. Create a proposal using the `submit-proposal` function.
3. Vote on proposals using the `cast-vote` function.
4. Execute proposals using the `finalize-proposal` function.

---

## Example Workflow

1. **Stake Tokens**:
   ```clarity
   (stake-tokens governance-token-interface u100000000)
   ```

2. **Create Proposal**:
   ```clarity
   (submit-proposal "Upgrade Protocol" "Proposal to upgrade the protocol to version 2.0")
   ```

3. **Vote on Proposal**:
   ```clarity
   (cast-vote u1 true) ;; Vote "for" proposal with ID 1
   ```

4. **Finalize Proposal**:
   ```clarity
   (finalize-proposal u1)
   ```

---

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Submit a pull request with a detailed description of your changes.


---

## Acknowledgments

- Inspired by time-weighted governance systems like Curve's veCRV.
- Built using the Stacks blockchain and Clarity smart contract language.

---


**ChronoVote** – Empowering long-term stakeholders in decentralized governance.