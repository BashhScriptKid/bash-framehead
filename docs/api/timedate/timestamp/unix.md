# `timedate::timestamp::unix`

**Signature:** `timedate::timestamp::unix()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Current unix timestamp (seconds since epoch)


## Source

```bash
timedate::timestamp::unix() {
    date +%s
}
```

