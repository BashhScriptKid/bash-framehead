# `net::fetch`

**Signature:** `net::fetch(url, [output_file])`

**Module:** [`net`](../net.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

--- FETCH / DOWNLOAD ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `url` | string | Yes | |
| `output_file` | path | No | |

## Source

```bash
net::fetch() {
		local url="$1" out="${2:--}"
		if runtime::has_command curl; then
				if [[ "$out" == "-" ]]; then
						curl -sfL --max-time 30 "$url"
				else
						curl -sfL --max-time 30 -o "$out" "$url"
				fi
		elif runtime::has_command wget; then
				if [[ "$out" == "-" ]]; then
						wget -qO- --timeout=30 "$url"
				else
						wget -qO "$out" --timeout=30 "$url"
				fi
		else
				echo "net::fetch: requires curl or wget" >&2
				return 1
		fi
}
```

