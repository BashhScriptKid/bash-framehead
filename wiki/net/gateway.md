# `net::gateway`

Get default gateway

## Source

```bash
net::gateway() {
    if runtime::has_command ip; then
        ip route show default 2>/dev/null | awk '{print $3; exit}'
    elif runtime::has_command route; then
        route -n 2>/dev/null | awk '/^0\.0\.0\.0/{print $2; exit}'
    fi
}
```

## Module

[`net`](../net.md)
