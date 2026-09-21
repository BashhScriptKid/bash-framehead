# `runtime::features::has`

**Signature:** `runtime::features::has(arg1)`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
runtime::features::has() {
	(( _RUNTIME_FEATURES_READY )) || _runtime::features_scan
	local _bit
	case $1 in
		param_transform)  _bit=0 ;;
		case_modify)      _bit=1 ;;
		nameref)          _bit=2 ;;
		assoc_array)      _bit=3 ;;
		assoc_dump)       _bit=4 ;;
		assoc_kv)         _bit=5 ;;
		epoch_realtime)   _bit=6 ;;
		bash_monoseconds) _bit=7 ;;
		globsort)         _bit=8 ;;
		unset_array_all)  _bit=9 ;;
		wait_n_p)         _bit=10 ;;
		mapfile_delim)    _bit=11 ;;
		*)                return 1 ;;
	esac
	(( _RUNTIME_FEATURES & (1 << _bit) ))
}
```

