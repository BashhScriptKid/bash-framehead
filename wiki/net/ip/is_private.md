# `net::ip::is_private`

Check if IP is in private range

## Source

```bash
net::ip::is_private() {
    local ip="$1"
    net::ip::is_valid_v4 "$ip" || return 1
    [[ "$ip" =~ ^10\. ]] && return 0
    [[ "$ip" =~ ^192\.168\. ]] && return 0
    [[ "$ip" =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. ]] && return 0
    return 1
}
```

## Module

[`net`](../net.md)
