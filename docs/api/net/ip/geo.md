# `net::ip::geo`

**Signature:** `net::ip::geo([ip], , (omit, for, public, IP))`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get geolocation info for an IP (uses ip-api.com free tier)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `ip` | string | No | |
| `(omit` | string | Yes | |
| `for` | string | Yes | |
| `public` | string | Yes | |
| `IP)` | string | Yes | |

## Source

```bash
net::ip::geo() {
		local ip="${1:-}"
		local url="http://ip-api.com/json/${ip}"
		net::fetch "$url" 2>/dev/null
}
```

