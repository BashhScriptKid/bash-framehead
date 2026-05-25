# `process::service::is_running`

**Signature:** `process::service::is_running(service_name)`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- DAEMON / SERVICE ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `service_name` | variable | Yes | |

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

