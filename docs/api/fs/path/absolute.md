# `fs::path::absolute`

**Signature:** `fs::path::absolute(arg1)`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Get absolute path (resolves . and .. without requiring the path to exist)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::path::absolute() {
		local _path="$1"
		if [[ "$_path" != /* ]]; then
				_path="$(pwd)/$_path"
		fi
		# Resolve . and .. manually
		local -a parts=() result=()
		IFS='/' read -ra parts <<< "$_path"
		for part in "${parts[@]}"; do
				case "$part" in
						""|.) ;;
						..)   [[ ${#result[@]} -gt 0 ]] && unset 'result[-1]' ;;
						*)    result+=("$part") ;;
				esac
		done
		echo "/${result[*]// //}"
}
```

