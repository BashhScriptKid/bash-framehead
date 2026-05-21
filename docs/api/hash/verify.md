# `hash::verify`

**Signature:** `hash::verify(string, expected_hash, algorithm)`

**Module:** [`hash`](../hash.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Verify a string against a known hash

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `string` | string | Yes | |
| `expected_hash` | string | Yes | |
| `algorithm` | string | Yes | |

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

