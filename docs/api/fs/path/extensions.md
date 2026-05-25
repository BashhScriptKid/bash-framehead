# `fs::path::extensions`

**Signature:** `fs::path::extensions(file.tar.gz, →, tar.gz)`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get all extensions for multi-part extensions

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `file.tar.gz` | string | Yes | |
| `→` | string | Yes | |
| `tar.gz` | string | Yes | |

## Source

```bash
fs::path::extensions() {
		local base="${1##*/}"
		[[ "$base" == *.* ]] && echo "${base#*.}" || echo ""
}
```

