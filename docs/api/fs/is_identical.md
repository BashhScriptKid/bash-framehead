# `fs::is_identical`

**Signature:** `fs::is_identical(arg1, arg2)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if two files are identical (by content)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
fs::is_identical() {
    local sum1 sum2
    sum1=$(fs::checksum::sha256 "$1")
    sum2=$(fs::checksum::sha256 "$2")
    [[ "$sum1" == "$sum2" ]]
}
```

