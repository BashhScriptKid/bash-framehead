# `net::http::status`

**Signature:** `net::http::status(url)`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check HTTP status code of a URL

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `url` | string | Yes | |

## Source

```bash
net::http::status() {
		if runtime::has_command curl; then
				curl -sLo /dev/null -w '%{http_code}' --max-time 10 "$1" 2>/dev/null
		elif runtime::has_command wget; then
				wget -qS --spider "$1" 2>&1 | awk '/HTTP\//{print $2}' | tail -1
		fi
}
```

