# `net::backend`

**Signature:** `net::backend()`

**Module:** [`net`](../net.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Report the active backend. Useful for callers that need to know


## Source

```bash
net::backend() {
		_net::init
		echo "$_NET_BACKEND"
}
```

