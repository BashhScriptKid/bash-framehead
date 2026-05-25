# `net::ip::is_valid_v4`

**Signature:** `net::ip::is_valid_v4(arg1)`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if a string is a valid IPv4 address

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
net::ip::is_valid_v4() {
		local ip="$1"
		[[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
		local IFS='.'
# shellcheck disable=SC2206
		local -a octets=($ip)
		for o in "${octets[@]}"; do
				(( o >= 0 && o <= 255 )) || return 1
		done
}
```

