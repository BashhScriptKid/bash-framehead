# `net::ip::is_valid_v4`

Check if a string is a valid IPv4 address

## Source

```bash
net::ip::is_valid_v4() {
    local ip="$1"
    [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
    local IFS='.'
    local -a octets=($ip)
    for o in "${octets[@]}"; do
        (( o >= 0 && o <= 255 )) || return 1
    done
}
```

## Module

[`net`](../net.md)
