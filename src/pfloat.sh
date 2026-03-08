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

pfloat::add() {
  local a_scaled b_scaled result
  a_scaled=$(_pfloat::_to_scaled "$1")
  b_scaled=$(_pfloat::_to_scaled "$2")
  result=$((a_scaled + b_scaled))
  _pfloat::_from_scaled "$result"
}

pfloat::sub() {
  local a_scaled b_scaled result
  a_scaled=$(_pfloat::_to_scaled "$1")
  b_scaled=$(_pfloat::_to_scaled "$2")
  result=$((a_scaled - b_scaled))
  _pfloat::_from_scaled "$result"
}

pfloat::mul() {
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

pfloat::div() {
  local a_scaled b_scaled result scale_factor
  a_scaled=$(_pfloat::_to_scaled "$1")
  b_scaled=$(_pfloat::_to_scaled "$2")

  if ((b_scaled == 0)); then
    echo "pfloat::div: division by zero" >&2
    return 1
  fi

  scale_factor=$(_pfloat::_scale_factor)
  result=$(((a_scaled * scale_factor) / b_scaled))
  _pfloat::_from_scaled "$result"
}

pfloat::mod() {
  local a_scaled b_scaled result
  a_scaled=$(_pfloat::_to_scaled "$1")
  b_scaled=$(_pfloat::_to_scaled "$2")

  if ((b_scaled == 0)); then
    echo "pfloat::mod: division by zero" >&2
    return 1
  fi

  result=$((a_scaled % b_scaled))
  _pfloat::_from_scaled "$result"
}

pfloat::neg() {
  local a_scaled
  a_scaled=$(_pfloat::_to_scaled "$1")
  _pfloat::_from_scaled "$((-a_scaled))"
}

pfloat::abs() {
  local a_scaled
  a_scaled=$(_pfloat::_to_scaled "$1")
  a_scaled=$(_pfloat::_abs "$a_scaled")
  _pfloat::_from_scaled "$a_scaled"
}

pfloat::eq() {
  local a b
  a=$(_pfloat::_to_scaled "$1")
  b=$(_pfloat::_to_scaled "$2")
  ((a == b))
}

pfloat::ne() {
  local a b
  a=$(_pfloat::_to_scaled "$1")
  b=$(_pfloat::_to_scaled "$2")
  ((a != b))
}

pfloat::lt() {
  local a b
  a=$(_pfloat::_to_scaled "$1")
  b=$(_pfloat::_to_scaled "$2")
  ((a < b))
}

pfloat::le() {
  local a b
  a=$(_pfloat::_to_scaled "$1")
  b=$(_pfloat::_to_scaled "$2")
  ((a <= b))
}

pfloat::gt() {
  local a b
  a=$(_pfloat::_to_scaled "$1")
  b=$(_pfloat::_to_scaled "$2")
  ((a > b))
}

pfloat::ge() {
  local a b
  a=$(_pfloat::_to_scaled "$1")
  b=$(_pfloat::_to_scaled "$2")
  ((a >= b))
}

pfloat::is_zero() {
  local a
  a=$(_pfloat::_to_scaled "$1")
  ((a == 0))
}

pfloat::is_positive() {
  local a
  a=$(_pfloat::_to_scaled "$1")
  ((a > 0))
}

pfloat::is_negative() {
  local a
  a=$(_pfloat::_to_scaled "$1")
  ((a < 0))
}

pfloat::floor() {
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

pfloat::ceil() {
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

pfloat::round() {
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

pfloat::trunc() {
  local a="$1"

  if [[ "$a" == *.* ]]; then
    a="${a%%.*}"
  fi

  [[ -z "$a" ]] && a="0"
  echo "$a"
}

pfloat::min() {
  local a b
  a=$(_pfloat::_to_scaled "$1")
  b=$(_pfloat::_to_scaled "$2")
  if ((a < b)); then
    _pfloat::_from_scaled "$a"
  else
    _pfloat::_from_scaled "$b"
  fi
}

pfloat::max() {
  local a b
  a=$(_pfloat::_to_scaled "$1")
  b=$(_pfloat::_to_scaled "$2")
  if ((a > b)); then
    _pfloat::_from_scaled "$a"
  else
    _pfloat::_from_scaled "$b"
  fi
}

pfloat::clamp() {
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

pfloat::sqr() {
  pfloat::mul "$1" "$1"
}

pfloat::sqrt() {
  local num="$1" iterations="${2:-20}"
  local guess prev_guess i

  if pfloat::is_negative "$num"; then
    echo "pfloat::sqrt: negative input" >&2
    return 1
  fi

  if pfloat::is_zero "$num"; then
    echo "0"
    return
  fi

  if pfloat::gt "$num" "1"; then
    guess=$(pfloat::div "$num" "2")
  else
    guess="1"
  fi

  for ((i = 0; i < iterations; i++)); do
    prev_guess="$guess"
    guess=$(pfloat::div $(pfloat::add "$guess" $(pfloat::div "$num" "$guess")) "2")

    if pfloat::eq "$guess" "$prev_guess"; then
      break
    fi
  done

  echo "$guess"
}

pfloat::pow() {
  local base="$1" exp="$2"
  local result="1"
  local neg_exp=0

  if ((exp < 0)); then
    neg_exp=1
    exp=$((-exp))
  fi

  while ((exp > 0)); do
    if ((exp % 2 == 1)); then
      result=$(pfloat::mul "$result" "$base")
    fi
    base=$(pfloat::mul "$base" "$base")
    exp=$((exp / 2))
  done

  if ((neg_exp)); then
    pfloat::div "1" "$result"
  else
    echo "$result"
  fi
}

pfloat::cbrt() {
  local num="$1" iterations="${2:-30}"
  local guess i sign=""

  if pfloat::is_negative "$num"; then
    sign="-"
    num=$(pfloat::neg "$num")
  fi

  if pfloat::is_zero "$num"; then
    echo "0"
    return
  fi

  guess=$(pfloat::div "$num" "3")
  [[ "$guess" == "0" ]] && guess="1"

  for ((i = 0; i < iterations; i++)); do
    local x2
    x2=$(pfloat::mul "$guess" "$guess")
    guess=$(pfloat::div $(pfloat::add $(pfloat::mul "2" "$guess") $(pfloat::div "$num" "$x2")) "3")
  done

  if [[ -n "$sign" ]]; then
    echo "-${guess}"
  else
    echo "$guess"
  fi
}

pfloat::sum() {
  local total="0"
  for n in "$@"; do
    total=$(pfloat::add "$total" "$n")
  done
  echo "$total"
}

pfloat::avg() {
  local count=$#
  ((count == 0)) && {
    echo "pfloat::avg: no arguments" >&2
    return 1
  }

  local total
  total=$(pfloat::sum "$@")
  pfloat::div "$total" "$count"
}

pfloat::lerp() {
  local a="$1" b="$2" t="$3"
  local diff scaled
  diff=$(pfloat::sub "$b" "$a")
  scaled=$(pfloat::mul "$diff" "$t")
  pfloat::add "$a" "$scaled"
}

pfloat::inv_lerp() {
  local v="$1" a="$2" b="$3"
  local num den
  num=$(pfloat::sub "$v" "$a")
  den=$(pfloat::sub "$b" "$a")
  pfloat::div "$num" "$den"
}

pfloat::map() {
  local v="$1" imin="$2" imax="$3" omin="$4" omax="$5"
  local t
  t=$(pfloat::inv_lerp "$v" "$imin" "$imax")
  pfloat::lerp "$omin" "$omax" "$t"
}

pfloat::normalize() {
  local v="$1" lo="$2" hi="$3"
  pfloat::inv_lerp "$v" "$lo" "$hi"
}

pfloat::percent() {
  local part="$1" total="$2"
  local ratio
  ratio=$(pfloat::div "$part" "$total")
  pfloat::mul "$ratio" "100"
}

pfloat::percent_of() {
  local pct="$1" total="$2"
  pfloat::mul "$total" $(pfloat::div "$pct" "100")
}

pfloat::percent_change() {
  local old="$1" new="$2"
  local diff
  diff=$(pfloat::sub "$new" "$old")
  pfloat::mul $(pfloat::div "$diff" "$old") "100"
}

pfloat::dist2() {
  local x1="$1" y1="$2" x2="$3" y2="$4"
  local dx dy dx2 dy2 sum
  dx=$(pfloat::sub "$x1" "$x2")
  dy=$(pfloat::sub "$y1" "$y2")
  dx2=$(pfloat::mul "$dx" "$dx")
  dy2=$(pfloat::mul "$dy" "$dy")
  sum=$(pfloat::add "$dx2" "$dy2")
  pfloat::sqrt "$sum"
}

pfloat::dist3() {
  local x1="$1" y1="$2" z1="$3" x2="$4" y2="$5" z2="$6"
  local dx dy dz dx2 dy2 dz2 sum
  dx=$(pfloat::sub "$x1" "$x2")
  dy=$(pfloat::sub "$y1" "$y2")
  dz=$(pfloat::sub "$z1" "$z2")
  dx2=$(pfloat::mul "$dx" "$dx")
  dy2=$(pfloat::mul "$dy" "$dy")
  dz2=$(pfloat::mul "$dz" "$dz")
  sum=$(pfloat::add "$dx2" "$dy2" "$dz2")
  pfloat::sqrt "$sum"
}

pfloat::sign() {
  local a="$1"
  if pfloat::is_negative "$a"; then
    echo "-1"
  elif pfloat::is_positive "$a"; then
    echo "1"
  else
    echo "0"
  fi
}

pfloat::recip() {
  pfloat::div "1" "$1"
}

pfloat::mean() {
  pfloat::avg "$1" "$2"
}

pfloat::geomean() {
  local a="$1" b="$2"
  local prod
  prod=$(pfloat::mul "$a" "$b")
  pfloat::sqrt "$prod"
}

pfloat::harmean() {
  local a="$1" b="$2"
  local sum prod
  sum=$(pfloat::add "$a" "$b")
  prod=$(pfloat::mul "$a" "$b")
  pfloat::div $(pfloat::mul "2" "$prod") "$sum"
}

pfloat::factorial() {
  local n="$1"
  local result="1" i

  if [[ "$n" == -* ]]; then
    echo "pfloat::factorial: negative input" >&2
    return 1
  fi

  n=$(pfloat::trunc "$n")

  for ((i = 2; i <= n; i++)); do
    result=$(pfloat::mul "$result" "$i")
  done
  echo "$result"
}

pfloat::sigmoid() {
  local x="$1"
  local neg_x exp_val

  if pfloat::is_negative "$x"; then
    neg_x=$(pfloat::neg "$x")
    exp_val=$(pfloat::_exp_approx "$neg_x")
    pfloat::div "1" $(pfloat::add "1" "$exp_val")
  else
    exp_val=$(pfloat::_exp_approx "$x")
    pfloat::div "$exp_val" $(pfloat::add "1" "$exp_val")
  fi
}

pfloat::_exp_approx() {
  local x="$1"
  local result="1" term="$1" i

  for ((i = 1; i < 15; i++)); do
    term=$(pfloat::mul "$term" "$x")
    term=$(pfloat::div "$term" "$i")
    result=$(pfloat::add "$result" "$term")
  done
  echo "$result"
}

pfloat::softplus() {
  local x="$1"
  local exp_val one_plus_exp

  if pfloat::lt "$x" "-10"; then
    echo "0"
    return
  fi

  exp_val=$(pfloat::_exp_approx "$x")
  one_plus_exp=$(pfloat::add "1" "$exp_val")

  pfloat::_ln_approx "$one_plus_exp"
}

pfloat::_ln_approx() {
  local x="$1"
  local y="1" i iterations=20

  if pfloat::le "$x" "0"; then
    echo "0"
    return
  fi

  for ((i = 0; i < iterations; i++)); do
    local ey num den delta
    ey=$(pfloat::_exp_approx "$y")
    num=$(pfloat::mul "2" $(pfloat::sub "$x" "$ey"))
    den=$(pfloat::add "$x" "$ey")
    delta=$(pfloat::div "$num" "$den")
    y=$(pfloat::add "$y" "$delta")
  done
  echo "$y"
}
