# `process::service::is_running`

Check if a systemd service is running

## Usage

```bash
process::service::is_running service_name
```

## Source

```bash
process::service::is_running() {
    if runtime::has_command systemctl; then
        systemctl is-active --quiet "$1" 2>/dev/null
    elif runtime::has_command service; then
        service "$1" status >/dev/null 2>&1
    else
        process::is_running::name "$1"
    fi
}
```

## Module

[`process`](../process.md)
