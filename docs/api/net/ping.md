# `net::ping`

**Signature:** `net::ping(host, [count])`

**Module:** [`net`](../net.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Ping a host and return average round-trip time in ms

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `host` | string | Yes | |
| `count` | string | No | |

## Source

```bash
net::ping() {
		local host="$1" count="${2:-4}"
		ping -c "$count" "$host" 2>/dev/null | \
				tail -1 | awk -F'/' '{print $5}'
}
```

