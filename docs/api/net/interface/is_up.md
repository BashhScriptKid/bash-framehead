# `net::interface::is_up`

**Signature:** `net::interface::is_up(arg1)`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if an interface is up

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
net::interface::is_up() {
    local iface="$1"
    if [[ -f "/sys/class/net/$iface/operstate" ]]; then
        [[ "$(cat "/sys/class/net/$iface/operstate")" == "up" ]]
    elif runtime::has_command ip; then
        ip link show "$iface" 2>/dev/null | grep -q 'state UP'
    fi
}
```

