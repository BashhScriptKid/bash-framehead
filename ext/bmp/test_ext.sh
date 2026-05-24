#!/usr/bin/env bash
# test_ext.sh — ext/bmp test suite
#
# Sourced by the test runner after tester.sh and the extension are loaded.
# _pass / _fail / _assert / _sub_done / _skip are in scope.

# ==============================================================================
# bmp::rgb
# ==============================================================================

test::bmp::rgb() {
    local out
    out=$(bmp::rgb 255 0 0 | od -An -tx1 | tr -d ' ')
    if [[ "$out" == "0000ff" ]]; then _pass; else _fail "BGR byte order: $out"; fi
}

# ==============================================================================
# bmp::pad
# ==============================================================================

test::bmp::pad() {
    local out
    out=$(bmp::pad 3 | od -An -tx1 | tr -d ' ')
    if [[ "$out" == "000000" ]]; then _pass; else _fail "null bytes: $out"; fi
}

# ==============================================================================
# bmp::header
# ==============================================================================

test::bmp::header() {
    local tmpfile padding
    tmpfile=$(mktemp "/tmp/fsbshf-bmp-test.XXXXXX")

    bmp::header 4 4 > "$tmpfile"
    padding=$REPLY

    local sig len
    sig=$(head -c 2 "$tmpfile")
    len=$(wc -c < "$tmpfile")

    if [[ "$sig" != "BM" ]]; then _fail "BMP signature: $sig"; rm -f "$tmpfile"; return; fi
    if [[ "$len" != "54" ]]; then _fail "header length: $len (expected 54)"; rm -f "$tmpfile"; return; fi
    if [[ "$padding" != "0" ]]; then _fail "padding for 4x4: $padding (expected 0)"; rm -f "$tmpfile"; return; fi
    _pass
    rm -f "$tmpfile"
}

# ==============================================================================
# bmp::hex2rgb
# ==============================================================================

test::bmp::hex2rgb() {
    if [[ "$(bmp::hex2rgb "#ff0000")" == "255 0 0" ]]; then _pass; else _fail; fi
}

# ==============================================================================
# bmp::gradient
# ==============================================================================

test::bmp::gradient() {
    local tmpfile sig len center

    # Linear
    tmpfile=$(mktemp "/tmp/fsbshf-bmp-test.XXXXXX")
    bmp::gradient 4 4 linear > "$tmpfile"
    sig=$(head -c 2 "$tmpfile")
    len=$(wc -c < "$tmpfile")
    if [[ "$sig" != "BM" ]]; then _fail "linear: bad signature"; rm -f "$tmpfile"; return; fi
    if [[ "$len" != "102" ]]; then _fail "linear: size $len (expected 102)"; rm -f "$tmpfile"; return; fi
    _sub_pass "linear gradient"
    rm -f "$tmpfile"

    # Radial — center pixel should be blue (d2=0 → R=0, B=255)
    tmpfile=$(mktemp "/tmp/fsbshf-bmp-test.XXXXXX")
    bmp::gradient 4 4 radial > "$tmpfile"
    sig=$(head -c 2 "$tmpfile")
    len=$(wc -c < "$tmpfile")
    if [[ "$sig" != "BM" ]]; then _fail "radial: bad signature"; rm -f "$tmpfile"; return; fi
    if [[ "$len" != "102" ]]; then _fail "radial: size $len (expected 102)"; rm -f "$tmpfile"; return; fi

    # Center pixel (d2=0) at BMP loop (x=2,y=2) → screen (2,1). Offset = 54+2*12+2*3 = 84.
    center=$(tail -c +85 "$tmpfile" | head -c 3 | od -An -tx1 | tr -d ' ')
    if [[ "$center" == "ff0000" ]]; then _sub_pass "radial center blue"
    else _sub_fail "radial center: $center (expected ff0000)"; fi

    rm -f "$tmpfile"
    _sub_done
}

# ==============================================================================
# bmp::sprite
# ==============================================================================

test::bmp::sprite() {
    local tmpdir tmpfile sig len
    tmpdir=$(mktemp -d "/tmp/fsbshf-bmp-test.XXXXXX")

    echo 'X #ff0000' > "$tmpdir/palette.txt"
    echo '. #ffffff' >> "$tmpdir/palette.txt"

    tmpfile=$(mktemp "/tmp/fsbshf-bmp-test.XXXXXX")
    printf 'X\n' | bmp::sprite "$tmpdir/palette.txt" > "$tmpfile"
    sig=$(head -c 2 "$tmpfile")
    len=$(wc -c < "$tmpfile")
    if [[ "$sig" != "BM" ]]; then _fail "sprite: bad signature"; rm -f "$tmpfile"; rm -rf "$tmpdir"; return; fi
    # 1x1 BMP: 54 header + 1 row of 3 bytes + 1 pad byte = 58
    if [[ "$len" != "58" ]]; then _fail "sprite: size $len (expected 58)"; rm -f "$tmpfile"; rm -rf "$tmpdir"; return; fi
    _pass

    rm -f "$tmpfile"
    rm -rf "$tmpdir"
}

# ==============================================================================
# bmp::global — edge cases
# ==============================================================================

test::bmp::global() {
    local out

    # hex2rgb without # prefix
    if [[ "$(bmp::hex2rgb "ff0000")" == "255 0 0" ]]; then
        _sub_pass "hex2rgb without #"
    else
        _sub_fail "hex2rgb without #"
    fi

    # gradient with unknown type
    bmp::gradient 2 2 bogus >/dev/null 2>/dev/null
    if [[ $? -eq 1 ]]; then
        _sub_pass "unknown gradient type fails"
    else
        _sub_fail "unknown gradient type should fail"
    fi

    # sprite with nonexistent palette
    bmp::sprite /nonexistent/palette >/dev/null 2>/dev/null
    if [[ $? -eq 1 ]]; then
        _sub_pass "nonexistent palette fails"
    else
        _sub_fail "nonexistent palette should fail"
    fi

    # hex2rgb with lowercase and no # — verify values
    if [[ "$(bmp::hex2rgb "00ff00")" == "0 255 0" ]]; then
        _sub_pass "lowercase green hex"
    else
        _sub_fail "lowercase green hex"
    fi

    _sub_done
}
