# `net::whois`

**Signature:** `net::whois(arg1)`

**Module:** [`net`](../net.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Basic whois lookup

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
net::whois() {
    if runtime::has_command whois; then
        whois "$1" 2>/dev/null
    else
        echo "net::whois: requires whois" >&2
        return 1
    fi
}
```

