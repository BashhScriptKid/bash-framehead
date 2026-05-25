# `net::port::wait`

**Signature:** `net::port::wait(host, port, [timeout_seconds], [interval])`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code

## Description

Wait until a port is open (useful for service readiness checks)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `host` | string | Yes | |
| `port` | string | Yes | |
| `timeout_seconds` | integer | No | |
| `interval` | string | No | |

## Source

```bash
net::port::wait() {
		local host="$1" port="$2" timeout="${3:-30}" interval="${4:-1}"
		local elapsed=0
		while (( elapsed < timeout )); do
				net::port::is_open "$host" "$port" && return 0
				sleep "$interval"
				(( elapsed += interval ))
		done
		return 1
}
```

