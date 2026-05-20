# `net::can_reach`

Check if a specific host is reachable

## Usage

```bash
net::can_reach host [timeout_seconds]
```

## Source

```bash
net::can_reach() {
    local host="$1" timeout="${2:-2}"
    ping -c 1 -W "$timeout" "$host" >/dev/null 2>&1
}
```

## Module

[`net`](../net.md)
