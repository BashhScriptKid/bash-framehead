# `net::gateway`

**Signature:** `net::gateway(arg2, arg3)`

**Module:** [`net`](../net.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get default gateway

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg2` | string | Yes | |
| `arg3` | string | Yes | |

## Source

```bash
net::gateway() {
    if runtime::has_command ip; then
        ip route show default 2>/dev/null | awk '{print $3; exit}'
    elif runtime::has_command route; then
        route -n 2>/dev/null | awk '/^0\.0\.0\.0/{print $2; exit}'
    fi
}
```

