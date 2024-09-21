// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "permit2/interfaces/ISignatureTransfer.sol";
import "forge-std/Test.sol";

abstract contract SignUtils is Test {
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    bytes32 private constant _HASHED_NAME = keccak256("Permit2");
    bytes32 private constant _TYPE_HASH =
        keccak256(
            "EIP712Domain(string name,uint256 chainId,address verifyingContract)"
        );

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

    struct Permit2SignatureTransferDetails {
        ISignatureTransfer.PermitBatchTransferFrom permit;
        ISignatureTransfer.SignatureTransferDetails[] transferDetails;
    }

    struct Permit2SignatureTransferData {
        ISignatureTransfer.PermitTransferFrom permit;
        ISignatureTransfer.SignatureTransferDetails transferDetails;
    }

    constructor() {
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(
            _TYPE_HASH,
            _HASHED_NAME
        );
    }

    function _hash(
        ISignatureTransfer.PermitTransferFrom memory permit
    ) public view returns (bytes32) {
        bytes32 tokenPermissionsHash = _hashTokenPermissions(permit.permitted);
        return
            keccak256(
                abi.encode(
                    _PERMIT_TRANSFER_FROM_TYPEHASH,
                    tokenPermissionsHash,
                    msg.sender,
                    permit.nonce,
                    permit.deadline
                )
            );
    }

    function _hash(
        ISignatureTransfer.PermitBatchTransferFrom memory permit
    ) public view returns (bytes32) {
        uint256 numPermitted = permit.permitted.length;
        bytes32[] memory tokenPermissionHashes = new bytes32[](numPermitted);

        for (uint256 i = 0; i < numPermitted; ++i) {
            tokenPermissionHashes[i] = _hashTokenPermissions(
                permit.permitted[i]
            );
        }

        return
            keccak256(
                abi.encode(
                    _PERMIT_BATCH_TRANSFER_FROM_TYPEHASH,
                    keccak256(abi.encodePacked(tokenPermissionHashes)),
                    msg.sender,
                    permit.nonce,
                    permit.deadline
                )
            );
    }

    function hashTypedData(bytes32 dataHash) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), dataHash)
            );
    }

    function _hashTypedData(
        ISignatureTransfer.PermitTransferFrom memory permit
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), _hash(permit))
            );
    }

    function _hashBatchTypedData(
        ISignatureTransfer.PermitBatchTransferFrom memory permit
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), _hash(permit))
            );
    }

    function constructSig(
        ISignatureTransfer.PermitBatchTransferFrom memory permit,
        uint256 privKey
    ) public view returns (bytes memory sig) {
        bytes32 mhash = _hash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privKey, mhash);
        sig = getSig(v, r, s);
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash
    ) private view returns (bytes32) {
        return
            keccak256(
                abi.encode(typeHash, nameHash, block.chainid, address(this))
            );
    }

    function _hashTokenPermissions(
        ISignatureTransfer.TokenPermissions memory permitted
    ) private pure returns (bytes32) {
        return keccak256(abi.encode(_TOKEN_PERMISSIONS_TYPEHASH, permitted));
    }

    function getSig(
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (bytes memory sig) {
        sig = bytes.concat(r, s, bytes1(v));
    }

    function DOMAIN_SEPARATOR() private view returns (bytes32) {
        return
            block.chainid == _CACHED_CHAIN_ID
                ? _CACHED_DOMAIN_SEPARATOR
                : _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME);
    }
}
