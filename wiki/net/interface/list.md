# `net::interface::list`

List all network interfaces

## Source

```bash
net::interface::list() {
    if runtime::has_command ip; then
        ip link show 2>/dev/null | awk -F': ' '/^[0-9]+:/{print $2}' | tr -d ' '
    elif runtime::has_command ifconfig; then
        ifconfig -l 2>/dev/null | tr ' ' '\n'
    elif [[ -d /sys/class/net ]]; then
        ls /sys/class/net/
    fi
}
```

## Module

[`net`](../net.md)
