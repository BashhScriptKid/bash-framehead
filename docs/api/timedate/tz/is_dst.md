# `timedate::tz::is_dst`

**Signature:** `timedate::tz::is_dst()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if currently in daylight saving time


## Source

```bash
timedate::tz::is_dst() {
		local dst
		dst=$(date +%Z)
		# Most DST zones have a different abbreviation (EDT vs EST, BST vs GMT, etc.)
		# This is a heuristic — not universally reliable
		[[ "$dst" =~ DT$|BST|CEST|IST|NZDT|AEDT|AEST ]]
}
```

