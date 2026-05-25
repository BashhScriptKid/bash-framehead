# `fs::temp::file`

**Signature:** `fs::temp::file(tmpfile=$(fs::temp::file, [prefix]))`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- TEMP FILES ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `tmpfile=$(fs::temp::file` | string | Yes | |
| `[prefix])` | string | Yes | |

## Source

```bash
fs::temp::file() {
		local prefix="${1:-fsbshf}"
		mktemp "/tmp/${prefix}.XXXXXX"
}
```

