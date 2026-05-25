# `net::http::headers`

**Signature:** `net::http::headers(arg1)`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get response headers

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
net::http::headers() {
		if runtime::has_command curl; then
				curl -sI --max-time 10 "$1" 2>/dev/null
		elif runtime::has_command wget; then
				wget -qS --spider "$1" 2>&1
		fi
}
```

