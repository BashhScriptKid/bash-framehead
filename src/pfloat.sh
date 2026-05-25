#!/usr/bin/env bash
# needs runtime.sh
# i actually dont want to kms anymore i think
# numbers are scaled by 10^pfloat_SCALE
# pfloat_SCALE defaults to 5 (balance between precision and overflow prevention)
# For more precision, set pfloat_SCALE before sourcing (max recommended: 8 for 64-bit safety)
# Warning: setting scale to 10 will risk integer overflow.

pfloat_SCALE="${pfloat_SCALE:-5}"

_pfloat::_scale_factor() {
	local s="1" i
	for ((i = 0; i < pfloat_SCALE; i++)); do s+="0"; done
	echo "$s"
}

_pfloat::_to_scaled() {
	local num="$1"
	local sign="" int_part frac_part result

	if [[ "$num" == -* ]]; then
		sign="-"
		num="${num#-}"
	fi

	if [[ "$num" == *.* ]]; then
		int_part="${num%%.*}"
		frac_part="${num#*.}"
	else
		int_part="$num"
		frac_part=""
	fi

	int_part="${int_part#"${int_part%%[!0]*}"}"
	[[ -z "$int_part" ]] && int_part="0"

	while ((${#frac_part} < pfloat_SCALE)); do
		frac_part+="0"
	done
	frac_part="${frac_part:0:$pfloat_SCALE}"

	result="${int_part}${frac_part}"
	result="${result#"${result%%[!0]*}"}"
	[[ -z "$result" ]] && result="0"

	echo "${sign}${result}"
}

_pfloat::_from_scaled() {
	local num="$1"
	local sign="" int_part frac_part

	if [[ "$num" == -* ]]; then
		sign="-"
		num="${num#-}"
	fi

	num="${num#"${num%%[!0]*}"}"
	[[ -z "$num" ]] && num="0"

	while ((${#num} <= pfloat_SCALE)); do
		num="0${num}"
	done

	int_part="${num:0:${#num}-pfloat_SCALE}"
	frac_part="${num:${#num}-pfloat_SCALE}"

	while [[ "$frac_part" == *0 ]]; do
		frac_part="${frac_part%0}"
	done

	if [[ -z "$frac_part" ]]; then
		echo "${sign}${int_part}"
	else
		echo "${sign}${int_part}.${frac_part}"
	fi
}

_pfloat::_abs() {
	local n="$1"
	[[ "$n" == -* ]] && echo "${n#-}" || echo "$n"
}

# Check if a value is an integer (no decimal point)
_pfloat::_is_integer() {
	[[ "$1" =~ ^-?[0-9]+$ ]]
}

pfloat::fixed::add() {
	local a_scaled b_scaled result
	a_scaled=$(_pfloat::_to_scaled "$1")
	b_scaled=$(_pfloat::_to_scaled "$2")
	result=$((a_scaled + b_scaled))
	_pfloat::_from_scaled "$result"
}

pfloat::fixed::sub() {
	local a_scaled b_scaled result
	a_scaled=$(_pfloat::_to_scaled "$1")
	b_scaled=$(_pfloat::_to_scaled "$2")
	result=$((a_scaled - b_scaled))
	_pfloat::_from_scaled "$result"
}

pfloat::fixed::mul() {
	local a="$1" b="$2"

	# Fast path for integers - avoid overflow from scaling
	if _pfloat::_is_integer "$a" && _pfloat::_is_integer "$b"; then
		echo "$((a * b))"
		return
	fi

	local a_scaled b_scaled result scale_factor
	a_scaled=$(_pfloat::_to_scaled "$a")
	b_scaled=$(_pfloat::_to_scaled "$b")
	scale_factor=$(_pfloat::_scale_factor)
	result=$(((a_scaled * b_scaled) / scale_factor))
	_pfloat::_from_scaled "$result"
}

pfloat::fixed::div() {
	local a_scaled b_scaled result scale_factor
	a_scaled=$(_pfloat::_to_scaled "$1")
	b_scaled=$(_pfloat::_to_scaled "$2")

	if ((b_scaled == 0)); then
		echo "pfloat::fixed::div: division by zero" >&2
		return 1
	fi

	scale_factor=$(_pfloat::_scale_factor)
	result=$(((a_scaled * scale_factor) / b_scaled))
	_pfloat::_from_scaled "$result"
}

pfloat::fixed::mod() {
	local a_scaled b_scaled result
	a_scaled=$(_pfloat::_to_scaled "$1")
	b_scaled=$(_pfloat::_to_scaled "$2")

	if ((b_scaled == 0)); then
		echo "pfloat::fixed::mod: division by zero" >&2
		return 1
	fi

	result=$((a_scaled % b_scaled))
	_pfloat::_from_scaled "$result"
}

pfloat::fixed::neg() {
	local a_scaled
	a_scaled=$(_pfloat::_to_scaled "$1")
	_pfloat::_from_scaled "$((-a_scaled))"
}

pfloat::fixed::abs() {
	local a_scaled
	a_scaled=$(_pfloat::_to_scaled "$1")
	a_scaled=$(_pfloat::_abs "$a_scaled")
	_pfloat::_from_scaled "$a_scaled"
}

pfloat::fixed::eq() {
	local a b
	a=$(_pfloat::_to_scaled "$1")
	b=$(_pfloat::_to_scaled "$2")
	((a == b))
}

pfloat::fixed::ne() {
	local a b
	a=$(_pfloat::_to_scaled "$1")
	b=$(_pfloat::_to_scaled "$2")
	((a != b))
}

pfloat::fixed::lt() {
	local a b
	a=$(_pfloat::_to_scaled "$1")
	b=$(_pfloat::_to_scaled "$2")
	((a < b))
}

pfloat::fixed::le() {
	local a b
	a=$(_pfloat::_to_scaled "$1")
	b=$(_pfloat::_to_scaled "$2")
	((a <= b))
}

pfloat::fixed::gt() {
	local a b
	a=$(_pfloat::_to_scaled "$1")
	b=$(_pfloat::_to_scaled "$2")
	((a > b))
}

pfloat::fixed::ge() {
	local a b
	a=$(_pfloat::_to_scaled "$1")
	b=$(_pfloat::_to_scaled "$2")
	((a >= b))
}

pfloat::fixed::is_zero() {
	local a
	a=$(_pfloat::_to_scaled "$1")
	((a == 0))
}

pfloat::fixed::is_positive() {
	local a
	a=$(_pfloat::_to_scaled "$1")
	((a > 0))
}

pfloat::fixed::is_negative() {
	local a
	a=$(_pfloat::_to_scaled "$1")
	((a < 0))
}

pfloat::fixed::floor() {
	local a="$1" sign="" int_part frac_part

	if [[ "$a" == -* ]]; then
		sign="-"
		a="${a#-}"
	fi

	if [[ "$a" == *.* ]]; then
		int_part="${a%%.*}"
		frac_part="${a#*.}"
	else
		echo "$a"
		return
	fi

	[[ -z "$int_part" ]] && int_part="0"

	if [[ "$sign" == "-" ]] && [[ "$frac_part" != "0" ]] && [[ "$frac_part" != "" ]]; then
		int_part=$((int_part + 1))
		echo "-${int_part}"
	else
		echo "${sign}${int_part}"
	fi
}

pfloat::fixed::ceil() {
	local a="$1" sign="" int_part frac_part

	if [[ "$a" == -* ]]; then
		sign="-"
		a="${a#-}"
	fi

	if [[ "$a" == *.* ]]; then
		int_part="${a%%.*}"
		frac_part="${a#*.}"
	else
		echo "$a"
		return
	fi

	[[ -z "$int_part" ]] && int_part="0"

	if [[ "$frac_part" =~ [1-9] ]]; then
		if [[ "$sign" == "-" ]]; then
			echo "${sign}${int_part}"
		else
			echo "$((int_part + 1))"
		fi
	else
		echo "${sign}${int_part}"
	fi
}

pfloat::fixed::round() {
	local a="$1" sign="" int_part frac_part first_digit

	if [[ "$a" == -* ]]; then
		sign="-"
		a="${a#-}"
	fi

	if [[ "$a" == *.* ]]; then
		int_part="${a%%.*}"
		frac_part="${a#*.}"
	else
		echo "$a"
		return
	fi

	[[ -z "$int_part" ]] && int_part="0"
	first_digit="${frac_part:0:1}"

	if ((first_digit >= 5)); then
		if [[ "$sign" == "-" ]]; then
			echo "-$((int_part + 1))"
		else
			echo "$((int_part + 1))"
		fi
	else
		echo "${sign}${int_part}"
	fi
}

pfloat::fixed::trunc() {
	local a="$1"

	if [[ "$a" == *.* ]]; then
		a="${a%%.*}"
	fi

	[[ -z "$a" ]] && a="0"
	echo "$a"
}

pfloat::fixed::min() {
	local a b
	a=$(_pfloat::_to_scaled "$1")
	b=$(_pfloat::_to_scaled "$2")
	if ((a < b)); then
		_pfloat::_from_scaled "$a"
	else
		_pfloat::_from_scaled "$b"
	fi
}

pfloat::fixed::max() {
	local a b
	a=$(_pfloat::_to_scaled "$1")
	b=$(_pfloat::_to_scaled "$2")
	if ((a > b)); then
		_pfloat::_from_scaled "$a"
	else
		_pfloat::_from_scaled "$b"
	fi
}

pfloat::fixed::clamp() {
	local val lo hi val_s lo_s hi_s
	val_s=$(_pfloat::_to_scaled "$1")
	lo_s=$(_pfloat::_to_scaled "$2")
	hi_s=$(_pfloat::_to_scaled "$3")

	if ((val_s < lo_s)); then
		_pfloat::_from_scaled "$lo_s"
	elif ((val_s > hi_s)); then
		_pfloat::_from_scaled "$hi_s"
	else
		_pfloat::_from_scaled "$val_s"
	fi
}

pfloat::fixed::sqr() {
	pfloat::fixed::mul "$1" "$1"
}

pfloat::fixed::sqrt() {
	local num="$1" iterations="${2:-20}"
	local guess prev_guess i

	if pfloat::fixed::is_negative "$num"; then
		echo "pfloat::fixed::sqrt: negative input" >&2
		return 1
	fi

	if pfloat::fixed::is_zero "$num"; then
		echo "0"
		return
	fi

	if pfloat::fixed::gt "$num" "1"; then
		guess=$(pfloat::fixed::div "$num" "2")
	else
		guess="1"
	fi

	for ((i = 0; i < iterations; i++)); do
		prev_guess="$guess"
		guess=$(pfloat::fixed::div $(pfloat::fixed::add "$guess" $(pfloat::fixed::div "$num" "$guess")) "2")

		if pfloat::fixed::eq "$guess" "$prev_guess"; then
			break
		fi
	done

	echo "$guess"
}

pfloat::fixed::pow() {
	local base="$1" exp="$2"
	local result="1"
	local neg_exp=0

	if ((exp < 0)); then
		neg_exp=1
		exp=$((-exp))
	fi

	while ((exp > 0)); do
		if ((exp % 2 == 1)); then
			result=$(pfloat::fixed::mul "$result" "$base")
		fi
		base=$(pfloat::fixed::mul "$base" "$base")
		exp=$((exp / 2))
	done

	if ((neg_exp)); then
		pfloat::fixed::div "1" "$result"
	else
		echo "$result"
	fi
}

pfloat::fixed::cbrt() {
	local num="$1" iterations="${2:-30}"
	local guess i sign=""

	if pfloat::fixed::is_negative "$num"; then
		sign="-"
		num=$(pfloat::fixed::neg "$num")
	fi

	if pfloat::fixed::is_zero "$num"; then
		echo "0"
		return
	fi

	guess=$(pfloat::fixed::div "$num" "3")
	[[ "$guess" == "0" ]] && guess="1"

	for ((i = 0; i < iterations; i++)); do
		local x2
		x2=$(pfloat::fixed::mul "$guess" "$guess")
		guess=$(pfloat::fixed::div $(pfloat::fixed::add $(pfloat::fixed::mul "2" "$guess") $(pfloat::fixed::div "$num" "$x2")) "3")
	done

	if [[ -n "$sign" ]]; then
		echo "-${guess}"
	else
		echo "$guess"
	fi
}

pfloat::fixed::sum() {
	local total="0"
	for n in "$@"; do
		total=$(pfloat::fixed::add "$total" "$n")
	done
	echo "$total"
}

pfloat::fixed::avg() {
	local count=$#
	((count == 0)) && {
		echo "pfloat::fixed::avg: no arguments" >&2
		return 1
	}

	local total
	total=$(pfloat::fixed::sum "$@")
	pfloat::fixed::div "$total" "$count"
}

pfloat::fixed::lerp() {
	local a="$1" b="$2" t="$3"
	local diff scaled
	diff=$(pfloat::fixed::sub "$b" "$a")
	scaled=$(pfloat::fixed::mul "$diff" "$t")
	pfloat::fixed::add "$a" "$scaled"
}

pfloat::fixed::inv_lerp() {
	local v="$1" a="$2" b="$3"
	local num den
	num=$(pfloat::fixed::sub "$v" "$a")
	den=$(pfloat::fixed::sub "$b" "$a")
	pfloat::fixed::div "$num" "$den"
}

pfloat::fixed::map() {
	local v="$1" imin="$2" imax="$3" omin="$4" omax="$5"
	local t
	t=$(pfloat::fixed::inv_lerp "$v" "$imin" "$imax")
	pfloat::fixed::lerp "$omin" "$omax" "$t"
}

pfloat::fixed::normalize() {
	local v="$1" lo="$2" hi="$3"
	pfloat::fixed::inv_lerp "$v" "$lo" "$hi"
}

pfloat::fixed::percent() {
	local part="$1" total="$2"
	local ratio
	ratio=$(pfloat::fixed::div "$part" "$total")
	pfloat::fixed::mul "$ratio" "100"
}

pfloat::fixed::percent_of() {
	local pct="$1" total="$2"
	pfloat::fixed::mul "$total" $(pfloat::fixed::div "$pct" "100")
}

pfloat::fixed::percent_change() {
	local old="$1" new="$2"
	local diff
	diff=$(pfloat::fixed::sub "$new" "$old")
	pfloat::fixed::mul $(pfloat::fixed::div "$diff" "$old") "100"
}

pfloat::fixed::dist2() {
	local x1="$1" y1="$2" x2="$3" y2="$4"
	local dx dy dx2 dy2 sum
	dx=$(pfloat::fixed::sub "$x1" "$x2")
	dy=$(pfloat::fixed::sub "$y1" "$y2")
	dx2=$(pfloat::fixed::mul "$dx" "$dx")
	dy2=$(pfloat::fixed::mul "$dy" "$dy")
	sum=$(pfloat::fixed::add "$dx2" "$dy2")
	pfloat::fixed::sqrt "$sum"
}

pfloat::fixed::dist3() {
	local x1="$1" y1="$2" z1="$3" x2="$4" y2="$5" z2="$6"
	local dx dy dz dx2 dy2 dz2 sum
	dx=$(pfloat::fixed::sub "$x1" "$x2")
	dy=$(pfloat::fixed::sub "$y1" "$y2")
	dz=$(pfloat::fixed::sub "$z1" "$z2")
	dx2=$(pfloat::fixed::mul "$dx" "$dx")
	dy2=$(pfloat::fixed::mul "$dy" "$dy")
	dz2=$(pfloat::fixed::mul "$dz" "$dz")
	sum=$(pfloat::fixed::add "$dx2" "$dy2" "$dz2")
	pfloat::fixed::sqrt "$sum"
}

pfloat::fixed::sign() {
	local a="$1"
	if pfloat::fixed::is_negative "$a"; then
		echo "-1"
	elif pfloat::fixed::is_positive "$a"; then
		echo "1"
	else
		echo "0"
	fi
}

pfloat::fixed::recip() {
	pfloat::fixed::div "1" "$1"
}

pfloat::fixed::mean() {
	pfloat::fixed::avg "$1" "$2"
}

pfloat::fixed::geomean() {
	local a="$1" b="$2"
	local prod
	prod=$(pfloat::fixed::mul "$a" "$b")
	pfloat::fixed::sqrt "$prod"
}

pfloat::fixed::harmean() {
	local a="$1" b="$2"
	local sum prod
	sum=$(pfloat::fixed::add "$a" "$b")
	prod=$(pfloat::fixed::mul "$a" "$b")
	pfloat::fixed::div $(pfloat::fixed::mul "2" "$prod") "$sum"
}

pfloat::fixed::factorial() {
	local n="$1"
	local result="1" i

	if [[ "$n" == -* ]]; then
		echo "pfloat::fixed::factorial: negative input" >&2
		return 1
	fi

	n=$(pfloat::fixed::trunc "$n")

	for ((i = 2; i <= n; i++)); do
		result=$(pfloat::fixed::mul "$result" "$i")
	done
	echo "$result"
}

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

_pfloat::_exp_approx() {
	local x="$1"
	local result="1" term="$1" i

	for ((i = 1; i < 15; i++)); do
		term=$(pfloat::fixed::mul "$term" "$x")
		term=$(pfloat::fixed::div "$term" "$i")
		result=$(pfloat::fixed::add "$result" "$term")
	done
	echo "$result"
}

pfloat::fixed::softplus() {
	local x="$1"
	local exp_val one_plus_exp

	if pfloat::fixed::lt "$x" "-10"; then
		echo "0"
		return
	fi

	exp_val=$(_pfloat::_exp_approx "$x")
	one_plus_exp=$(pfloat::fixed::add "1" "$exp_val")

	_pfloat::_ln_approx "$one_plus_exp"
}

_pfloat::_ln_approx() {
	local x="$1"
	local y="1" i iterations=20

	if pfloat::fixed::le "$x" "0"; then
		echo "0"
		return
	fi

	for ((i = 0; i < iterations; i++)); do
		local _exp_y num den delta
		_exp_y=$(_pfloat::_exp_approx "$y")
		num=$(pfloat::fixed::mul "2" $(pfloat::fixed::sub "$x" "$_exp_y"))
		den=$(pfloat::fixed::add "$x" "$_exp_y")
		delta=$(pfloat::fixed::div "$num" "$den")
		y=$(pfloat::fixed::add "$y" "$delta")
	done
	echo "$y"
}

# ==============================================================================
# BACKWARD COMPATIBILITY WRAPPERS
# These aliases maintain compatibility with code using pfloat::* directly
# ==============================================================================

pfloat::add() { pfloat::fixed::add "$@"; }
pfloat::sub() { pfloat::fixed::sub "$@"; }
pfloat::mul() { pfloat::fixed::mul "$@"; }
pfloat::div() { pfloat::fixed::div "$@"; }
pfloat::mod() { pfloat::fixed::mod "$@"; }
pfloat::neg() { pfloat::fixed::neg "$@"; }
pfloat::abs() { pfloat::fixed::abs "$@"; }
pfloat::eq() { pfloat::fixed::eq "$@"; }
pfloat::ne() { pfloat::fixed::ne "$@"; }
pfloat::lt() { pfloat::fixed::lt "$@"; }
pfloat::le() { pfloat::fixed::le "$@"; }
pfloat::gt() { pfloat::fixed::gt "$@"; }
pfloat::ge() { pfloat::fixed::ge "$@"; }
pfloat::is_zero() { pfloat::fixed::is_zero "$@"; }
pfloat::is_positive() { pfloat::fixed::is_positive "$@"; }
pfloat::is_negative() { pfloat::fixed::is_negative "$@"; }
pfloat::floor() { pfloat::fixed::floor "$@"; }
pfloat::ceil() { pfloat::fixed::ceil "$@"; }
pfloat::round() { pfloat::fixed::round "$@"; }
pfloat::trunc() { pfloat::fixed::trunc "$@"; }
pfloat::min() { pfloat::fixed::min "$@"; }
pfloat::max() { pfloat::fixed::max "$@"; }
pfloat::clamp() { pfloat::fixed::clamp "$@"; }
pfloat::sqr() { pfloat::fixed::sqr "$@"; }
pfloat::sqrt() { pfloat::fixed::sqrt "$@"; }
pfloat::pow() { pfloat::fixed::pow "$@"; }
pfloat::cbrt() { pfloat::fixed::cbrt "$@"; }
pfloat::sum() { pfloat::fixed::sum "$@"; }
pfloat::avg() { pfloat::fixed::avg "$@"; }
pfloat::lerp() { pfloat::fixed::lerp "$@"; }
pfloat::inv_lerp() { pfloat::fixed::inv_lerp "$@"; }
pfloat::map() { pfloat::fixed::map "$@"; }
pfloat::normalize() { pfloat::fixed::normalize "$@"; }
pfloat::percent() { pfloat::fixed::percent "$@"; }
pfloat::percent_of() { pfloat::fixed::percent_of "$@"; }
pfloat::percent_change() { pfloat::fixed::percent_change "$@"; }
pfloat::dist2() { pfloat::fixed::dist2 "$@"; }
pfloat::dist3() { pfloat::fixed::dist3 "$@"; }
pfloat::sign() { pfloat::fixed::sign "$@"; }
pfloat::recip() { pfloat::fixed::recip "$@"; }
pfloat::mean() { pfloat::fixed::mean "$@"; }
pfloat::geomean() { pfloat::fixed::geomean "$@"; }
pfloat::harmean() { pfloat::fixed::harmean "$@"; }
pfloat::factorial() { pfloat::fixed::factorial "$@"; }
pfloat::sigmoid() { pfloat::fixed::sigmoid "$@"; }
pfloat::softplus() { pfloat::fixed::softplus "$@"; }

# ==============================================================================
# IEEE 754 DOUBLE-PRECISION IMPLEMENTATION
# Pure Bash IEEE 754 floating-point arithmetic
# Uses 64-bit fixed-point representation internally
# ==============================================================================

# IEEE 754 Double-precision constants
readonly IEEE754_SIGN_BIT=63
readonly IEEE754_EXP_BITS=11
readonly IEEE754_MANT_BITS=52
readonly IEEE754_EXP_BIAS=1023
readonly IEEE754_EXP_MAX=2047
readonly IEEE754_MANT_MASK=4503599627370495  # 0xFFFFFFFFFFFFF
readonly IEEE754_EXP_MASK=9218868437227405312  # 0x7FF0000000000000
readonly IEEE754_SIGN_MASK=9223372036854775808  # 0x8000000000000000

# Internal: Extract sign bit from 64-bit pattern
_ieee754::get_sign() {
	local bits="$1"
	echo $(( (bits >> 63) & 1 ))
}

# Internal: Extract exponent from 64-bit pattern
_ieee754::get_exp() {
	local bits="$1"
	echo $(( (bits >> 52) & 2047 ))
}

# Internal: Extract mantissa from 64-bit pattern
_ieee754::get_mant() {
	local bits="$1"
	echo $(( bits & 4503599627370495 ))
}

# Internal: Pack sign, exp, mant into 64-bit pattern
_ieee754::pack() {
	local sign="$1" exp="$2" mant="$3"
	echo $(( (sign << 63) | (exp << 52) | mant ))
}

# Internal: Check if value is NaN
_ieee754::is_nan() {
	local bits="$1"
	local exp=$(_ieee754::get_exp "$bits")
	local mant=$(_ieee754::get_mant "$bits")
	((exp == 2047 && mant != 0))
}

# Internal: Check if value is Infinity
_ieee754::is_inf() {
	local bits="$1"
	local exp=$(_ieee754::get_exp "$bits")
	local mant=$(_ieee754::get_mant "$bits")
	((exp == 2047 && mant == 0))
}

# Internal: Check if value is zero
_ieee754::is_zero() {
	local bits="$1"
	local exp=$(_ieee754::get_exp "$bits")
	local mant=$(_ieee754::get_mant "$bits")
	((exp == 0 && mant == 0))
}

# Internal: Check if value is subnormal
_ieee754::is_subnormal() {
	local bits="$1"
	local exp=$(_ieee754::get_exp "$bits")
	((exp == 0))
}

# Internal: Convert decimal string to IEEE 754 double
# Uses fixed-point intermediate representation for precision
_ieee754::from_string() {
	local str="$1"
	local sign=0

	if [[ "$str" == -* ]]; then
		sign=1
		str="${str#-}"
	fi

	case "$str" in
		inf|Inf|infinity|Infinity) echo $((sign << 63 | 2047 << 52)); return ;;
		nan|NaN) echo $((2047 << 52 | 1)); return ;;
	esac

	local int_part frac_part=""
	if [[ "$str" == *.* ]]; then
		int_part="${str%%.*}"
		frac_part="${str#*.}"
	else
		int_part="$str"
	fi

	int_part="${int_part#"${int_part%%[!0]*}"}"
	[[ -z "$int_part" ]] && int_part="0"

	if [[ "$int_part" == "0" ]] && [[ -z "$frac_part" || "$frac_part" =~ ^0+$ ]]; then
		echo $((sign << 63))
		return
	fi

	# Convert to numerator / denominator
	local frac_len=${#frac_part}
	while [[ -n "$frac_part" && "${frac_part: -1}" == "0" ]]; do
		frac_part="${frac_part%0}"
		((frac_len--))
	done

	local numerator denominator
	if ((frac_len > 0)); then
		denominator=1
		local _i
		for ((_i = 0; _i < frac_len; _i++)); do
			denominator=$((denominator * 10))
		done
		numerator=$((int_part * denominator + frac_part))
	else
		numerator=$int_part
		denominator=1
	fi

	# Binary long division: normalize to 1 <= numerator/denominator < 2
	local exp=0

	while ((numerator < denominator)); do
		if ((numerator > (1 << 62))); then
			numerator=$((numerator >> 1))
			denominator=$((denominator >> 1))
		fi
		numerator=$((numerator << 1))
		((exp--))
	done

	while ((numerator >= denominator * 2)); do
		denominator=$((denominator << 1))
		((exp++))
	done

	# Remove implicit leading 1
	numerator=$((numerator - denominator))

	# Extract 52 mantissa bits
	local mant=0 i
	for ((i = 51; i >= 0; i--)); do
		numerator=$((numerator << 1))
		if ((numerator >= denominator)); then
			mant=$((mant | (1 << i)))
			numerator=$((numerator - denominator))
		fi
	done

	# Round to nearest, ties to even
	if ((numerator * 2 > denominator || (numerator * 2 == denominator && (mant & 1)))); then
		mant=$((mant + 1))
		if ((mant >= (1 << 52))); then
			mant=0
			((exp++))
		fi
	fi

	local ieee_exp=$((exp + 1023))
	if ((ieee_exp <= 0)); then
		echo $((sign << 63))
		return
	fi
	if ((ieee_exp >= 2047)); then
		echo $((sign << 63 | 2047 << 52))
		return
	fi

	echo $(( (sign << 63) | (ieee_exp << 52) | mant ))
}

# Internal: Convert IEEE 754 double to decimal string
_ieee754::to_string() {
	local bits="$1"

	if _ieee754::is_nan "$bits"; then echo "NaN"; return; fi

	if _ieee754::is_inf "$bits"; then
		if [[ $(_ieee754::get_sign "$bits") -eq 1 ]]; then echo "-Inf"; else echo "Inf"; fi
		return
	fi

	if _ieee754::is_zero "$bits"; then echo "0"; return; fi

	local sign=$(_ieee754::get_sign "$bits")
	local exp=$(_ieee754::get_exp "$bits")
	local mant=$(_ieee754::get_mant "$bits")

	# Add implicit leading 1 for normalized numbers
	if ((exp > 0)); then
		mant=$((mant | 4503599627370496))
	fi

	local actual_exp=$((exp - 1023 - 52))

	if ((actual_exp >= 0)); then
		local int_result=$((mant << actual_exp))
		((sign)) && echo "-$int_result" || echo "$int_result"
		return
	fi

	local shift=$((-actual_exp))
	local int_part=$((mant >> shift))

	# Fractional remainder = mant - int_part * 2^shift = low bits of mant
	local frac_rem
	if ((shift <= 60)); then
		frac_rem=$((mant & ((1 << shift) - 1)))
	else
		# For large shift: int_part is 0, whole mant is fractional
		frac_rem=$mant
	fi

	# Convert binary fraction to decimal: digits of frac_rem / 2^shift
	local frac_digits=""
	local max_digits=15 i digit

	for ((i = 0; i < max_digits; i++)); do
		if ((shift <= 60)); then
			local denom=$((1 << shift))
			frac_rem=$((frac_rem * 10))
			digit=$((frac_rem / denom))
			frac_rem=$((frac_rem - digit * denom))
		else
			digit=0
			frac_rem=$((frac_rem * 10))
		fi
		frac_digits+="$digit"
		((frac_rem == 0)) && break
	done

	# Remove trailing zeros from fraction
	while [[ "$frac_digits" != "" && "${frac_digits: -1}" == "0" ]]; do
		frac_digits="${frac_digits%0}"
	done

	local result="$int_part"
	[[ -n "$frac_digits" ]] && result="${result}.${frac_digits}"
	((sign)) && result="-${result}"
	echo "$result"
}

# IEEE 754: Addition
# Usage: pfloat::ieee754::add bits_a bits_b
pfloat::ieee754::add() {
	local a="$1" b="$2"

	# Extract components
	local sign_a=$(_ieee754::get_sign "$a")
	local sign_b=$(_ieee754::get_sign "$b")
	local exp_a=$(_ieee754::get_exp "$a")
	local exp_b=$(_ieee754::get_exp "$b")
	local mant_a=$(_ieee754::get_mant "$a")
	local mant_b=$(_ieee754::get_mant "$b")

	# Add implicit leading 1 for normalized numbers
	if ((exp_a > 0)); then mant_a=$((mant_a | 4503599627370496)); fi
	if ((exp_b > 0)); then mant_b=$((mant_b | 4503599627370496)); fi

	# Handle special cases
	if ((exp_a == 2047 || exp_b == 2047)); then
		# NaN or Inf
		echo "$a"  # Simplified - should handle NaN propagation
		return
	fi

	# Align exponents (shift smaller mantissa)
	if ((exp_a > exp_b)); then
		local diff=$((exp_a - exp_b))
		((diff > 52)) && diff=53
		mant_b=$((mant_b >> diff))
		exp_b=$exp_a
	elif ((exp_b > exp_a)); then
		local diff=$((exp_b - exp_a))
		((diff > 52)) && diff=53
		mant_a=$((mant_a >> diff))
		exp_a=$exp_b
	fi

	# Add or subtract mantissas based on signs
	local result_mant result_sign
	if ((sign_a == sign_b)); then
		result_mant=$((mant_a + mant_b))
		result_sign=$sign_a
	else
		if ((mant_a >= mant_b)); then
			result_mant=$((mant_a - mant_b))
			result_sign=$sign_a
		else
			result_mant=$((mant_b - mant_a))
			result_sign=$sign_b
		fi
	fi

	# Normalize result
	local result_exp=$exp_a
	if ((result_mant > 0)); then
		while ((result_mant < 4503599627370496 && result_exp > 0)); do
			result_mant=$((result_mant << 1))
			((result_exp--))
		done
		while ((result_mant >= 9007199254740992)); do
			result_mant=$((result_mant >> 1))
			((result_exp++))
		done
	fi

	# Check for overflow
	if ((result_exp >= 2047)); then
		echo $((result_sign << 63 | 2047 << 52))  # Infinity
		return
	fi

	# Handle zero result (before removing implicit 1)
	if ((result_mant == 0)); then
		echo 0
		return
	fi

	# Remove implicit leading 1 and pack
	result_mant=$((result_mant & 4503599627370495))

	_ieee754::pack "$result_sign" "$result_exp" "$result_mant"
}

# IEEE 754: Subtraction (uses addition with negated operand)
# Usage: pfloat::ieee754::sub bits_a bits_b
pfloat::ieee754::sub() {
	local a="$1" b="$2"
	# Flip sign bit of b and add
	local neg_b=$((b ^ 9223372036854775808))
	pfloat::ieee754::add "$a" "$neg_b"
}

# IEEE 754: Multiplication
# Usage: pfloat::ieee754::mul bits_a bits_b
pfloat::ieee754::mul() {
	local a="$1" b="$2"

	# Extract components
	local sign_a=$(_ieee754::get_sign "$a")
	local sign_b=$(_ieee754::get_sign "$b")
	local exp_a=$(_ieee754::get_exp "$a")
	local exp_b=$(_ieee754::get_exp "$b")
	local mant_a=$(_ieee754::get_mant "$a")
	local mant_b=$(_ieee754::get_mant "$b")

	# Handle special cases
	if ((exp_a == 2047 || exp_b == 2047)); then
		echo $(( (sign_a ^ sign_b) << 63 | 2047 << 52 ))  # Inf or NaN
		return
	fi

	# Result sign
	local result_sign=$((sign_a ^ sign_b))

	# Result exponent (subtract bias)
	local result_exp=$((exp_a + exp_b - 1023))

	# Add implicit leading 1
	if ((exp_a > 0)); then mant_a=$((mant_a | 4503599627370496)); fi
	if ((exp_b > 0)); then mant_b=$((mant_b | 4503599627370496)); fi

	# Multiply mantissas: split 53-bit values into 26-bit chunks
	# mant_a = a_hi*2^26 + a_lo, mant_b = b_hi*2^26 + b_lo
	# product = a_hi*b_hi*2^52 + (a_hi*b_lo + a_lo*b_hi)*2^26 + a_lo*b_lo
	# result = product >> 52 = a_hi*b_hi + ((a_hi*b_lo + a_lo*b_hi)*2^26 + a_lo*b_lo) >> 52
	local a_lo=$((mant_a & 0x3FFFFFF))
	local a_hi=$((mant_a >> 26))
	local b_lo=$((mant_b & 0x3FFFFFF))
	local b_hi=$((mant_b >> 26))

	local cross=$((a_hi * b_lo + a_lo * b_hi))
	local cross_hi=$((cross >> 26))
	local cross_lo=$((cross & 0x3FFFFFF))

	local frac=$(((cross_lo << 26) + a_lo * b_lo))
	local carry=$((cross_hi + (frac >> 52)))
	local result_mant=$((a_hi * b_hi + carry))

	# Normalize
	if ((result_mant >= 9007199254740992)); then
		result_mant=$((result_mant >> 1))
		((result_exp++))
	fi

	# Check for overflow/underflow
	if ((result_exp >= 2047)); then
		echo $((result_sign << 63 | 2047 << 52))  # Infinity
		return
	fi
	if ((result_exp <= 0)); then
		# Subnormal or zero
		echo $((result_sign << 63))
		return
	fi

	# Remove implicit leading 1 and pack
	result_mant=$((result_mant & 4503599627370495))
	_ieee754::pack "$result_sign" "$result_exp" "$result_mant"
}

# IEEE 754: Division
# Usage: pfloat::ieee754::div bits_a bits_b
pfloat::ieee754::div() {
	local a="$1" b="$2"

	# Extract components
	local sign_a=$(_ieee754::get_sign "$a")
	local sign_b=$(_ieee754::get_sign "$b")
	local exp_a=$(_ieee754::get_exp "$a")
	local exp_b=$(_ieee754::get_exp "$b")
	local mant_a=$(_ieee754::get_mant "$a")
	local mant_b=$(_ieee754::get_mant "$b")

	# Handle division by zero
	if _ieee754::is_zero "$b"; then
		if _ieee754::is_zero "$a"; then
			echo "NaN" >&2
			echo $((2047 << 52 | 1))  # NaN
			return
		fi
		echo $(( (sign_a ^ sign_b) << 63 | 2047 << 52 ))  # Infinity
		return
	fi

	# Handle special cases
	if ((exp_a == 2047 || exp_b == 2047)); then
		echo $(( (sign_a ^ sign_b) << 63 | 2047 << 52 ))
		return
	fi

	# Result sign
	local result_sign=$((sign_a ^ sign_b))

	# Result exponent (add bias)
	local result_exp=$((exp_a - exp_b + 1023))

	# Add implicit leading 1
	if ((exp_a > 0)); then mant_a=$((mant_a | 4503599627370496)); fi
	if ((exp_b > 0)); then mant_b=$((mant_b | 4503599627370496)); fi

	# Divide mantissas: compute (mant_a * 2^52) // mant_b
	# Use 10-bit chunks to keep intermediate values under 2^63
	local result_mant=0
	local rem=$mant_a
	local bits_done=0
	local chunk
	while ((bits_done < 52)); do
		chunk=10
		((bits_done + chunk > 52)) && chunk=$((52 - bits_done))
		rem=$((rem << chunk))
		local q_chunk=$((rem / mant_b))
		rem=$((rem - q_chunk * mant_b))
		result_mant=$(((result_mant << chunk) | q_chunk))
		bits_done=$((bits_done + chunk))
	done

	# Normalize
	if ((result_mant >= 9007199254740992)); then
		result_mant=$((result_mant >> 1))
		((result_exp++))
	elif ((result_mant < 4503599627370496 && result_exp > 1)); then
		result_mant=$((result_mant << 1))
		((result_exp--))
	fi

	# Check for overflow/underflow
	if ((result_exp >= 2047)); then
		echo $((result_sign << 63 | 2047 << 52))
		return
	fi

	# Remove implicit leading 1 and pack
	result_mant=$((result_mant & 4503599627370495))
	_ieee754::pack "$result_sign" "$result_exp" "$result_mant"
}

# IEEE 754: Square root (Newton-Raphson iteration)
# Usage: pfloat::ieee754::sqrt bits
pfloat::ieee754::sqrt() {
	local a="$1"

	# Handle negative input
	if [[ $(_ieee754::get_sign "$a") -eq 1 ]]; then
		echo "NaN" >&2
		echo $((2047 << 52 | 1))  # NaN
		return
	fi

	# Handle special cases
	local exp=$(_ieee754::get_exp "$a")
	if ((exp == 2047)); then
		echo "$a"  # sqrt(Inf) = Inf, sqrt(NaN) = NaN
		return
	fi

	if _ieee754::is_zero "$a"; then
		echo 0
		return
	fi

	# Initial guess: exp/2
	local guess_exp=$((exp / 2 + 512))  # 512 = bias/2
	local guess=$((guess_exp << 52))

	# Newton-Raphson: x = (x + a/x) / 2
	local i
	for ((i = 0; i < 10; i++)); do
		local a_div_guess=$(pfloat::ieee754::div "$a" "$guess")
		local sum=$(pfloat::ieee754::add "$guess" "$a_div_guess")
		# Divide by 2 (just decrement exponent)
		guess=$((sum - (1 << 52)))
	done

	echo "$guess"
}

# IEEE 754: Comparison (returns 0 for true, 1 for false)
pfloat::ieee754::eq() {
	local a="$1" b="$2"
	# Handle signed zero
	local abs_a=$((a & ~9223372036854775808))
	local abs_b=$((b & ~9223372036854775808))
	((abs_a == abs_b))
}

# IEEE 754: Not-equal comparison
pfloat::ieee754::ne() {
	local a="$1" b="$2"
	local abs_a=$((a & ~9223372036854775808))
	local abs_b=$((b & ~9223372036854775808))
	((abs_a != abs_b))
}

# IEEE 754: Less-than comparison
pfloat::ieee754::lt() {
	local a="$1" b="$2"
	local sign_a=$(_ieee754::get_sign "$a")
	local sign_b=$(_ieee754::get_sign "$b")

	if ((sign_a && ! sign_b)); then return 0; fi  # Negative < Positive
	if ((! sign_a && sign_b)); then return 1; fi  # Positive >= Negative

	# Same sign - compare as integers (reverse for negative)
	if ((sign_a)); then
		((a > b))
	else
		((a < b))
	fi
}

# IEEE 754: Less-than-or-equal comparison
pfloat::ieee754::le() {
	local a="$1" b="$2"
	pfloat::ieee754::lt "$a" "$b" || pfloat::ieee754::eq "$a" "$b"
}

# IEEE 754: Greater-than comparison
pfloat::ieee754::gt() {
	local a="$1" b="$2"
	! pfloat::ieee754::le "$a" "$b"
}

# IEEE 754: Greater-than-or-equal comparison
pfloat::ieee754::ge() {
	local a="$1" b="$2"
	! pfloat::ieee754::lt "$a" "$b"
}

# IEEE 754: Check if value is NaN
pfloat::ieee754::is_nan() {
	_ieee754::is_nan "$1"
}

# IEEE 754: Check if value is Infinity
pfloat::ieee754::is_inf() {
	_ieee754::is_inf "$1"
}

# IEEE 754: Check if value is finite (not NaN, not Inf)
pfloat::ieee754::is_finite() {
	local exp=$(_ieee754::get_exp "$1")
	((exp < 2047))
}

# IEEE 754: Check if value is zero (+0 or -0)
pfloat::ieee754::is_zero() {
	_ieee754::is_zero "$1"
}

# IEEE 754: Check if value is negative
pfloat::ieee754::is_negative() {
	local sign=$(_ieee754::get_sign "$1")
	((sign == 1))
}

# IEEE 754: Check if value is positive (non-zero, non-negative)
pfloat::ieee754::is_positive() {
	local bits="$1"
	local sign=$(_ieee754::get_sign "$bits")
	((sign == 0)) && ! _ieee754::is_zero "$bits"
}

# IEEE 754: Negation
# Usage: pfloat::ieee754::neg bits
pfloat::ieee754::neg() {
	echo $(( $1 ^ 9223372036854775808 ))
}

# IEEE 754: Absolute value
# Usage: pfloat::ieee754::abs bits
pfloat::ieee754::abs() {
	echo $(( $1 & ~9223372036854775808 ))
}

# IEEE 754: Sign (-1, 0, or 1)
pfloat::ieee754::sign() {
	local bits="$1"
	if _ieee754::is_zero "$bits"; then
		echo 0
	elif [[ $(_ieee754::get_sign "$bits") -eq 1 ]]; then
		echo -1
	else
		echo 1
	fi
}

# IEEE 754: Convert from decimal string
pfloat::ieee754::from_string() {
	_ieee754::from_string "$1"
}

# IEEE 754: Convert to decimal string
pfloat::ieee754::to_string() {
	_ieee754::to_string "$1"
}

# IEEE 754: Pretty-print bit representation
# Usage: pfloat::ieee754::dump <bits>
pfloat::ieee754::dump() {
	local bits="$1"
	local sign; sign=$(_ieee754::get_sign "$bits")
	local exp;   exp=$(_ieee754::get_exp "$bits")
	local mant;  mant=$(_ieee754::get_mant "$bits")
	printf 'sign=%d exp=%d mantissa=0x%013x' "$sign" "$exp" "$mant"
}

# IEEE 754: Build 64-bit pattern from sign, exponent, mantissa strings
# Usage: pfloat::ieee754::from_binary <sign> <exp> <mantissa>
pfloat::ieee754::from_binary() {
	local sign="$1" exp="$2" mant="$3"
	local s_val=$((2#$sign))
	local e_val=$((2#$exp))
	local m_val=$((2#$mant))
	_ieee754::pack "$s_val" "$e_val" "$m_val"
}

# IEEE 754: Decompose 64-bit pattern into sign, exponent, mantissa
# Usage: pfloat::ieee754::to_binary <bits>
pfloat::ieee754::to_binary() {
	local bits="$1"
	local sign; sign=$(_ieee754::get_sign "$bits")
	local exp;   exp=$(_ieee754::get_exp "$bits")
	local mant;  mant=$(_ieee754::get_mant "$bits")
	printf '%d\n%d\n%d' "$sign" "$exp" "$mant"
}

# IEEE 754: Truncate float toward zero, return as integer bits
# Usage: pfloat::ieee754::trunc <bits>
pfloat::ieee754::trunc() {
	local bits="$1"
	_ieee754::is_nan "$bits" && { echo "0"; return 1; }
	_ieee754::is_inf "$bits" && { echo "$bits"; return 0; }
	_ieee754::is_zero "$bits" && { echo "$bits"; return 0; }

	local sign; sign=$(_ieee754::get_sign "$bits")
	local exp;   exp=$(_ieee754::get_exp "$bits")
	local mant;  mant=$(_ieee754::get_mant "$bits")

	local unbiased=$(( exp - 1023 ))
	if (( unbiased < 0 )); then
		# |value| < 1 → truncates to 0 (or -0)
		_ieee754::pack "$sign" 0 0
		return 0
	fi
	if (( unbiased >= 52 )); then
		# Already an integer
		echo "$bits"
		return 0
	fi

	# Zero out fractional bits in mantissa
	local frac_bits=$(( 52 - unbiased ))
	local frac_mask=$(( (1 << frac_bits) - 1 ))
	_ieee754::pack "$sign" "$exp" $(( mant & ~frac_mask ))
}

# IEEE 754: Round float to nearest integer, ties to even
# Usage: pfloat::ieee754::round <bits>
pfloat::ieee754::round() {
	local bits="$1"
	_ieee754::is_nan "$bits" && { echo "0"; return 1; }
	_ieee754::is_inf "$bits" && { echo "$bits"; return 0; }
	_ieee754::is_zero "$bits" && { echo "$bits"; return 0; }

	local sign; sign=$(_ieee754::get_sign "$bits")
	local exp;   exp=$(_ieee754::get_exp "$bits")
	local mant;  mant=$(_ieee754::get_mant "$bits")

	local unbiased=$(( exp - 1023 ))
	if (( unbiased < 0 )); then
		# |value| < 1
		if (( unbiased == -1 && mant > 0 )); then
			# 0.5 < |value| < 1 → round to ±1
			_ieee754::pack "$sign" 1023 0
		else
			# |value| ≤ 0.5 → round to 0 (ties-to-even: 0.5 → 0)
			_ieee754::pack "$sign" 0 0
		fi
		return 0
	fi
	if (( unbiased >= 52 )); then
		# Already an integer
		echo "$bits"
		return 0
	fi

	# Round to nearest, ties to even
	local frac_bits=$(( 52 - unbiased ))
	local half_bit=$(( 1 << (frac_bits - 1) ))
	local frac_mask=$(( (1 << frac_bits) - 1 ))
	local frac=$(( mant & frac_mask ))

	if (( frac > half_bit )); then
		# Round up: add 1 << frac_bits, then zero fraction
		mant=$(( mant + (1 << frac_bits) ))
	elif (( frac == half_bit )); then
		# Ties to even: round up if the integer LSB is 1
		if (( (mant >> frac_bits) & 1 )); then
			mant=$(( mant + (1 << frac_bits) ))
		fi
	fi
	# Zero out fractional bits
	_ieee754::pack "$sign" "$exp" $(( mant & ~frac_mask ))
}
