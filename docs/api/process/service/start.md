# `process::service::start`

**Signature:** `process::service::start(<service>)`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Start a systemd service

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<service>` | string | Yes | |

## Source

```bash
process::service::start() {
		if declare -f systemd::services::start &>/dev/null; then
				systemd::services::start "$@"
		elif runtime::has_command systemctl; then
				systemctl start "$@"
		elif runtime::has_command service; then
				service "$1" start
		fi
}
```

