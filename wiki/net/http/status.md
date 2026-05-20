# `net::http::status`

Check HTTP status code of a URL

## Usage

```bash
net::http::status url
```

## Source

```bash
net::http::status() {
    if runtime::has_command curl; then
        curl -sLo /dev/null -w '%{http_code}' --max-time 10 "$1" 2>/dev/null
    elif runtime::has_command wget; then
        wget -qS --spider "$1" 2>&1 | awk '/HTTP\//{print $2}' | tail -1
    fi
}
```

## Module

[`net`](../net.md)
