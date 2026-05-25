# `fs::mime_type`

**Signature:** `fs::mime_type(arg1)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

MIME type

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::mime_type() {
		if runtime::has_command file; then
				file --mime-type -b "$1" 2>/dev/null
		else
				echo "unknown"
		fi
}
```

