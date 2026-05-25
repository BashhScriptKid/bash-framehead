# `pfloat::fixed::sigmoid`

**Signature:** `pfloat::fixed::sigmoid(arg1)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
pfloat::fixed::sigmoid() {
	local x="$1"
	local neg_x exp_val

	if pfloat::fixed::is_negative "$x"; then
		neg_x=$(pfloat::fixed::neg "$x")
		exp_val=$(_pfloat::_exp_approx "$neg_x")
		pfloat::fixed::div "1" $(pfloat::fixed::add "1" "$exp_val")
	else
		exp_val=$(_pfloat::_exp_approx "$x")
		pfloat::fixed::div "$exp_val" $(pfloat::fixed::add "1" "$exp_val")
	fi
}
```

