# `net::fetch::progress`

**Signature:** `net::fetch::progress(arg1)`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Fetch with progress bar

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

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

