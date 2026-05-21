# `fs::path::join`

**Signature:** `fs::path::join(part1, part2, ...)`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Join path components

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `part1` | string | Yes | |
| `part2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
fs::path::join() {
    local result="$1"; shift
    for part in "$@"; do
        part="${part#/}"   # strip leading slash from each part
        result="${result%/}/$part"
    done
    echo "$result"
}
```

