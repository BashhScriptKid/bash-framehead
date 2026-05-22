#!/usr/bin/env bash
# stress_csv.sh — stress-test the csv extension against benchmark-style data
#
# Usage: cd <framehead> && bash ext/csv/stress_csv.sh

cd "$(dirname "$0")/../.."
source ./bash-framehead.sh
source ./ext/csv/csv.sh

pass=0 fail=0

check() {
    local label="$1" expected="$2" actual="$3"
    if [[ "$expected" == "$actual" ]]; then
        ((pass++))
        echo "  PASS  $label"
    else
        ((fail++))
        echo "  FAIL  $label"
        echo "        expected: [$expected]"
        echo "        actual:   [$actual]"
    fi
}

echo "=== 1. Quoted fields with embedded delimiters ==="

data=$'id,name,email,notes\n1,"Smith, John","john@example.com","Likes commas, semicolons; and more"\n2,"Doe, Jane","jane@example.com","Enjoys ""quoted"" strings"'

check "get quoted name"     'Smith, John' "$(csv::get "$data" 0 1)"
check "get quoted email"    'john@example.com' "$(csv::get "$data" 0 2)"
check "get quoted notes"    'Likes commas, semicolons; and more' "$(csv::get "$data" 0 3)"
check "get escaped quotes"  'Enjoys "quoted" strings' "$(csv::get "$data" 1 3)"

echo ""
echo "=== 2. Quoted fields with embedded newlines ==="

data=$'id,description\n1,"Line 1\nLine 2\nLine 3"\n2,"Single line"'

check "multiline field row0"  $'Line 1\nLine 2\nLine 3' "$(csv::get "$data" 0 1)"
check "single line field"      'Single line' "$(csv::get "$data" 1 1)"
check "numrows multiline"      '2' "$(csv::numrows "$data")"

echo ""
echo "=== 3. Edge: empty and null-like fields ==="

# a,b,c,d are headers; data rows contain empties
data=$'a,b,c,d\n,,"",\n1,,,4'

check "empty unquoted"   '' "$(csv::get "$data" 0 0)"
check "empty unquoted 2" '' "$(csv::get "$data" 0 1)"
check "quoted empty"     '' "$(csv::get "$data" 0 2)"
check "trailing empty"   '' "$(csv::get "$data" 0 3)"
check "row1 col0"       '1' "$(csv::get "$data" 1 0)"
check "row1 col3"       '4' "$(csv::get "$data" 1 3)"

echo ""
echo "=== 4. Large rows (100 columns x 5 data rows) ==="

gen_wide() {
    local cols="$1" rows="$2" r c
    for (( c=0; c<cols; c++ )); do
        printf 'col%d' "$c"
        (( c < cols-1 )) && printf ','
    done
    printf '\n'
    for (( r=0; r<rows; r++ )); do
        for (( c=0; c<cols; c++ )); do
            printf 'r%dc%d' "$r" "$c"
            (( c < cols-1 )) && printf ','
        done
        printf '\n'
    done
}

wide_data="$(gen_wide 100 5)"
check "numcols wide"    '100' "$(csv::numcols "$wide_data")"
check "numrows wide"      '5' "$(csv::numrows "$wide_data")"
check "first cell"    'r0c0' "$(csv::get "$wide_data" 0 0)"
check "mid cell"     'r2c50' "$(csv::get "$wide_data" 2 col50)"
check "last cell"    'r4c99' "$(csv::get "$wide_data" 4 col99)"

echo ""
echo "=== 5. Deep rows (200 data rows x 10 cols) with timing ==="

gen_deep() {
    local cols="$1" rows="$2" r c
    for (( c=0; c<cols; c++ )); do
        printf 'col%d' "$c"
        (( c < cols-1 )) && printf ','
    done
    printf '\n'
    for (( r=0; r<rows; r++ )); do
        for (( c=0; c<cols; c++ )); do
            printf 'r%dc%d' "$r" "$c"
            (( c < cols-1 )) && printf ','
        done
        printf '\n'
    done
}

deep_data="$(gen_deep 10 200)"
check "numcols deep"   '10' "$(csv::numcols "$deep_data")"
check "numrows deep" '200' "$(csv::numrows "$deep_data")"

# Sequential access: first and last rows
_t0=$(date +%s%3N)
_r199_c9=$(csv::get "$deep_data" 199 col9)
_t1=$(date +%s%3N)
check "row 199 col9" 'r199c9' "$_r199_c9"
echo "  INFO  row-199 seek: $(( _t1 - _t0 )) ms (walks ~2000 fields sequentially)"

_t0=$(date +%s%3N)
_r0_c0=$(csv::get "$deep_data" 0 0)
_t1=$(date +%s%3N)
check "row 0 col0" 'r0c0' "$_r0_c0"
echo "  INFO  row-0 seek: $(( _t1 - _t0 )) ms"

# Random access: the critical performance test
_t0=$(date +%s%3N)
_r100_c5=$(csv::get "$deep_data" 100 col5)
_t1=$(date +%s%3N)
check "row 100 col5" 'r100c5' "$_r100_c5"
echo "  INFO  row-100 seek: $(( _t1 - _t0 )) ms"

echo ""
echo "=== 6. Mixed quoting (some quoted, some not) ==="

data=$'id,active,notes\n1,true,\n2,false,"Contains, comma"\n3,true,Plain\n4,false,"Has ""quote"""'

check "mixed row0 notes"      '' "$(csv::get "$data" 0 notes)"
check "mixed row1 notes"      'Contains, comma' "$(csv::get "$data" 1 notes)"
check "mixed row2 notes"      'Plain' "$(csv::get "$data" 2 notes)"
check "mixed row3 notes"      'Has "quote"' "$(csv::get "$data" 3 notes)"

echo ""
echo "=== 7. Edge: leading/trailing whitespace in unquoted fields ==="

# No header row — the first row IS the data
data=$'  leading,trailing  ,  both  '
CSV_NOHEADER=1
check "leading spaces"    '  leading' "$(csv::get "$data" 0 0)"
check "trailing spaces"   'trailing  ' "$(csv::get "$data" 0 1)"
check "both spaces"       '  both  ' "$(csv::get "$data" 0 2)"
unset CSV_NOHEADER

echo ""
echo "=== 8. Edge: single-column CSV ==="

data=$'only\n1\n2\n3'
CSV_NOHEADER=1
check "single col row0"  'only' "$(csv::get "$data" 0 0)"
check "single col row1"    '1' "$(csv::get "$data" 1 0)"
check "numrows single"      '4' "$(csv::numrows "$data")"
check "numcols single"      '1' "$(csv::numcols "$data")"
unset CSV_NOHEADER

echo ""
echo "=== 9. Edge: very long field value ==="

long_str="$(printf 'x%.0s' {1..10000})"
data="a,b
${long_str},short"
check "long field (10000 chars)" "$long_str" "$(csv::get "$data" 0 0)"

echo ""
echo "=== 10. Custom delimiter (pipe) ==="

data=$'name|age|city\nAlice|30|NYC\nBob|25|LA'
CSV_DELIMITER='|'
check "pipe delim row0"  'Alice' "$(csv::get "$data" 0 0)"
check "pipe delim row1"    'LA' "$(csv::get "$data" 1 city)"
check "pipe delim ncols"     '3' "$(csv::numcols "$data")"
unset CSV_DELIMITER

echo ""
echo "=== Results: $pass passed, $fail failed ==="
(( fail == 0 ))
