# `net::can_reach`

**Signature:** `net::can_reach(host, [timeout_seconds])`

**Module:** [`net`](../net.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if a specific host is reachable

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `host` | string | Yes | |
| `timeout_seconds` | integer | No | |

## Source

```bash
net::can_reach() {
    local host="$1" timeout="${2:-2}"
    ping -c 1 -W "$timeout" "$host" >/dev/null 2>&1
}
```

