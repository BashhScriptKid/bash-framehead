# `net::resolve::reverse`

Reverse DNS lookup — IP to hostname

## Usage

```bash
net::resolve::reverse ip
```

## Source

```bash
net::resolve::reverse() {
    if runtime::has_command dig; then
        dig +short -x "$1" 2>/dev/null
    elif runtime::has_command nslookup; then
        nslookup "$1" 2>/dev/null | awk '/name =/{print $NF}'
    elif runtime::has_command getent; then
        getent hosts "$1" 2>/dev/null | awk '{print $NF}'
    fi
}
```

## Module

[`net`](../net.md)
