# `fs::trash`

**Signature:** `fs::trash(path)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Safely delete to a trash dir instead of permanent delete

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `path` | path | Yes | |

## Source

```bash
fs::trash() {
		local trash_dir="${HOME}/.local/share/Trash/files"
		mkdir -p "$trash_dir"
		mv "$1" "$trash_dir/$(fs::path::basename "$1").$(date +%s)"
}
```

