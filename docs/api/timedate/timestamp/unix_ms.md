# `timedate::timestamp::unix_ms`

**Signature:** `timedate::timestamp::unix_ms()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Current unix timestamp in milliseconds


## Source

```bash
timedate::timestamp::unix_ms() {
    if _timedate::has_gnu_date; then
        date +%s%3N
    else
        # macOS fallback — python if available
        if runtime::has_command python3; then
            python3 -c "import time; print(int(time.time() * 1000))"
        else
            echo "$(date +%s)000"
        fi
    fi
}
```

