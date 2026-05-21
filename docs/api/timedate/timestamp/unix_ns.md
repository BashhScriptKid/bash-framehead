# `timedate::timestamp::unix_ns`

**Signature:** `timedate::timestamp::unix_ns()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Current unix timestamp in nanoseconds


## Source

```bash
timedate::timestamp::unix_ns() {
    if _timedate::has_gnu_date; then
        date +%s%N
    elif runtime::has_command python3; then
        python3 -c "import time; print(int(time.time() * 1e9))"
    else
        echo "$(date +%s)000000000"
    fi
}
```

