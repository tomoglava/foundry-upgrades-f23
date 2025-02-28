//SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {DeployBox} from "../script/DeployBox.s.sol";
import {UpgradeBox} from "../script/UpgradeBox.s.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";

contract DeployAndUpgradeTest is Test {
    DeployBox deployBox;
    UpgradeBox upgradeBox;
    address public OWNER = makeAddr("OWNER");
    address public proxy; //we are never changing/reseting this address

    function setUp() public {
        deployBox = new DeployBox();
        upgradeBox = new UpgradeBox();
        proxy = deployBox.run(); //at start proxy points to BoxV1
    }

    function testProxyStartsAsBoxV1() public {
        vm.expectRevert();
        BoxV2(proxy).setNumber(42);
    }

    function testUpgrades() public {
        BoxV2 boxV2 = new BoxV2();

        upgradeBox.upgradeBox(proxy, address(boxV2));

        uint256 expectedValue = 2;
        assertEq(BoxV2(proxy).version(), expectedValue);

        BoxV2(proxy).setNumber(42);
        assertEq(BoxV2(proxy).getNumber(), 42);
    }
}
