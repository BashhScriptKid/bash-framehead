# `fs::checksum::md5`

**Signature:** `fs::checksum::md5(arg1)`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::checksum::md5() {
    if runtime::has_command md5sum; then
        md5sum "$1" | awk '{print $1}'
    elif runtime::has_command md5; then
        md5 -q "$1"
    fi
}
```

