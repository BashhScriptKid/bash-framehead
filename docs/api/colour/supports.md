# `colour::supports`

**Signature:** `colour::supports()`

**Module:** [`colour`](../colour.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

!/usr/bin/env bash


## Source

```bash
colour::supports() {
		[[ -t 1 ]] || return 1
		local count
		count=$(colour::depth)
		(( count >= 8 ))
}
```

