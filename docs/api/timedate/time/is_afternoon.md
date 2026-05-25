# `timedate::time::is_afternoon`

**Signature:** `timedate::time::is_afternoon()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if currently afternoon (12:00-17:59)


## Source

```bash
timedate::time::is_afternoon() {
		local hour
		hour=$(( 10#$(date +%H) ))
		(( hour >= 12 && hour < 18 ))
}
```

