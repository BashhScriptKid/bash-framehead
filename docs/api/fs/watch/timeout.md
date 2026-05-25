# `fs::watch::timeout`

**Signature:** `fs::watch::timeout(path, callback, timeout, [interval])`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Watch with a timeout (seconds)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `path` | path | Yes | |
| `callback` | function | Yes | |
| `timeout` | string | Yes | |
| `interval` | string | No | |

## Source

```bash
fs::watch::timeout() {
		local path="$1" callback="$2" timeout="$3" interval="${4:-1}"
		local elapsed=0
		local last_modified
		last_modified=$(fs::modified "$path")

		while (( elapsed < timeout )); do
				local current
				current=$(fs::modified "$path")
				if [[ "$current" != "$last_modified" ]]; then
						last_modified="$current"
						"$callback" "$path"
				fi
				(( elapsed += interval ))
				(( elapsed < timeout )) || break
				sleep "$interval"
		done
}
```

