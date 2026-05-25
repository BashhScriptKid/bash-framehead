# `string::colon::add`

**Signature:** `string::colon::add(value, dir, [after|before])`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

COLON-SEPARATED VARIABLES

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `value` | string | Yes | |
| `dir` | string | Yes | |
| `after|before` | string | No | |

## Source

```bash
string::colon::add() {
	local _value="$1" _dir="$2" _pos="${3:-after}"

	if [[ -z $_dir || $_dir == *:* ]]; then
		echo "string::colon::add: invalid argument: '$_dir'" >&2
		return 1
	fi

	local -a _arr
	IFS=: read -ra _arr <<< "$_value"

	# Skip if already present
	local _entry
	for _entry in "${_arr[@]}"; do
		[[ $_entry == "$_dir" ]] && { echo "$_value"; return 0; }
	done

	case "$_pos" in
		after) _arr+=("$_dir");;
		*) local -a _tmp=("$_dir"); _tmp+=("${_arr[@]}"); _arr=("${_tmp[@]}");;
	esac

	(IFS=:; echo "${_arr[*]}")
}
```

