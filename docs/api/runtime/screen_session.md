# `runtime::screen_session`

**Signature:** `runtime::screen_session()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
runtime::screen_session() {
	echo "${STY:-${TMUX:-none}}"
}
```

