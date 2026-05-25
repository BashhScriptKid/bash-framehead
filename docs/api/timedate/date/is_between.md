# `timedate::date::is_between`

**Signature:** `timedate::date::is_between(arg1, arg2, arg3)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if a date is between two dates (inclusive)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |
| `arg3` | string | Yes | |

## Source

```bash
timedate::date::is_between() {
		local d="$1" start="$2" end="$3"
		! timedate::date::is_before "$d" "$start" && \
		! timedate::date::is_after  "$d" "$end"
}
```

