import { ethers } from "hardhat";
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import {ReserveConfigurator} from "../typechain-types";
import {BigNumberish} from "ethers/lib/ethers";

async function main() {

    const errorsFactory = await ethers.getContractFactory("Errors");
    const errors = await errorsFactory.deploy();
    await errors.deployed();
    console.log("errors deployed to:", errors.address);

    const reserveConfiguratorFactory = await ethers.getContractFactory(
        "ReserveConfigurator",
        {
            libraries: {
                Errors: errors.address
            }
        }
    );
    const reserveConfigurator = await reserveConfiguratorFactory.deploy();
    await reserveConfigurator.deployed();

    console.log("reserveConfigurator deployed to:", reserveConfigurator.address);

    await doConfigs(reserveConfigurator);
}

async function doConfigs(reserveConfigurator: ReserveConfigurator) {
    let config: BigNumberish = 0;
    config = await reserveConfigurator.setActive(config, true);
    config = await reserveConfigurator.setFrozen(config, false);
    config = await reserveConfigurator.setLiquidationThreshold(config, 6500);
    config = await reserveConfigurator.setLtv(config, 5000);
    config = await reserveConfigurator.setReserveFactor(config, 0);
    config = await reserveConfigurator.setTokenType(config, 2 as BigNumberish);
    console.log("new configs ", config);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
