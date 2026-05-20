# `net::fetch`

Fetch URL contents — curl/wget with fallback

## Usage

```bash
net::fetch url [output_file]
```

## Source

```bash
net::fetch() {
    local url="$1" out="${2:--}"
    if runtime::has_command curl; then
        if [[ "$out" == "-" ]]; then
            curl -sfL --max-time 30 "$url"
        else
            curl -sfL --max-time 30 -o "$out" "$url"
        fi
    elif runtime::has_command wget; then
        if [[ "$out" == "-" ]]; then
            wget -qO- --timeout=30 "$url"
        else
            wget -qO "$out" --timeout=30 "$url"
        fi
    else
        echo "net::fetch: requires curl or wget" >&2
        return 1
    fi
}
```

## Module

[`net`](../net.md)
