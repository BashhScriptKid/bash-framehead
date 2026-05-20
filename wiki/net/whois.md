# `net::whois`

Basic whois lookup

## Source

```bash
net::whois() {
    if runtime::has_command whois; then
        whois "$1" 2>/dev/null
    else
        echo "net::whois: requires whois" >&2
        return 1
    fi
}
```

## Module

[`net`](../net.md)
