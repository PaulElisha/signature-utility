// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin/token/ERC20/IERC20.sol";
import "../../src/SignUtils.sol";

abstract contract TestHelper {
    uint256 public constant PRIVATE_KEY =
        0xe95e23bb89eadd0e4d715cca0540499d37c93ea745e307f985d00f72687bdffe;

    function createSignatureTransferDetails(
        IERC20 token,
        address to,
        address user
    ) public view returns (SignUtils.Permit2SignatureTransferDetails memory) {
        uint256 bal = token.balanceOf(user);

        ISignatureTransfer.TokenPermissions
            memory permittedTokens = ISignatureTransfer.TokenPermissions({
                token: address(token),
                amount: bal
            });

        ISignatureTransfer.PermitBatchTransferFrom
            memory permit = ISignatureTransfer.PermitBatchTransferFrom({
                permitted: new ISignatureTransfer.TokenPermissions[](1),
                nonce: 0,
                deadline: block.timestamp + 100
            });

        permit.permitted[0] = permittedTokens;

        ISignatureTransfer.SignatureTransferDetails
            memory transferDetail = ISignatureTransfer
                .SignatureTransferDetails({to: to, requestedAmount: bal});

        ISignatureTransfer.SignatureTransferDetails[]
            memory transferDetails = new ISignatureTransfer.SignatureTransferDetails[](
                1
            );

        transferDetails[0] = transferDetail;

        SignUtils.Permit2SignatureTransferDetails
            memory signatureTransferData = SignUtils
                .Permit2SignatureTransferDetails({
                    permit: permit,
                    transferDetails: transferDetails
                });

        return signatureTransferData;
    }

    function createSignatureTransferData(
        IERC20 token,
        address to,
        address user
    ) public view returns (SignUtils.Permit2SignatureTransferData memory) {
        uint256 bal = token.balanceOf(user);

        ISignatureTransfer.TokenPermissions
            memory permittedTokens = ISignatureTransfer.TokenPermissions({
                token: address(token),
                amount: bal
            });

        ISignatureTransfer.PermitTransferFrom memory permit = ISignatureTransfer
            .PermitTransferFrom({
                permitted: permittedTokens,
                nonce: 0,
                deadline: block.timestamp + 100
            });

        ISignatureTransfer.SignatureTransferDetails
            memory transferDetail = ISignatureTransfer
                .SignatureTransferDetails({to: to, requestedAmount: bal});

        SignUtils.Permit2SignatureTransferData
            memory signatureTransferData = SignUtils
                .Permit2SignatureTransferData({
                    permit: permit,
                    transferDetails: transferDetail
                });

        return signatureTransferData;
    }
}
