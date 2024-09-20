// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../script/DeploySignUtils.sol";
import "../src/SignUtils.sol";
import "../test/Helper/TestHelper.t.sol";
import "../test/mocks/MockERC20.sol";

contract SignUtilsTest is Test, TestHelper {
    SignUtils signUtils;
    MockERC20 mockERC20;

    address tester;

    function setUp() public {
        DeploySignUtils deploySignUtils = new DeploySignUtils();
        signUtils = deploySignUtils.run();

        mockERC20 = new MockERC20();

        tester = makeAddr("tester");
    }

    function testHashData() public {
        SignUtils.Permit2SignatureTransferData
            memory signatureTransferData = createSignatureTransferData(
                mockERC20,
                address(signUtils),
                tester
            );
        vm.startPrank(tester);
        signUtils._hash(signatureTransferData.permit);
        vm.stopPrank();
    }

    function testTypeHashData() public {
        SignUtils.Permit2SignatureTransferData
            memory signatureTransferData = createSignatureTransferData(
                mockERC20,
                address(signUtils),
                tester
            );
        vm.startPrank(tester);
        signUtils._hashTypedData(signatureTransferData.permit);
        vm.stopPrank();
    }

    function testHash() public {
        SignUtils.Permit2SignatureTransferDetails
            memory signatureTransferData = createSignatureTransferDetails(
                mockERC20,
                address(signUtils),
                tester
            );
        vm.startPrank(tester);
        signUtils._hash(signatureTransferData.permit);
        vm.stopPrank();
    }

    function testTypeHashDetails() public {
        SignUtils.Permit2SignatureTransferDetails
            memory signatureTransferData = createSignatureTransferDetails(
                mockERC20,
                address(signUtils),
                tester
            );
        vm.startPrank(tester);
        signUtils._hashBatchTypedData(signatureTransferData.permit);
        vm.stopPrank();
    }

    function testConstructSig() public {
        SignUtils.Permit2SignatureTransferDetails
            memory signatureTransferData = createSignatureTransferDetails(
                mockERC20,
                address(signUtils),
                tester
            );
        vm.startPrank(tester);
        signUtils.constructSig(signatureTransferData.permit, PRIVATE_KEY);
        vm.stopPrank();
    }
}
