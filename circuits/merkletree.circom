pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/mimcsponge.circom";

template HashLeftRight() {
    signal input left;
    signal input right;
    signal output hash;

    component mimcsponge = MiMCSponge(2, 220, 1);
    mimcsponge.ins[0] <== left;
    mimcsponge.ins[1] <== right;
    mimcsponge.k <== 0;

    hash <== mimcsponge.outs[0];
}

// This is used to determine the order to supply the inputs
// for the hash to be computed
// if s == 0 returns [in[0], in[1]]
// if s == 1 returns [in[1], in[0]]
template DualMux() {
    signal input in[2];
    signal input s;
    signal output out[2];

    s * (1 - s) === 0;
    out[0] <== (in[1] - in[0])*s + in[0];
    out[1] <== (in[0] - in[1])*s + in[1];
}


template MerkleVerify(n) {
    signal input merkleRoot;
    signal input merklePathElements[n];
    signal input merklePathIndices[n];
    signal input leaf;
    // signal output merkleValid; // there is no need for this output as the constrain
    // will fail if it is not valid
    component hashes[n];
    component selectors[n];

    var i;

    for (i = 0; i < n; i++) {
        hashes[i] = HashLeftRight();
        selectors[i] = DualMux();
        
        selectors[i].in[0] <== i == 0 ? leaf : hashes[i-1].hash;
        selectors[i].in[1] <== merklePathElements[i];
        selectors[i].s <== merklePathIndices[i];

        hashes[i].left <== selectors[i].out[0];
        hashes[i].right <== selectors[i].out[1];
    }

    merkleRoot === hashes[n - 1].hash;
}

component main {public [merkleRoot, merklePathElements, merklePathIndices, leaf]} = MerkleVerify(5000000);