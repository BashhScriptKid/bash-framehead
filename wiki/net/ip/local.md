# `net::ip::local`

Get local IP address (first non-loopback)

## Source

```bash
net::ip::local() {
    if runtime::has_command ip; then
        ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}'
    elif runtime::has_command ifconfig; then
        ifconfig 2>/dev/null | awk '/inet /{print $2}' | grep -v '127.0.0.1' | head -1
    fi
}
```

## Module

[`net`](../net.md)
