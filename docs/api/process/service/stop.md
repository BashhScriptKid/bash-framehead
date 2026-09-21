# `process::service::stop`

**Signature:** `process::service::stop(<service>)`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Stop a systemd service

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<service>` | string | Yes | |

## Source

```bash
process::service::stop() {
		if declare -f systemd::services::stop &>/dev/null; then
				systemd::services::stop "$@"
		elif runtime::has_command systemctl; then
				systemctl stop "$@"
		elif runtime::has_command service; then
				service "$1" stop
		fi
}
```

