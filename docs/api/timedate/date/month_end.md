# `timedate::date::month_end`

**Signature:** `timedate::date::month_end()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Get end of current month


## Source

```bash
timedate::date::month_end() {
		local year month days
		year=$(date +%Y)
		month=$(date +%m)
		days=$(timedate::date::days_in_month "$year" "$month")
		printf '%s-%s-%02d\n' "$year" "$month" "$days"
}
```

