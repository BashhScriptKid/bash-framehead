# `process::service::is_enabled`

Check if a service is enabled at boot

## Source

```bash
process::service::is_enabled() {
    if runtime::has_command systemctl; then
        systemctl is-enabled --quiet "$1" 2>/dev/null
    fi
}
```

## Module

[`process`](../process.md)
