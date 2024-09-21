## SignUtils

This is a signature utility library for the Uniswap Permit2 contract created to help developers building project that integrates Uniswap Permit2 to test their code using the Uniswap Permit2 hash Permit2 calldata, create signature and sign the approvals off-chain.

## Functions

```solidity
    _hash(
        ISignatureTransfer.PermitTransferFrom memory permit
    )
```
The hash function is used to hash a Permit parameter using the TypeHash of the struct `TokenPermissions()` and the TypeHash of the `PermitTransferFrom()` struct, appended by other parameters. The result is a messageHash of the parameters. 


```solidity
    _hash(
        ISignatureTransfer.PermitBatchTransferFrom memory permit
    )
```

The hash function is used to hash a Permit parameter using the TypeHash of the struct `TokenPermissions()` and the TypeHash of the `PermitTransferFrom()` struct, appended by other parameters. The result is a messageHash of the parameters. 

```solidity
    constructSig(
        ISignatureTransfer.PermitBatchTransferFrom memory permit,
        uint256 privKey
    )
```
The construct signature function is used to construct a signature which signs the message and is used to verify the caller of the transaction using the digest and the caller's address.


### Installation Guide

```bash
    forge install PaulElisha/Sign-Utils
```

## Usage

This is an abstract contract so after installation, go ahead to inherit it in your test helper file.

To construct a signature, the following code can be pasted in your test helper file:

```solidity
    function constructSig(
        Permit2SignatureTransferDetails memory _signatureTransferDetails,
        uint256 privKey
    ) public view returns (bytes memory sig) {
        bytes32 mhash = _hash(_signatureTransferDetails.permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privKey, mhash);
        sig = getSig(v, r, s);
    }
```

This takes in the Permit parameter and the private key to sign the message hash.

The `*_hash()*` and the `*getSig()*` function will automatically inherit from SignUtils.

## Note
This was initially written as a contract for testing purposes to ensure that all the functions are working perfectly before converting into an abstract contract.

Also, this is not your conventional EIP712 and EIP2612 Permit hashing and signature scheme so the methods and practices used in testing them do not apply here, Kindly follow the code carefully.