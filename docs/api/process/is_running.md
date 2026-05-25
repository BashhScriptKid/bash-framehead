# `process::is_running`

**Signature:** `process::is_running(pid)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

!/usr/bin/env bash

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `pid` | integer | Yes | |

## Source

```bash
process::is_running() {
		kill -0 "$1" 2>/dev/null
}
```

