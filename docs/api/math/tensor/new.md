# `math::tensor::new`

**Signature:** `math::tensor::new(arg1)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
math::tensor::new() {
		local shape=$1 data=${2:-}
		local -a dims; read -ra dims <<< "$shape"
		local size=1 d
		for d in "${dims[@]}"; do (( size *= d )); done
		if [[ -n "$data" ]]; then
				echo "shape $shape: $data"
		else
				local z; z=$(printf '0 %.0s' $(seq 1 $size))
				echo "shape $shape: ${z% }"
		fi
}
```

