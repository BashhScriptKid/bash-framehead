# `process::service::stop`

Stop a systemd service

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

## Module

[`process`](../process.md)
