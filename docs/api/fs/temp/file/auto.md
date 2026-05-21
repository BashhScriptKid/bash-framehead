# `fs::temp::file::auto`

**Signature:** `fs::temp::file::auto([prefix])`

**Module:** [`fs`](../../../fs.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

Create a temp file and register cleanup on EXIT

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `prefix` | string | No | |

## Source

```bash
fs::temp::file::auto() {
    local tmp
    tmp=$(fs::temp::file "$1")
    trap "rm -f '$tmp'" EXIT
    echo "$tmp"
}
```

