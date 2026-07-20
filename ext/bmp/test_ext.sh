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
		if [[ "$(bmp::hex2rgb "#ff0000")" == "255 0 0" ]]; then _sub_pass "6-digit hex"
		else _sub_fail "6-digit hex"; fi

		bmp::hex2rgb "#f00" >/dev/null 2>/dev/null
		if [[ $? -eq 1 ]]; then _sub_pass "short hex (#f00) rejected"
		else _sub_fail "short hex (#f00) should be rejected"; fi

		bmp::hex2rgb "zzzzzz" >/dev/null 2>/dev/null
		if [[ $? -eq 1 ]]; then _sub_pass "non-hex chars rejected"
		else _sub_fail "non-hex chars should be rejected"; fi

		_sub_done
}

# ==============================================================================
# bmp::rgb2hex
# ==============================================================================

test::bmp::rgb2hex() {
		if [[ "$(bmp::rgb2hex 255 0 0)" == "#ff0000" ]]; then _sub_pass "red"
		else _sub_fail "red"; fi

		if [[ "$(bmp::rgb2hex 0 255 0)" == "#00ff00" ]]; then _sub_pass "green"
		else _sub_fail "green"; fi

		bmp::rgb2hex 256 0 0 >/dev/null 2>/dev/null
		if [[ $? -eq 1 ]]; then _sub_pass "out-of-range rejected"
		else _sub_fail "out-of-range should be rejected"; fi

		# roundtrip with hex2rgb
		if [[ "$(bmp::rgb2hex $(bmp::hex2rgb "#abcdef"))" == "#abcdef" ]]; then _sub_pass "roundtrip with hex2rgb"
		else _sub_fail "roundtrip with hex2rgb"; fi

		_sub_done
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
		if [[ "$len" != "58" ]]; then _sub_fail "sprite: size $len (expected 58)"
		else _sub_pass "1x1 sprite"; fi
		rm -f "$tmpfile"

		# Ragged sprite input should be rejected
		printf 'XX\n.\n' | bmp::sprite "$tmpdir/palette.txt" >/dev/null 2>/dev/null
		if [[ $? -eq 1 ]]; then _sub_pass "ragged sprite rejected"
		else _sub_fail "ragged sprite should be rejected"; fi

		rm -rf "$tmpdir"
		_sub_done
}

# ==============================================================================
# bmp::info
# ==============================================================================

test::bmp::info() {
		local tmpfile info
		tmpfile=$(mktemp "/tmp/fsbshf-bmp-test.XXXXXX")
		bmp::gradient 4 3 linear > "$tmpfile"
		info=$(bmp::info "$tmpfile")
		rm -f "$tmpfile"

		if [[ "$info" == *"width=4"* ]]; then _sub_pass "width"; else _sub_fail "width: $info"; fi
		if [[ "$info" == *"height=3"* ]]; then _sub_pass "height"; else _sub_fail "height: $info"; fi
		if [[ "$info" == *"bits_per_px=24"* ]]; then _sub_pass "bits_per_px"; else _sub_fail "bits_per_px: $info"; fi
		if [[ "$info" == *"data_offset=54"* ]]; then _sub_pass "data_offset"; else _sub_fail "data_offset: $info"; fi

		bmp::info /nonexistent.bmp >/dev/null 2>/dev/null
		if [[ $? -eq 1 ]]; then _sub_pass "nonexistent file fails"; else _sub_fail "nonexistent file should fail"; fi

		bmp::info "$0" >/dev/null 2>/dev/null
		if [[ $? -eq 1 ]]; then _sub_pass "non-BMP file fails"; else _sub_fail "non-BMP file should fail"; fi

		_sub_done
}

# ==============================================================================
# bmp::read
# ==============================================================================

test::bmp::read() {
		local tmpfile out
		tmpfile=$(mktemp "/tmp/fsbshf-bmp-test.XXXXXX")
		bmp::gradient 4 3 linear > "$tmpfile"
		out=$(bmp::read "$tmpfile")
		rm -f "$tmpfile"

		# Top row of the natural reading order = last row written (y=height-1, b=170)
		local first_line last_line
		first_line=$(head -n1 <<< "$out")
		last_line=$(tail -n1 <<< "$out")
		if [[ "$first_line" == "0 0 170" ]]; then _sub_pass "top row matches bottom-up inversion"
		else _sub_fail "top row: '$first_line' (expected '0 0 170')"; fi
		if [[ "$last_line" == "191 0 0" ]]; then _sub_pass "bottom row matches"
		else _sub_fail "bottom row: '$last_line' (expected '191 0 0')"; fi

		local lines
		lines=$(wc -l <<< "$out")
		if [[ "$lines" == "12" ]]; then _sub_pass "pixel count (4x3)"
		else _sub_fail "pixel count: $lines (expected 12)"; fi

		# sprite roundtrip: X. / .X with X=red, .=green
		local tmpdir2
		tmpdir2=$(mktemp -d "/tmp/fsbshf-bmp-test.XXXXXX")
		echo 'X #ff0000' > "$tmpdir2/palette.txt"
		echo '. #00ff00' >> "$tmpdir2/palette.txt"
		tmpfile=$(mktemp "/tmp/fsbshf-bmp-test.XXXXXX")
		printf 'X.\n.X\n' | bmp::sprite "$tmpdir2/palette.txt" > "$tmpfile"
		out=$(bmp::read "$tmpfile")
		rm -f "$tmpfile"
		rm -rf "$tmpdir2"

		local expected=$'255 0 0\n0 255 0\n0 255 0\n255 0 0'
		if [[ "$out" == "$expected" ]]; then _sub_pass "sprite roundtrip"
		else _sub_fail "sprite roundtrip mismatch: '$out'"; fi

		_sub_done
}

# ==============================================================================
# bmp::hsv2rgb
# ==============================================================================

test::bmp::hsv2rgb() {
		if [[ "$(bmp::hsv2rgb 0 100 100)" == "255 0 0" ]]; then _sub_pass "red"
		else _sub_fail "red: $(bmp::hsv2rgb 0 100 100)"; fi

		if [[ "$(bmp::hsv2rgb 120 100 100)" == "0 255 0" ]]; then _sub_pass "green"
		else _sub_fail "green: $(bmp::hsv2rgb 120 100 100)"; fi

		if [[ "$(bmp::hsv2rgb 240 100 100)" == "0 0 255" ]]; then _sub_pass "blue"
		else _sub_fail "blue: $(bmp::hsv2rgb 240 100 100)"; fi

		bmp::hsv2rgb 400 100 100 >/dev/null 2>/dev/null
		if [[ $? -eq 1 ]]; then _sub_pass "out-of-range hue rejected"
		else _sub_fail "out-of-range hue should be rejected"; fi

		_sub_done
}

# ==============================================================================
# bmp::rgb2hsv
# ==============================================================================

test::bmp::rgb2hsv() {
		if [[ "$(bmp::rgb2hsv 255 0 0)" == "0 100 100" ]]; then _sub_pass "red"
		else _sub_fail "red: $(bmp::rgb2hsv 255 0 0)"; fi

		if [[ "$(bmp::rgb2hsv 0 255 0)" == "120 100 100" ]]; then _sub_pass "green"
		else _sub_fail "green: $(bmp::rgb2hsv 0 255 0)"; fi

		bmp::rgb2hsv 256 0 0 >/dev/null 2>/dev/null
		if [[ $? -eq 1 ]]; then _sub_pass "out-of-range rgb rejected"
		else _sub_fail "out-of-range rgb should be rejected"; fi

		# roundtrip
		if [[ "$(bmp::rgb2hsv $(bmp::hsv2rgb 240 100 100))" == "240 100 100" ]]; then _sub_pass "roundtrip with hsv2rgb"
		else _sub_fail "roundtrip with hsv2rgb: $(bmp::rgb2hsv $(bmp::hsv2rgb 240 100 100))"; fi

		_sub_done
}

# ==============================================================================
# bmp::from_array
# ==============================================================================

test::bmp::from_array() {
		local tmpfile1 tmpfile2 pixels
		tmpfile1=$(mktemp "/tmp/fsbshf-bmp-test.XXXXXX")
		tmpfile2=$(mktemp "/tmp/fsbshf-bmp-test.XXXXXX")

		bmp::gradient 4 3 linear > "$tmpfile1"
		local -a pixels
		mapfile -t pixels < <(bmp::read "$tmpfile1")
		bmp::from_array 4 3 pixels > "$tmpfile2"

		if cmp -s "$tmpfile1" "$tmpfile2"; then _sub_pass "roundtrip via bmp::read byte-identical"
		else _sub_fail "roundtrip via bmp::read produced different bytes"; fi
		rm -f "$tmpfile1" "$tmpfile2"

		local -a bad=("1 2 3" "4 5 6")
		bmp::from_array 4 3 bad >/dev/null 2>/dev/null
		if [[ $? -eq 1 ]]; then _sub_pass "mismatched array length rejected"
		else _sub_fail "mismatched array length should be rejected"; fi

		_sub_done
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
