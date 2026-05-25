# `net::port::scan`

**Signature:** `net::port::scan(host, [start_port], [end_port])`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Scan common ports on a host, print open ones

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `host` | string | Yes | |
| `start_port` | integer | No | |
| `end_port` | integer | No | |

## Source

```bash
net::port::scan() {
		local host="$1" start="${2:-1}" end="${3:-1024}"
		local port
		for (( port=start; port<=end; port++ )); do
				net::port::is_open "$host" "$port" 1 && echo "$port"
		done
}
```

