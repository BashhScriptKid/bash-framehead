# `process::service::restart`

**Signature:** `process::service::restart(arg1)`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Restart a systemd service

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
process::service::restart() {
    if runtime::has_command systemctl; then
        systemctl restart "$1"
    elif runtime::has_command service; then
        service "$1" restart
    fi
}
```

