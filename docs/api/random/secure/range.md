# `random::secure::range`

**Signature:** `random::secure::range(min, max)`

**Module:** [`random`](../../random.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Secure random in [min, max] inclusive.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `min` | string | Yes | |
| `max` | string | Yes | |

## Source

```bash
random::secure::range() {
		if [[ -z "${SRANDOM:-}" ]]; then
				echo "random::secure::range: requires Bash 5.1+" >&2; return 1
		fi
		local min="$1" max="$2"
		echo $(( (SRANDOM % (max - min + 1)) + min ))
}
```

