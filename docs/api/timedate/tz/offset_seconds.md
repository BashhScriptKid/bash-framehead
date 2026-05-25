# `timedate::tz::offset_seconds`

**Signature:** `timedate::tz::offset_seconds()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Get UTC offset in seconds


## Source

```bash
timedate::tz::offset_seconds() {
		local offset
		offset=$(date +%z)
		local sign="${offset:0:1}"
		local hours=$(( 10#${offset:1:2} ))
		local mins=$(( 10#${offset:3:2} ))
		local total=$(( hours * 3600 + mins * 60 ))
		[[ "$sign" == "-" ]] && total=$(( -total ))
		echo "$total"
}
```

