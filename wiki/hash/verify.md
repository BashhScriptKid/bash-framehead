# `hash::verify`

Verify a string against a known hash

## Usage

```bash
hash::verify string expected_hash algorithm
```

## Example

```bash
hash::verify "hello" "2cf24dba..." sha256
```

## Source

```bash
hash::verify() {
    local s="$1" expected="$2" algo="${3:-sha256}"
    local actual
    actual=$(hash::"$algo" "$s" 2>/dev/null) || return 1
    [[ "$actual" == "$expected" ]]
}
```

## Module

[`hash`](../hash.md)
