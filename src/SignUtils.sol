// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "permit2/interfaces/ISignatureTransfer.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Vm} from "forge-std/Vm.sol";

contract SignUtils {
    // Permit2 Test Utility
    Vm private constant vm =
        Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    bytes32 public constant _TOKEN_PERMISSIONS_TYPEHASH =
        keccak256("TokenPermissions(address token,uint256 amount)");

    bytes32 public constant _PERMIT_TRANSFER_FROM_TYPEHASH =
        keccak256(
            "PermitTransferFrom(TokenPermissions permitted,address spender,uint256 nonce,uint256 deadline)TokenPermissions(address token,uint256 amount)"
        );

    bytes32 public constant _PERMIT_BATCH_TRANSFER_FROM_TYPEHASH =
        keccak256(
            "PermitBatchTransferFrom(TokenPermissions[] permitted,address spender,uint256 nonce,uint256 deadline)TokenPermissions(address token,uint256 amount)"
        );

    ISignatureTransfer.PermitBatchTransferFrom permitBatchTransfers;
    ISignatureTransfer.TokenPermissions[] batchTokenPermissions;
    ISignatureTransfer.SignatureTransferDetails[] batchTransferDetails;

    function defaultERC20PermitTransfer(
        address token,
        uint256 nonce,
        uint256 amount,
        uint256 deadline
    ) internal pure returns (ISignatureTransfer.PermitTransferFrom memory) {
        return
            ISignatureTransfer.PermitTransferFrom({
                permitted: ISignatureTransfer.TokenPermissions({
                    token: token,
                    amount: amount
                }),
                nonce: nonce,
                deadline: deadline
            });
    }

    function getTransferDetails(
        address to,
        uint256 amount
    )
        internal
        pure
        returns (ISignatureTransfer.SignatureTransferDetails memory)
    {
        return
            ISignatureTransfer.SignatureTransferDetails({
                to: to,
                requestedAmount: amount
            });
    }

    function getPermitTransferSignature(
        ISignatureTransfer.PermitTransferFrom memory permit,
        uint256 privateKey,
        address spender,
        bytes32 domainSeparator
    ) internal pure returns (bytes memory sig) {
        bytes32 tokenPermissions = keccak256(
            abi.encode(_TOKEN_PERMISSIONS_TYPEHASH, permit.permitted)
        );
        bytes32 msgHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                keccak256(
                    abi.encode(
                        _PERMIT_TRANSFER_FROM_TYPEHASH,
                        tokenPermissions,
                        spender,
                        permit.nonce,
                        permit.deadline
                    )
                )
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);
        return bytes.concat(r, s, bytes1(v));
    }

    function getBatchTokenPermissions(
        address[] memory tokens,
        uint256[] memory amounts
    ) internal returns (ISignatureTransfer.TokenPermissions[] memory) {
        if (tokens.length > 0 || amounts.length > 0) {
            for (uint256 i; i < tokens.length; i++) {
                ISignatureTransfer.TokenPermissions
                    memory tokenPermissions = ISignatureTransfer
                        .TokenPermissions({
                            token: tokens[i],
                            amount: amounts[i]
                        });

                batchTokenPermissions.push(tokenPermissions);
            }
        }

        return batchTokenPermissions;
    }

    function defaultERC20PermitBatchTransfer(
        ISignatureTransfer.TokenPermissions[] memory _batchTokenPermissions,
        uint256 nonce,
        uint256 deadline
    )
        internal
        pure
        returns (ISignatureTransfer.PermitBatchTransferFrom memory)
    {
        ISignatureTransfer.PermitBatchTransferFrom
            memory permitBatch = ISignatureTransfer.PermitBatchTransferFrom({
                permitted: _batchTokenPermissions,
                nonce: nonce,
                deadline: deadline
            });

        return permitBatch;
    }

    function getBatchTransferDetails(
        address[] memory to,
        uint256[] memory amount
    ) internal returns (ISignatureTransfer.SignatureTransferDetails[] memory) {
        if (to.length > 0 || amount.length > 0) {
            for (uint256 i; i < to.length; i++) {
                ISignatureTransfer.SignatureTransferDetails
                    memory transferDetail = ISignatureTransfer
                        .SignatureTransferDetails({
                            to: to[i],
                            requestedAmount: amount[i]
                        });
                batchTransferDetails.push(transferDetail);
            }
        }

        return batchTransferDetails;
    }

    function getBatchPermitTransferSignature(
        ISignatureTransfer.PermitBatchTransferFrom memory permit,
        uint256 privateKey,
        address spender,
        bytes32 domainSeparator
    ) internal pure returns (bytes memory sig) {
        uint256 numPermitted = permit.permitted.length;
        bytes32[] memory tokenPermissionHashes = new bytes32[](numPermitted);

        for (uint256 i; i < numPermitted; i++) {
            tokenPermissionHashes[i] = keccak256(
                abi.encode(_TOKEN_PERMISSIONS_TYPEHASH, permit.permitted[i])
            );
        }

        bytes32 msgHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                keccak256(
                    abi.encode(
                        _PERMIT_BATCH_TRANSFER_FROM_TYPEHASH,
                        keccak256(abi.encodePacked(tokenPermissionHashes)),
                        spender,
                        permit.nonce,
                        permit.deadline
                    )
                )
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);
        return bytes.concat(r, s, bytes1(v));
    }
}
