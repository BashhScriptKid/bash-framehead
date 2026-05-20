# `net::ip::all`

Get all local IP addresses (one per line)

## Source

```bash
net::ip::all() {
    if runtime::has_command ip; then
        ip addr show 2>/dev/null | awk '/inet /{gsub(/\/.*/, "", $2); print $2}'
    elif runtime::has_command ifconfig; then
        ifconfig 2>/dev/null | awk '/inet /{print $2}'
    fi
}
```

## Module

[`net`](../net.md)
