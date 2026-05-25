# `net::ip::local`

**Signature:** `net::ip::local(arg2)`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- IP ADDRESS ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg2` | string | Yes | |

## Source

```bash
net::ip::local() {
		if runtime::has_command ip; then
				ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}'
		elif runtime::has_command ifconfig; then
				ifconfig 2>/dev/null | awk '/inet /{print $2}' | grep -v '127.0.0.1' | head -1
		fi
}
```

