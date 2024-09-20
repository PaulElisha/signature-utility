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

## Usage

### Installation Guide

```bash
    forge install PaulElisha/Sign-Utils
```
## Note
This was initially written as a contract for testing purposes to ensure that all the functions are working perfectly before converting into an abstract contract.

Also, this is not your conventional EIP712 and EIP2612 Permit hashing and signature scheme so the methods and practices used in testing them do not apply here, Kindly follow the code carefully.