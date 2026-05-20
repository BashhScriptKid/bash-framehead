# `net::is_online`

Check if the system has a working internet connection
Tries multiple endpoints in case one is down

## Source

```bash
net::is_online() {
    local endpoints=("8.8.8.8" "1.1.1.1" "9.9.9.9")
    for endpoint in "${endpoints[@]}"; do
        if ping -c 1 -W 2 "$endpoint" >/dev/null 2>&1; then
            return 0
        fi
    done
    return 1
}
```

## Module

[`net`](../net.md)
