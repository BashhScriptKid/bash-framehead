# `process::service::restart`

**Signature:** `process::service::restart(<service>)`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Restart a systemd service

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<service>` | string | Yes | |

## Source

```bash
process::service::restart() {
		if declare -f systemd::services::restart &>/dev/null; then
				systemd::services::restart "$@"
		elif runtime::has_command systemctl; then
				systemctl restart "$@"
		elif runtime::has_command service; then
				service "$1" restart
		fi
}
```

