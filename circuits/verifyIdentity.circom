pragma circom 2.0.0;
// Circuit to prove that a message has been signed by a given signer
template verifyMessageSigner() {
    signal input message;
    signal input signedMessageHash;
    signal input signerPublicKey;
    signal private input signerPrivateKey;
}