pragma circom 2.1.6;

/// This is the character that will be used to fill the remaining characters of the byte array we want to encode/decode
/// This is a value that we know does not exist in ASCII not in base64 look up tables.
function null_char() {
  return 127;
}
