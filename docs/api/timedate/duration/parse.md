# `timedate::duration::parse`

**Signature:** `timedate::duration::parse(1d, 2h, 3m, 4s)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Parse a duration string into seconds

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `1d` | string | Yes | |
| `2h` | string | Yes | |
| `3m` | string | Yes | |
| `4s` | string | Yes | |

## Source

```bash
timedate::duration::parse() {
		local input="$1" total=0
		# shellcheck disable=SC2206
		local -a tokens=($input)
		for token in "${tokens[@]}"; do
				local val unit
				val="${token%[dhms]*}"
				unit="${token##*[0-9]}"
				case "$unit" in
				d) (( total += val * 86400 )) ;;
				h) (( total += val * 3600  )) ;;
				m) (( total += val * 60    )) ;;
				s) (( total += val         )) ;;
				esac
		done
		echo "$total"
}
```

