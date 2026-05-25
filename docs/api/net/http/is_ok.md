# `net::http::is_ok`

**Signature:** `net::http::is_ok(arg1)`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if a URL returns 200 OK

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
net::http::is_ok() {
		[[ "$(net::http::status "$1")" == "200" ]]
}
```

