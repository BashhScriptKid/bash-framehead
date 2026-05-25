# `net::resolve`

**Signature:** `net::resolve(hostname)`

**Module:** [`net`](../net.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Resolve hostname to IP

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `hostname` | string | Yes | |

## Source

```bash
net::resolve() {
		if runtime::has_command dig; then
				dig +short "$1" 2>/dev/null | grep -E '^[0-9]+\.' | head -1
		elif runtime::has_command nslookup; then
				nslookup "$1" 2>/dev/null | awk '/^Address:/{print $2}' | grep -v '#' | head -1
		elif runtime::has_command getent; then
				getent hosts "$1" 2>/dev/null | awk '{print $1}' | head -1
		else
				ping -c 1 "$1" 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
		fi
}
```

