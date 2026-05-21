# `net::resolve::reverse`

**Signature:** `net::resolve::reverse(ip)`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Reverse DNS lookup — IP to hostname

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `ip` | string | Yes | |

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

