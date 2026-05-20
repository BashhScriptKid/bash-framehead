# `hash::adler32`

Adler-32 — fast checksum used in zlib/PNG
Not a hash in the traditional sense but useful for data integrity

## Source

```bash
hash::adler32() {
    local s="$1"
    local a=1 b=0 i char MOD=65521

    for (( i=0; i<${#s}; i++ )); do
        char=$(printf '%d' "'${s:$i:1}")
        a=$(( (a + char) % MOD ))
        b=$(( (b + a) % MOD ))
    done

    echo $(( (b << 16) | a ))
}
```

## Module

[`hash`](../hash.md)
