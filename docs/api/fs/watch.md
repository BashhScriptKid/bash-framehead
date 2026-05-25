# `fs::watch`

**Signature:** `fs::watch(path, callback, [interval_seconds])`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- WATCHING ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `path` | path | Yes | |
| `callback` | function | Yes | |
| `interval_seconds` | integer | No | |

## Source

```bash
fs::watch() {
		local path="$1" callback="$2" interval="${3:-1}"
		local last_modified
		last_modified=$(fs::modified "$path")

		while true; do
				sleep "$interval"
				local current
				current=$(fs::modified "$path")
				if [[ "$current" != "$last_modified" ]]; then
						last_modified="$current"
						"$callback" "$path"
				fi
		done
}
```

