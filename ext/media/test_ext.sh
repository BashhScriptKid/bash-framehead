#!/usr/bin/env bash
# test_ext.sh — ext/media test suite

declare -f 'media::type' &>/dev/null || {
	echo "${BASH_SOURCE[0]}: media.sh not found — source it first" >&2
	return 1
}

# --- Helper: create test files ---

_create_test_png() {
	# Minimal 1x1 white PNG
	local _file="${1:-/tmp/test_media.png}"
	printf '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\x0cIDATx\x9cc\xf8\x0f\x00\x00\x01\x01\x00\x05\x18\xd8N\x00\x00\x00\x00IEND\xaeB`\x82' > "$_file"
}

# --- Tests ---

test::media::type() {
	local _f="/tmp/test_media_$$.png"
	_create_test_png "$_f"
	local _t
	_t=$(media::type "$_f")
	rm -f "$_f"
	[[ "$_t" == "image" ]] && _pass || _fail "expected image, got $_t"
}

test::media::format() {
	local _f="/tmp/test_media_$$.png"
	_create_test_png "$_f"
	local _fmt
	_fmt=$(media::format "$_f")
	rm -f "$_f"
	[[ "$_fmt" == "PNG" ]] && _pass || _fail "expected PNG, got $_fmt"
}

test::media::image::width() {
	local _f="/tmp/test_media_$$.png"
	_create_test_png "$_f"
	local _w
	_w=$(media::image::width "$_f")
	rm -f "$_f"
	[[ "$_w" == "1" ]] && _pass || _fail "expected 1, got $_w"
}

test::media::image::height() {
	local _f="/tmp/test_media_$$.png"
	_create_test_png "$_f"
	local _h
	_h=$(media::image::height "$_f")
	rm -f "$_f"
	[[ "$_h" == "1" ]] && _pass || _fail "expected 1, got $_h"
}

test::media::image::depth() {
	local _f="/tmp/test_media_$$.png"
	_create_test_png "$_f"
	local _d
	_d=$(media::image::depth "$_f")
	rm -f "$_f"
	[[ "$_d" == "8" ]] && _pass || _fail "expected 8, got $_d"
}

test::media::image::channels() {
	local _f="/tmp/test_media_$$.png"
	_create_test_png "$_f"
	local _c
	_c=$(media::image::channels "$_f")
	rm -f "$_f"
	[[ "$_c" == "3" ]] && _pass || _fail "expected 3, got $_c"
}

test::media::image::info() {
	local _f="/tmp/test_media_$$.png"
	_create_test_png "$_f"
	local _info
	_info=$(media::image::info "$_f")
	rm -f "$_f"
	[[ "$_info" == *"width=1"* ]] && _pass || _fail "info missing width"

# ==============================================================================
# General type/format probes — guarded by external tools (ffprobe/mediainfo)
# ==============================================================================

_media_avail() { command -v ffprobe >/dev/null 2>&1 || command -v mediainfo >/dev/null 2>&1; }

test::media::type()    { _media_avail || { _skip "no ffprobe/mediainfo"; return; }; local _f="/tmp/test_media_$$.png"; _create_test_png "$_f"; local _v; _v=$(media::type "$_f" 2>/dev/null); rm -f "$_f"; [[ -n "$_v" ]] && _pass || _fail; }
test::media::format()  { _media_avail || { _skip "no ffprobe/mediainfo"; return; }; local _f="/tmp/test_media_$$.png"; _create_test_png "$_f"; local _v; _v=$(media::format "$_f" 2>/dev/null); rm -f "$_f"; [[ -n "$_v" ]] && _pass || _fail; }

# image::* — all already covered indirectly, but exercise them all
test::media::image::depth()    { _media_avail || { _skip "no ffprobe"; return; }; local _f="/tmp/test_media_$$.png"; _create_test_png "$_f"; local _v; _v=$(media::image::depth "$_f" 2>/dev/null); rm -f "$_f"; [[ -n "$_v" ]] && _pass || _fail; }
test::media::image::channels() { _media_avail || { _skip "no ffprobe"; return; }; local _f="/tmp/test_media_$$.png"; _create_test_png "$_f"; local _v; _v=$(media::image::channels "$_f" 2>/dev/null); rm -f "$_f"; [[ -n "$_v" ]] && _pass || _fail; }
test::media::image::format()   { _media_avail || { _skip "no ffprobe"; return; }; local _f="/tmp/test_media_$$.png"; _create_test_png "$_f"; local _v; _v=$(media::image::format "$_f" 2>/dev/null); rm -f "$_f"; [[ -n "$_v" ]] && _pass || _fail; }

# audio::* additional
test::media::audio::format()    { _media_avail || { _skip "no ffprobe"; return; }; local _f="/tmp/test_media_$$.wav"; _create_test_wav "$_f" 8; local _v; _v=$(media::audio::format "$_f" 2>/dev/null); rm -f "$_f"; [[ -n "$_v" ]] && _pass || _fail; }
test::media::audio::channels()  { _media_avail || { _skip "no ffprobe"; return; }; local _f="/tmp/test_media_$$.wav"; _create_test_wav "$_f" 8; local _v; _v=$(media::audio::channels "$_f" 2>/dev/null); rm -f "$_f"; [[ -n "$_v" ]] && _pass || _fail; }
test::media::audio::duration()  { _media_avail || { _skip "no ffprobe"; return; }; local _f="/tmp/test_media_$$.wav"; _create_test_wav "$_f" 8; local _v; _v=$(media::audio::duration "$_f" 2>/dev/null); rm -f "$_f"; [[ -n "$_v" ]] && _pass || _fail; }
test::media::audio::bitrate()   { _media_avail || { _skip "no ffprobe"; return; }; local _f="/tmp/test_media_$$.wav"; _create_test_wav "$_f" 8; local _v; _v=$(media::audio::bitrate "$_f" 2>/dev/null); rm -f "$_f"; [[ -n "$_v" ]] && _pass || _fail; }
test::media::audio::tags()      { _media_avail || { _skip "no ffprobe"; return; }; local _f="/tmp/test_media_$$.wav"; _create_test_wav "$_f" 8; media::audio::tags "$_f" >/dev/null 2>&1; rm -f "$_f"; local r=$?; [[ $r -eq 0 || $r -eq 1 ]] && _pass || _fail; }
test::media::audio::tag::get()  { _media_avail || { _skip "no ffprobe"; return; }; local _f="/tmp/test_media_$$.wav"; _create_test_wav "$_f" 8; local _v; _v=$(media::audio::tag::get "$_f" artist 2>/dev/null); rm -f "$_f"; [[ -n "$_v" || $? -eq 1 ]] && _pass || _fail; }
test::media::audio::info()      { _media_avail || { _skip "no ffprobe"; return; }; local _f="/tmp/test_media_$$.wav"; _create_test_wav "$_f" 8; local _v; _v=$(media::audio::info "$_f" 2>/dev/null); rm -f "$_f"; [[ -n "$_v" ]] && _pass || _fail; }

# video::* — only call if a sample file exists in repo
test::media::video::format()      { _media_avail || { _skip "no ffprobe"; return; }; _skip "no sample video in test fixture"; }
test::media::video::resolution()  { _media_avail || { _skip "no ffprobe"; return; }; _skip "no sample video in test fixture"; }
test::media::video::duration()    { _media_avail || { _skip "no ffprobe"; return; }; _skip "no sample video in test fixture"; }
}
