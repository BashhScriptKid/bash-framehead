# `net::port::is_open`

**Signature:** `net::port::is_open(host, port, [timeout])`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code

## Description

Check if a TCP port is open on a host

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `host` | string | Yes | |
| `port` | string | Yes | |
| `timeout` | string | No | |

## Source

```bash
net::port::is_open() {
		local host="$1" port="$2" timeout="${3:-2}"
		if runtime::has_command nc; then
				nc -z -w "$timeout" "$host" "$port" >/dev/null 2>&1
		elif runtime::has_command bash; then
				# Pure bash /dev/tcp trick
				(echo >/dev/tcp/"$host"/"$port") >/dev/null 2>&1
		else
				return 1
		fi
}
```

