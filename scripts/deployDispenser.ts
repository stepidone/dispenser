import fs from 'fs'
import hre from 'hardhat';
import {ethers} from 'hardhat';
import {Contract} from "ethers";
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

const network = hre.network.name;

async function main() {
  let owner: SignerWithAddress;
  let dispenser: Contract;

  [owner] = await ethers.getSigners();
  console.log("Owner address: ", owner.address)
  const balance = await owner.getBalance();
  console.log(`Owner account balance: ${ethers.utils.formatEther(balance).toString()}`)

  const DispenserFactory = await ethers.getContractFactory("Dispenser");
  dispenser = await DispenserFactory.deploy(process.env.VALIDATOR_ADDRESS as string)
  await dispenser.deployed()
  console.log(`Dequest contract deployed to ${dispenser.address}`)
  fs.appendFileSync(`.env-${network}`, 
  `DEQUEST_CONTRACT_ADDRESS=${dispenser.address}\r`)
  const promise = new Promise((resolve) => {
    setTimeout(async () => {
      try {
        if (hre.network.name != 'localhost' && hre.network.name != 'hardhat') {
          await hre.run('verify:verify', {
            address: dispenser.address,
            constructorArguments: [
              process.env.VALIDATOR_ADDRESS
            ]
          });
        }
      } catch (e) {
        console.log(e);
      }
    }, 30000)
  })
  await Promise.resolve(promise)
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });