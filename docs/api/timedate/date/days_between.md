# `timedate::date::days_between`

**Signature:** `timedate::date::days_between(YYYY-MM-DD, YYYY-MM-DD)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Number of days between two dates

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `YYYY-MM-DD` | string | Yes | |
| `YYYY-MM-DD` | string | Yes | |

## Source

```bash
timedate::date::days_between() {
    local ts1 ts2
    ts1=$(timedate::timestamp::from_human "$1 00:00:00")
    ts2=$(timedate::timestamp::from_human "$2 00:00:00")
    echo $(( (ts2 - ts1) / 86400 ))
}
```

