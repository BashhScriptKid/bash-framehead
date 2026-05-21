# `fs::path::extension`

**Signature:** `fs::path::extension(file.tar.gz, →, gz)`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get file extension (without dot)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `file.tar.gz` | string | Yes | |
| `→` | string | Yes | |
| `gz` | string | Yes | |

## Source

```bash
fs::path::extension() {
    local base="${1##*/}"
    [[ "$base" == *.* ]] && echo "${base##*.}" || echo ""
}
```

