# `hash::murmur2`

**Signature:** `hash::murmur2()`

**Module:** [`hash`](../hash.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

MurmurHash2 — pure bash, good distribution, faster than cryptographic hashes


## Source

```bash
hash::murmur2() {
  local input; _hash::read_input input "$@"
    local s="$input" seed="${2:-0}"
    local len="${#s}"
    local m=2246822519 r=13
    local h=$(( seed ^ len ))
    local i=0 k

    while (( i + 4 <= len )); do
        local c0=$(printf '%d' "'${s:$i:1}")
        local c1=$(printf '%d' "'${s:$((i+1)):1}")
        local c2=$(printf '%d' "'${s:$((i+2)):1}")
        local c3=$(printf '%d' "'${s:$((i+3)):1}")
        k=$(( c0 | (c1 << 8) | (c2 << 16) | (c3 << 24) ))
        k=$(( (k * m) & 0xFFFFFFFF ))
        k=$(( k ^ (k >> r) ))
        k=$(( (k * m) & 0xFFFFFFFF ))
        h=$(( (h * m) & 0xFFFFFFFF ))
        h=$(( (h ^ k) & 0xFFFFFFFF ))
        (( i += 4 ))
    done

    # Handle remaining bytes
    local remaining=$(( len - i ))
    case "$remaining" in
    3) h=$(( h ^ ($(printf '%d' "'${s:$((i+2)):1}") << 16) )) ;&
    2) h=$(( h ^ ($(printf '%d' "'${s:$((i+1)):1}") << 8)  )) ;&
    1) h=$(( h ^ $(printf '%d' "'${s:$i:1}") ))
       h=$(( (h * m) & 0xFFFFFFFF ))
       ;;
    esac

    h=$(( h ^ (h >> 13) ))
    h=$(( (h * m) & 0xFFFFFFFF ))
    h=$(( h ^ (h >> 15) ))

    echo "$h"
}
```

