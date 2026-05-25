# `random::secure`

**Signature:** `random::secure()`

**Module:** [`random`](../random.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

SECURE


## Source

```bash
random::secure() {
		if [[ -z "${SRANDOM:-}" ]]; then
				echo "random::secure: requires Bash 5.1+ (SRANDOM not available)" >&2; return 1
		fi
		echo "$SRANDOM"
}
```

