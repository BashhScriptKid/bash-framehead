# `net::mac`

Get MAC address of an interface

## Usage

```bash
net::mac interface
```

## Source

```bash
net::mac() {
    local iface="${1:-eth0}"
    if [[ -f "/sys/class/net/$iface/address" ]]; then
        cat "/sys/class/net/$iface/address"
    elif runtime::has_command ip; then
        ip link show "$iface" 2>/dev/null | awk '/ether/{print $2}'
    elif runtime::has_command ifconfig; then
        ifconfig "$iface" 2>/dev/null | awk '/ether|HWaddr/{print $2}'
    fi
}
```

## Module

[`net`](../net.md)
