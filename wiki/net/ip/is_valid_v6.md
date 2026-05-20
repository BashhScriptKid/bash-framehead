# `net::ip::is_valid_v6`

Check if a string is a valid IPv6 address (basic check)

## Source

```bash
net::ip::is_valid_v6() {
    [[ "$1" =~ ^([0-9a-fA-F]{0,4}:){2,7}[0-9a-fA-F]{0,4}$ ]]
}
```

## Module

[`net`](../net.md)
