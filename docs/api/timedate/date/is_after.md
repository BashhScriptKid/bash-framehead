# `timedate::date::is_after`

**Signature:** `timedate::date::is_after(arg1, arg2)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if a date is after another

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
timedate::date::is_after() {
    [[ "$(timedate::date::compare "$1" "$2")" == "1" ]]
}
```

