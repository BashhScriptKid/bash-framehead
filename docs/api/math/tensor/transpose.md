# `math::tensor::transpose`

**Signature:** `math::tensor::transpose(arg1, arg2)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
math::tensor::transpose() {
		local t=$1 perm=$2
		local dims data; dims=$(_math::tensor_shape_dims "$t"); data=$(_math::tensor_data "$t")
		local -a d v pa nd; read -ra d <<< "$dims"; read -ra v <<< "$data"
		IFS=',' read -ra pa <<< "$perm"
		local r=${#d[@]} i total=1
		for ((i = 0; i < r; i++)); do nd+=("${d[${pa[$i]}]}"); (( total *= d[i] )); done

		# Compute old and new strides (row-major, last dim stride=1)
		local -a old_str new_str
		local s=1
		for ((i = r - 1; i >= 0; i--)); do old_str[$i]=$s; (( s *= d[i] )); done
		s=1
		for ((i = r - 1; i >= 0; i--)); do new_str[$i]=$s; (( s *= nd[i] )); done

		# Inverse permutation: perm[i] = old axis → new axis position
		local -a inv_pa
		for ((i = 0; i < r; i++)); do inv_pa[${pa[$i]}]=$i; done

		local -a res new_coords
		local n
		for ((n = 0; n < total; n++)); do
				local rem=$n old_off=0 c
				for ((c = 0; c < r; c++)); do
						new_coords[$c]=$((rem / new_str[c]))
						(( rem %= new_str[c] ))
				done
				# Map new coords → old coords: new axis c came from old axis pa[c]
				for ((c = 0; c < r; c++)); do
						(( old_off += new_coords[c] * old_str[${pa[$c]}] ))
				done
				res+=("${v[$old_off]}")
		done
		echo "shape ${nd[*]}: ${res[*]}"
}
```

