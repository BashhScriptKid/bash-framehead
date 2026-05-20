# `net::dns::propagation`

Check DNS propagation — query multiple public resolvers

## Usage

```bash
net::dns::propagation hostname
```

## Source

```bash
net::dns::propagation() {
    local host="$1"
    local -A resolvers=(
        ["Google"]="8.8.8.8"
        ["Cloudflare"]="1.1.1.1"
        ["Quad9"]="9.9.9.9"
        ["OpenDNS"]="208.67.222.222"
    )
    if ! runtime::has_command dig; then
        echo "net::dns::propagation: requires dig" >&2
        return 1
    fi
    for name in "${!resolvers[@]}"; do
        local ip="${resolvers[$name]}"
        local result
        result=$(dig +short "@$ip" "$host" 2>/dev/null | tr '\n' ' ')
        printf '%-12s %s\n' "$name" "${result:-[no result]}"
    done
}
```

## Module

[`net`](../net.md)
