# `fifo::create`

**Signature:** `fifo::create(path, [mode])`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- FIFO / NAMED PIPES ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `path` | path | Yes | |
| `mode` | string | No | |

## Source

```bash
fifo::create() {
		local path="$1" mode="$2"
		if [[ -n "$mode" ]]; then
				mkfifo -m "$mode" "$path"
		else
				mkfifo "$path"
		fi
}
```

