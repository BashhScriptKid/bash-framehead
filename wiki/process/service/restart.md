# `process::service::restart`

Restart a systemd service

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

## Module

[`process`](../process.md)
