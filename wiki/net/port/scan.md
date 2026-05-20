# `net::port::scan`

Scan common ports on a host, print open ones

## Usage

```bash
net::port::scan host [start_port] [end_port]
```

## Source

```bash
net::port::scan() {
    local host="$1" start="${2:-1}" end="${3:-1024}"
    local port
    for (( port=start; port<=end; port++ )); do
        net::port::is_open "$host" "$port" 1 && echo "$port"
    done
}
```

## Module

[`net`](../net.md)
