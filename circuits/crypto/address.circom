pragma circom 2.1.6;

include "circomlib/circuits/poseidon.circom";

// get and array of max_claim_json_bytes (e.g. 78) and splits it into 6 chunks of 13 bytes each
// Note these values are hardcoded and are based on the fact that max_claim_json_bytes = 78. If this values
// changes then we would need to adapt the hardcoded values too
template Chunk(max_claim_json_bytes) {
  signal input in[max_claim_json_bytes];
  signal output out[6][13];

  for(var i = 0; i < max_claim_json_bytes; i += 13) {
    var chunk = i / 13;
    for(var j = 0; j < 13; j++) {
      out[chunk][j] <== in[j + i];
    }
  }
}

template HashChunks() {
  signal input chunks[6][13];
  signal output out;

  component final_hash = Poseidon(6);

  for(var i = 0; i < 6; i++) {
    final_hash.inputs[i] <== Poseidon(13)(chunks[i]);
  }

  out <== final_hash.out;
}


/// It will compute `address = H(sub|iss|aud|salt)`
/// sub, iss nad aud are byte arrays so we have to:
/// 1. split each array into chunks of 13 bytes. The reason is that Poseidon can accept at most 16 input values
///    and since these array have 78 bytes we want to split where 78 % chunk_count == 0; That's why we split into 6
///    chunks.
/// 2. get the hash of each such chunk and then calculate the hash of all chunk hashes H(AllChunkHashes)
/// 3. At this point we have found the hash for one claim. We do this for all other claims and at the end
///    we concatenate those 4 hashes to find the final hash.
template Address(max_claim_json_bytes, k) {
  signal input sub[max_claim_json_bytes];
  signal input iss[max_claim_json_bytes];
  signal input aud[max_claim_json_bytes];
  signal input salt[16];

  signal output out;

  signal sub_hash <== HashChunks()(Chunk(max_claim_json_bytes)(sub));
  signal iss_hash <== HashChunks()(Chunk(max_claim_json_bytes)(iss));
  signal aud_hash <== HashChunks()(Chunk(max_claim_json_bytes)(aud));
  signal salt_hash <== Poseidon(16)(salt);

  out <== Poseidon(4)([sub_hash, iss_hash, aud_hash, salt_hash]);
}
