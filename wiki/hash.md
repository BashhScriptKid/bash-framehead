# `hash`

Cryptographic and non-cryptographic hashing — MD5, SHA family, BLAKE2b, HMAC, DJB2, FNV-1a, MurmurHash2, CRC32, and utility functions for verification, consistent hashing, and hash-based UUIDs. **25 functions.** No `::fast` variants.

---

## Cryptographic Hashes

Delegates to system tools (`md5sum`, `sha256sum`, etc.).

| Function | Description |
|----------|-------------|
| `hash::md5` | MD5 hash (insecure, use only for checksums) |
| `hash::sha1` | SHA1 hash |
| `hash::sha256` | SHA256 hash |
| `hash::sha512` | SHA512 hash |
| `hash::sha3_256` | SHA3-256 hash |
| `hash::blake2b` | BLAKE2b hash |

```bash
hash::md5 "hello"       # → 5d41402abc4b2a76b9719d911017c592
hash::sha256 "hello"    # → 2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824
```

## HMAC

| Function | Description |
|----------|-------------|
| `hash::hmac::sha256` | HMAC-SHA256 |
| `hash::hmac::sha512` | HMAC-SHA512 |
| `hash::hmac::md5` | HMAC-MD5 |

```bash
hash::hmac::sha256 "secret-key" "message to sign"
```

---

## Non-Cryptographic Hashes

Pure Bash implementations — fast, suitable for hash tables and data structures.

| Function | Description |
|----------|-------------|
| `hash::djb2` | DJB2 — Daniel J. Bernstein's classic hash, returns unsigned 32-bit integer |
| `hash::djb2a` | DJB2a (xor variant) — slightly better distribution than djb2 |
| `hash::sdbm` | SDBM hash — used in the SDBM database library, often outperforms DJB2 for database keys |
| `hash::fnv1a32` | FNV-1a 32-bit — excellent avalanche, widely used (period: 2³²) |
| `hash::fnv1a64` | FNV-1a 64-bit — larger state for longer strings (note: bash uses signed 64-bit, results may be negative) |
| `hash::murmur2` | MurmurHash2 — pure Bash, good distribution, faster than cryptographic hashes |
| `hash::adler32` | Adler-32 — fast checksum used in zlib/PNG, for data integrity |
| `hash::crc32` | CRC32 — delegates to system tools, pure Bash fallback is too slow for real use |

```bash
hash::djb2 "hello"      # Fast, good for hash tables
hash::fnv1a32 "hello"   # Excellent distribution
hash::crc32 "hello"     # Uses system crc32 if available
```

---

## Utility Functions

| Function | Description |
|----------|-------------|
| `hash::verify` | Verify a string against a known hash with specified algorithm |
| `hash::slot` | Consistent hashing — map a value to a bucket (0 to n-1), useful for load balancing and sharding |
| `hash::short` | Generate a short hash — first n chars of sha256 |
| `hash::combine` | Hash multiple values into one — useful for cache keys from multiple inputs |
| `hash::equal` | Check if two strings have the same hash (constant-time safe via hash comparison) |
| `hash::uuid5` | Generate a UUID v5 (name-based, SHA1) — deterministic from namespace + name |

```bash
# Verify a password hash
hash::verify "mypassword" "5e884898da..." sha256 && echo "Match"

# Consistent hashing for sharding
bucket=$(hash::slot 8 "user123")  # → 0–7, always the same for "user123"

# Short hash for display
hash::short "long-string" 8        # → "2cf24dba"

# Combined cache key
key=$(hash::combine "user" "123" "profile")

# Deterministic UUID
hash::uuid5 "6ba7b810-9dad-11d1-80b4-00c04fd430c8" "my-resource"
```

## Dependencies

- **Requires**: `runtime`
- **External tools**: System hash commands (`md5sum`, `sha256sum`, etc.) for cryptographic hashes; `crc32` for CRC32 (with pure Bash fallback)
