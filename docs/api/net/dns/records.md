# `net::dns::records`

**Signature:** `net::dns::records(hostname, [type])`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get all DNS records of a type

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `hostname` | string | Yes | |
| `type` | string | No | |

## Source

```bash
net::dns::records() {
		local host="$1" type="${2:-A}"
		if runtime::has_command dig; then
				dig +short "$host" "$type" 2>/dev/null
		elif runtime::has_command nslookup; then
				nslookup -type="$type" "$host" 2>/dev/null
		fi
}
```

