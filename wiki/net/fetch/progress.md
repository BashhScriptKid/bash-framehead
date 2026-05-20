# `net::fetch::progress`

Fetch with progress bar

## Source

```bash
net::fetch::progress() {
    local url="$1" out="${2:-$(basename "$url")}"
    if runtime::has_command curl; then
        curl -L --progress-bar -o "$out" "$url"
    elif runtime::has_command wget; then
        wget --progress=bar -O "$out" "$url"
    else
        echo "net::fetch::progress: requires curl or wget" >&2
        return 1
    fi
}
```

## Module

[`net`](../net.md)
