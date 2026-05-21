# `hash::uuid5`

**Signature:** `hash::uuid5(namespace, name)`

**Module:** [`hash`](../hash.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Generate a hash-based UUID v5 (name-based, SHA1)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `namespace` | string | Yes | |
| `name` | string | Yes | |

## Source

```bash
hash::uuid5() {
    # uuidgen doesn't support v5 on all platforms — fall back to sha1-based manual construction
    local raw
    raw=$(hash::sha1 "${1}:${2}")
    printf '%s-%s-%s-%s-%s\n' \
        "${raw:0:8}" "${raw:8:4}" "5${raw:13:3}" \
        "$(printf '%x' $(( (16#${raw:16:2} & 0x3f) | 0x80 )))${raw:18:2}" \
        "${raw:20:12}"
}
```

