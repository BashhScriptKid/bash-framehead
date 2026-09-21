# `pfloat::fixed::pow::fast`

**Signature:** `pfloat::fixed::pow::fast(result_var, arg1, arg2)`

**Module:** [`pfloat`](../../../pfloat.md) — [Guide](../../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
pfloat::fixed::pow::fast() {
	local -n _out=${@: -1}
	local base=$1 exp=$2 _b _sf i result
	_pfloat::_to_scaled::fast "$base" _b
	_sf=1; for ((i=0; i<pfloat_SCALE; i++)); do _sf+=0; done
	result=$_sf
	if ((exp < 0)); then
		exp=$((-exp))
		while ((exp-- > 0)); do result=$((result * _b / _sf)); done
		_pfloat::_from_scaled::fast $((_sf * _sf / result)) _out
	else
		while ((exp-- > 0)); do result=$((result * _b / _sf)); done
		_pfloat::_from_scaled::fast $((result)) _out
	fi
}
```

