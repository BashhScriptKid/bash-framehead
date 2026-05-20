# `net::http::headers`

Get response headers

## Source

```bash
net::http::headers() {
    if runtime::has_command curl; then
        curl -sI --max-time 10 "$1" 2>/dev/null
    elif runtime::has_command wget; then
        wget -qS --spider "$1" 2>&1
    fi
}
```

## Module

[`net`](../net.md)
