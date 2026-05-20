# `hash::hmac::md5`

HMAC-MD5

## Usage

```bash
hash::hmac::md5 key message
```

## Source

```bash
hash::hmac::md5() {
    local key="$1" msg="$2"
    if runtime::has_command openssl; then
        printf '%s' "$msg" | \
            openssl dgst -md5 -hmac "$key" 2>/dev/null | awk '{print $NF}'
    else
        echo "hash::hmac::md5: requires openssl" >&2
        return 1
    fi
}
```

## Module

[`hash`](../hash.md)
