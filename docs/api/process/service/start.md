# `process::service::start`

**Signature:** `process::service::start(arg1)`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Start a systemd service

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
process::service::start() {
    if runtime::has_command systemctl; then
        systemctl start "$1"
    elif runtime::has_command service; then
        service "$1" start
    fi
}
```

