# `timedate::time::is_after`

**Signature:** `timedate::time::is_after(arg1)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if current time is after a given time

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
timedate::time::is_after() {
		local target="$1"
		local current
		current=$(date +%H:%M)
		[[ "$current" > "$target" ]]
}
```

