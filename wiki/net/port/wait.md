# `net::port::wait`

Wait until a port is open (useful for service readiness checks)

## Usage

```bash
net::port::wait host port [timeout_seconds] [interval]
```

## Source

```bash
net::port::wait() {
    local host="$1" port="$2" timeout="${3:-30}" interval="${4:-1}"
    local elapsed=0
    while (( elapsed < timeout )); do
        net::port::is_open "$host" "$port" && return 0
        sleep "$interval"
        (( elapsed += interval ))
    done
    return 1
}
```

## Module

[`net`](../net.md)
