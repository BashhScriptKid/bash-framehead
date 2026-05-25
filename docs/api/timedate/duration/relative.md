# `timedate::duration::relative`

**Signature:** `timedate::duration::relative(timestamp)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Human-readable relative time from a unix timestamp

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `timestamp` | string | Yes | |

## Source

```bash
timedate::duration::relative() {
		local _timestamp="$1"
		local now
		now=$(timedate::timestamp::unix)
		local diff=$(( now - _timestamp ))
		local abs_diff=$(( diff < 0 ? -diff : diff ))
		local future=false
		(( diff < 0 )) && future=true

		local result
		if   (( abs_diff < 60 ));     then result="${abs_diff} second$( (( abs_diff != 1 )) && echo s)"
		elif (( abs_diff < 3600 ));   then
				local m=$(( abs_diff / 60 ))
				result="$m minute$( (( m != 1 )) && echo s)"
		elif (( abs_diff < 86400 ));  then
				local h=$(( abs_diff / 3600 ))
				result="$h hour$( (( h != 1 )) && echo s)"
		elif (( abs_diff < 2592000 )); then
				local d=$(( abs_diff / 86400 ))
				result="$d day$( (( d != 1 )) && echo s)"
		elif (( abs_diff < 31536000 )); then
				local mo=$(( abs_diff / 2592000 ))
				result="$mo month$( (( mo != 1 )) && echo s)"
		else
				local y=$(( abs_diff / 31536000 ))
				result="$y year$( (( y != 1 )) && echo s)"
		fi

		$future && echo "in $result" || echo "$result ago"
}
```

