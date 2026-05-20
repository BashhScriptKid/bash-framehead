# `net::ip::is_loopback`

Check if IP is loopback

## Source

```bash
net::ip::is_loopback() {
    [[ "$1" == "127."* || "$1" == "::1" ]]
}
```

## Module

[`net`](../net.md)
