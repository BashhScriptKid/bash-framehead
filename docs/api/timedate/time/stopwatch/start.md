# `timedate::time::stopwatch::start`

**Signature:** `timedate::time::stopwatch::start(token=$(timedate::time::stopwatch::start))`

**Module:** [`timedate`](../../../timedate.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Stopwatch — start, returns a token

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `token=$(timedate::time::stopwatch::start)` | string | Yes | |

## Source

```bash
timedate::time::stopwatch::start() {
		timedate::timestamp::unix_ms
}
```

