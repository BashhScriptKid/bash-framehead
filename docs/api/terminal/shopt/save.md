# `terminal::shopt::save`

**Signature:** `terminal::shopt::save(eval, $(terminal::shopt::save))`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Save current shopt state (prints a restore command)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `eval` | string | Yes | |
| `$(terminal::shopt::save)` | string | Yes | |

## Source

```bash
terminal::shopt::save() {
		shopt | awk '$2 == "on"  {print "shopt -s " $1 ";"}'
		shopt | awk '$2 == "off" {print "shopt -u " $1 ";"}'
}
```

