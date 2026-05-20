# `net::http::is_ok`

Check if a URL returns 200 OK

## Source

```bash
net::http::is_ok() {
    [[ "$(net::http::status "$1")" == "200" ]]
}
```

## Module

[`net`](../net.md)
