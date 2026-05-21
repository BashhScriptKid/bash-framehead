# `process::service::stop`

**Signature:** `process::service::stop(arg1)`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Stop a systemd service

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
process::service::stop() {
    if runtime::has_command systemctl; then
        systemctl stop "$1"
    elif runtime::has_command service; then
        service "$1" stop
    fi
}
```

