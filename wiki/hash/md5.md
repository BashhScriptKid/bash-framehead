# `hash::md5`

MD5 hash of a string

## Usage

```bash
hash::md5 string
```

## Source

```bash
hash::md5() {
    if runtime::has_command md5sum; then
        _hash::pipe "$1" md5sum | awk '{print $1}'
    elif runtime::has_command md5; then
        _hash::pipe "$1" md5 -q 2>/dev/null || \
        _hash::pipe "$1" md5 | awk '{print $NF}'
    else
        echo "hash::md5: requires md5sum or md5" >&2
        return 1
    fi
}
```

## Module

[`hash`](../hash.md)
