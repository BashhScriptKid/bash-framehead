#!/usr/bin/env bash
# test_ext.sh — ext/wav test suite
#
# Sourced by the test runner after tester.sh and the extension are loaded.
# _pass / _fail / _assert / _assert_contains / _sub_done / _skip are in scope.

# ==============================================================================
# wav::header
# ==============================================================================

test::wav::header() {
    local tmp
    tmp=$(mktemp "/tmp/fsbshf-wav-test.XXXXXX")
    wav::header 44100 2 16 100 > "$tmp"

    local sig riff wave fmt data sz
    riff=$(head -c 4 "$tmp")
    wave=$(tail -c +9 "$tmp" | head -c 4)
    fmt=$(tail -c +13 "$tmp" | head -c 4)
    data=$(tail -c +37 "$tmp" | head -c 4)
    sz=$(wc -c < "$tmp")

    if [[ "$riff" != "RIFF" ]]; then _fail "RIFF: $riff"; rm -f "$tmp"; return; fi
    if [[ "$wave" != "WAVE" ]]; then _fail "WAVE: $wave"; rm -f "$tmp"; return; fi
    if [[ "$fmt" != "fmt " ]]; then _fail "fmt: $fmt"; rm -f "$tmp"; return; fi
    if [[ "$data" != "data" ]]; then _fail "data: $data"; rm -f "$tmp"; return; fi
    if [[ "$sz" != "44" ]]; then _fail "size: $sz (expected 44)"; rm -f "$tmp"; return; fi
    _pass
    rm -f "$tmp"
}

# ==============================================================================
# wav::parse_header
# ==============================================================================

test::wav::parse_header() {
    local tmp
    tmp=$(mktemp "/tmp/fsbshf-wav-test.XXXXXX")
    wav::header 48000 2 24 500 > "$tmp"
    wav::parse_header < "$tmp"

    if [[ "$_WAV_RATE" != "48000" ]]; then _fail "rate: $_WAV_RATE"; return; fi
    if [[ "$_WAV_CHANNELS" != "2" ]]; then _fail "channels: $_WAV_CHANNELS"; return; fi
    if [[ "$_WAV_BITS" != "24" ]]; then _fail "bits: $_WAV_BITS"; return; fi
    if [[ "$_WAV_FORMAT" != "1" ]]; then _fail "format: $_WAV_FORMAT"; return; fi
    if [[ "$_WAV_NUM_SAMPLES" != "500" ]]; then _fail "samples: $_WAV_NUM_SAMPLES"; return; fi
    _pass
    rm -f "$tmp"
}

# ==============================================================================
# wav::read
# ==============================================================================

test::wav::read() {
    local tmp
    tmp=$(mktemp "/tmp/fsbshf-wav-test.XXXXXX")
    wav::write::sample s16le 0 >> "$tmp"
    wav::write::sample s16le -1 >> "$tmp"
    wav::write::sample s16le 32767 >> "$tmp"

    # Use a single fd so reads advance sequentially
    local s0 s1 s2
    exec 3< "$tmp"
    s0=$(wav::read s16le <&3)
    s1=$(wav::read s16le <&3)
    s2=$(wav::read s16le <&3)
    exec 3<&-
    if [[ "$s0" != "0" ]]; then _fail "s0: $s0"; rm -f "$tmp"; return; fi
    if [[ "$s1" != "-1" ]]; then _fail "s1: $s1"; rm -f "$tmp"; return; fi
    if [[ "$s2" != "32767" ]]; then _fail "s2: $s2"; rm -f "$tmp"; return; fi
    _pass
    rm -f "$tmp"
}

test::wav::read::skip() {
    local tmp
    tmp=$(mktemp "/tmp/fsbshf-wav-test.XXXXXX")
    wav::write::sample s16le 100 >> "$tmp"
    wav::write::sample s16le 200 >> "$tmp"
    wav::write::sample s16le 300 >> "$tmp"

    local s
    s=$(wav::read s16le 1 < "$tmp")  # skip first, read second
    if [[ "$s" != "200" ]]; then _fail "skip 1: $s (expected 200)"; rm -f "$tmp"; return; fi
    _pass
    rm -f "$tmp"
}

test::wav::read::u8() {
    local tmp
    tmp=$(mktemp "/tmp/fsbshf-wav-test.XXXXXX")
    wav::write::sample u8 128 >> "$tmp"

    local s; s=$(wav::read u8 < "$tmp")
    if [[ "$s" != "128" ]]; then _fail "u8: $s (expected 128)"; rm -f "$tmp"; return; fi
    _pass
    rm -f "$tmp"
}

# ==============================================================================
# wav::write::sample
# ==============================================================================

test::wav::write::sample() {
    local tmp s
    tmp=$(mktemp "/tmp/fsbshf-wav-test.XXXXXX")

    wav::write::sample s16le 0 >> "$tmp"
    wav::write::sample s16le -1 >> "$tmp"
    wav::write::sample s16le -32768 >> "$tmp"

    s=$(od -An -tx1 < "$tmp" | tr -d ' \n')
    if [[ "$s" != "0000ffff0080" ]]; then _fail "bytes: $s"; rm -f "$tmp"; return; fi
    _pass
    rm -f "$tmp"
}

# ==============================================================================
# wav::write::tone
# ==============================================================================

test::wav::write::tone() {
    local tmp sig sz

    # Square: s16le 440Hz 0.01s → 44 + 441*2 = 926 bytes
    tmp=$(mktemp "/tmp/fsbshf-wav-test.XXXXXX")
    wav::write::tone square s16le 440 0.01 44100 10000 1 > "$tmp"
    sig=$(head -c 4 "$tmp")
    sz=$(wc -c < "$tmp")
    if [[ "$sig" != "RIFF" ]]; then _fail "square: bad sig $sig"; rm -f "$tmp"; return; fi
    if [[ "$sz" != "926" ]]; then _fail "square: size $sz (expected 926)"; rm -f "$tmp"; return; fi
    _sub_pass "square"
    rm -f "$tmp"

    # Sawtooth: u8 → 44 + 441*1 = 485
    tmp=$(mktemp "/tmp/fsbshf-wav-test.XXXXXX")
    wav::write::tone sawtooth u8 440 0.01 44100 64 1 > "$tmp"
    sig=$(head -c 4 "$tmp")
    sz=$(wc -c < "$tmp")
    if [[ "$sig" != "RIFF" ]]; then _fail "sawtooth: bad sig"; rm -f "$tmp"; return; fi
    if [[ "$sz" != "485" ]]; then _fail "sawtooth: size $sz (expected 485)"; rm -f "$tmp"; return; fi
    _sub_pass "sawtooth"
    rm -f "$tmp"

    # Triangle: s16le → 926
    tmp=$(mktemp "/tmp/fsbshf-wav-test.XXXXXX")
    wav::write::tone triangle s16le 440 0.01 44100 10000 1 > "$tmp"
    sig=$(head -c 4 "$tmp")
    sz=$(wc -c < "$tmp")
    if [[ "$sig" != "RIFF" ]]; then _fail "triangle: bad sig"; rm -f "$tmp"; return; fi
    if [[ "$sz" != "926" ]]; then _fail "triangle: size $sz (expected 926)"; rm -f "$tmp"; return; fi
    _sub_pass "triangle"
    rm -f "$tmp"

    # Sine: requires bc
    if command -v bc &>/dev/null; then
        tmp=$(mktemp "/tmp/fsbshf-wav-test.XXXXXX")
        wav::write::tone sine s16le 440 0.01 44100 10000 1 > "$tmp"
        sig=$(head -c 4 "$tmp")
        sz=$(wc -c < "$tmp")
        if [[ "$sig" != "RIFF" ]]; then _fail "sine: bad sig"; rm -f "$tmp"; return; fi
        if [[ "$sz" != "926" ]]; then _fail "sine: size $sz (expected 926)"; rm -f "$tmp"; return; fi
        _sub_pass "sine"
        rm -f "$tmp"
    else
        _sub_pass "sine skipped (no bc)"
    fi

    _sub_done
}

# ==============================================================================
# wav::global — edge cases
# ==============================================================================

test::wav::global() {
    local tmp out

    # Unknown encoding
    out=$(wav::read bogus 2>/dev/null; echo "EXIT:$?")
    if [[ "$out" == *"EXIT:1"* ]]; then _sub_pass "unknown encoding fails"
    else _sub_fail "unknown encoding: $out"; fi

    # Parse non-WAV
    tmp=$(mktemp "/tmp/fsbshf-wav-test.XXXXXX")
    printf 'NOTAWAVEFILE!!!!' > "$tmp"
    out=$(wav::parse_header < "$tmp" 2>/dev/null; echo "EXIT:$?")
    if [[ "$out" == *"EXIT:1"* ]]; then _sub_pass "non-WAV rejected"
    else _sub_fail "non-WAV: $out"; fi
    rm -f "$tmp"

    # Short file
    tmp=$(mktemp "/tmp/fsbshf-wav-test.XXXXXX")
    printf 'RI' > "$tmp"
    out=$(wav::parse_header < "$tmp" 2>/dev/null; echo "EXIT:$?")
    if [[ "$out" == *"EXIT:1"* ]]; then _sub_pass "short file rejected"
    else _sub_fail "short file: $out"; fi
    rm -f "$tmp"

    # Stereo tone size
    tmp=$(mktemp "/tmp/fsbshf-wav-test.XXXXXX")
    wav::write::tone square s16le 440 0.01 44100 10000 2 > "$tmp"
    local stereo_sz=$(wc -c < "$tmp")
    # 44 + 441 * 2 * 2 = 1808
    if [[ "$stereo_sz" == "1808" ]]; then _sub_pass "stereo size"
    else _sub_fail "stereo: $stereo_sz (expected 1808)"; fi
    rm -f "$tmp"

    _sub_done
}
