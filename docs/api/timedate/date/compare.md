# `timedate::date::compare`

**Signature:** `timedate::date::compare(YYYY-MM-DD, YYYY-MM-DD)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Compare two dates — returns -1, 0, or 1

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `YYYY-MM-DD` | string | Yes | |
| `YYYY-MM-DD` | string | Yes | |

## Source

```bash
timedate::date::compare() {
    local ts1 ts2
    ts1=$(timedate::timestamp::from_human "$1 00:00:00")
    ts2=$(timedate::timestamp::from_human "$2 00:00:00")
    if (( ts1 < ts2 ));   then echo -1
    elif (( ts1 > ts2 )); then echo 1
    else                       echo 0
    fi
}
```

