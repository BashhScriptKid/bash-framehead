# `process::service::is_enabled`

**Signature:** `process::service::is_enabled(<service>)`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if a service is enabled at boot

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<service>` | string | Yes | |

## Source

```bash
process::service::is_enabled() {
		if declare -f systemd::services::isenabled &>/dev/null; then
				systemd::services::isenabled "$1"
		elif runtime::has_command systemctl; then
				systemctl is-enabled --quiet "$1" 2>/dev/null
		fi
}
```

