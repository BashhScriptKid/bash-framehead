# `net::dns::records`

Get all DNS records of a type

## Usage

```bash
net::dns::records hostname [type]
```

## Source

```bash
net::dns::records() {
    local host="$1" type="${2:-A}"
    if runtime::has_command dig; then
        dig +short "$host" "$type" 2>/dev/null
    elif runtime::has_command nslookup; then
        nslookup -type="$type" "$host" 2>/dev/null
    fi
}
```

## Module

[`net`](../net.md)
