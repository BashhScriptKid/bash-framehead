# `kernel::bsd::security::hardlink_uid_match::set_system`

**Signature:** `kernel::bsd::security::hardlink_uid_match::set_system(arg1)`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::bsd::security::hardlink_uid_match::set_system() {
	runtime::is_root || { echo "kernel::bsd::security::hardlink_uid_match::set_system: requires root" >&2; return 1; }
	sysctl security.bsd.hardlink_check_uid="$1" 2>/dev/null || return 1
	_kernel::bsd::persist_sysctl "security.bsd.hardlink_check_uid" "$1"
}
```

