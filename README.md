# Dispenser

A simple contract that accepts and gives away ERC-20 tokens by the signature of the validator. Before replenishing the contract, you must approve the amount you want to spend

# Setup

Fill in the ```.env``` file following the comments left. You can customize the ```hardhat.config.ts``` file depending on the networks you want to deploy them to

# Run
```
 npm i
 npm run compile
 npx hardhat run --network <NETWORK> .\scripts\deployDispenser.ts
```
