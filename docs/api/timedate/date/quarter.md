# `timedate::date::quarter`

**Signature:** `timedate::date::quarter()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Get quarter (1-4)


## Source

```bash
timedate::date::quarter() {
		local month
		month=$(date +%m)
		echo $(( (10#$month - 1) / 3 + 1 ))
}
```

