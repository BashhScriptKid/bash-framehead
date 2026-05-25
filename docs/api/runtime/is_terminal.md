# `runtime::is_terminal`

**Signature:** `runtime::is_terminal()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

!/usr/bin/env bash


## Source

```bash
runtime::is_terminal() {
	# Thorough check for all standard file descriptors (stdin, stdout, stderr)
	[[ -t 0 && -t 1 && -t 2 ]]
}
```

