# `timedate::time::stopwatch::stop`

**Signature:** `timedate::time::stopwatch::stop(token)`

**Module:** [`timedate`](../../../timedate.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

Stopwatch — stop, returns elapsed ms

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `token` | string | Yes | |

## Source

```bash
timedate::time::stopwatch::stop() {
    local start="$1"
    local now
    now=$(timedate::timestamp::unix_ms)
    echo $(( now - start ))
}
```

