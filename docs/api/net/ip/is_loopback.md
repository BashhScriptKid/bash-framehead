# `net::ip::is_loopback`

**Signature:** `net::ip::is_loopback(arg1)`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if IP is loopback

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
net::ip::is_loopback() {
		[[ "$1" == "127."* || "$1" == "::1" ]]
}
```

