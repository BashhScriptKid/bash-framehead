# `net::ip::public`

**Signature:** `net::ip::public()`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Get public IP address


## Source

```bash
net::ip::public() {
		local services=(
				"https://api.ipify.org"
				"https://ifconfig.me/ip"
				"https://icanhazip.com"
				"https://checkip.amazonaws.com"
		)
		local fetcher
		if runtime::has_command curl; then
				fetcher="curl -sf --max-time 5"
		elif runtime::has_command wget; then
				fetcher="wget -qO- --timeout=5"
		else
				echo "net::ip::public: requires curl or wget" >&2
				return 1
		fi

		for svc in "${services[@]}"; do
				local result
				result=$($fetcher "$svc" 2>/dev/null | tr -d '[:space:]')
				if [[ -n "$result" ]]; then
						echo "$result"
						return 0
				fi
		done

		echo "net::ip::public: all endpoints failed" >&2
		return 1
}
```

