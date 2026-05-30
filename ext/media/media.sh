# shellcheck shell=bash
# ext/media.sh — Pure Bash media metadata parsing
# Requires: runtime (runtime::has_command)
#
# Reads image/audio metadata using od (coreutils) + bash arithmetic.
# No external media tools required.
#
# Usage:
#   source ext/media/media.sh
#   media::type photo.jpg          # image
#   media::format photo.jpg        # JPEG
#   media::image::width photo.jpg  # 1920
#   media::audio::duration song.mp3 # 245

# --- Guard ---

declare -f 'runtime::bash_version' &>/dev/null || {
	echo "${BASH_SOURCE[0]}: runtime not found — source bash-framehead.sh first" >&2
	return 1
}

# --- Readonly format constants ---

# Magic bytes (first 4 bytes, as hex strings)
readonly _MEDIA_MAGIC_PNG="89504e47"
readonly _MEDIA_MAGIC_JPEG="ffd8ff"
readonly _MEDIA_MAGIC_BMP="424d"
readonly _MEDIA_MAGIC_FLAC="664c6143"
readonly _MEDIA_MAGIC_WAVE="52494646"
readonly _MEDIA_MAGIC_OGG="4f676753"
readonly _MEDIA_MAGIC_MP3_ID3V2="494433"
readonly _MEDIA_MAGIC_MP3_FRAME="fffb"
readonly _MEDIA_MAGIC_MP3_FRAME2="fffa"
readonly _MEDIA_MAGIC_MP3_FRAME3="fff3"
readonly _MEDIA_MAGIC_MP3_FRAME4="fff2"

# PNG offsets (from file start)
readonly _PNG_IHDR_OFFSET=16
readonly _PNG_WIDTH_OFFSET=16
readonly _PNG_HEIGHT_OFFSET=20
readonly _PNG_DEPTH_OFFSET=24
readonly _PNG_TYPE_OFFSET=25

# BMP offsets
readonly _BMP_WIDTH_OFFSET=18
readonly _BMP_HEIGHT_OFFSET=22
readonly _BMP_BPP_OFFSET=28
readonly _BMP_SIZE_OFFSET=2

# WAV offsets (from RIFF header)
readonly _WAV_FORMAT_OFFSET=20
readonly _WAV_CHANNELS_OFFSET=22
readonly _WAV_SAMPLE_RATE_OFFSET=24
readonly _WAV_BITS_OFFSET=34
readonly _WAV_DATA_OFFSET=36
readonly _WAV_SIZE_OFFSET=40

# FLAC STREAMINFO (from offset 4)
readonly _FLAC_STREAMINFO_OFFSET=4
readonly _FLAC_BLOCK_HEADER=4
readonly _FLAC_STREAMINFO_SIZE=34

# ID3v1 (last 128 bytes)
readonly _ID3V1_SIZE=128
readonly _ID3V1_TAG="544147"
readonly _ID3V1_TITLE_OFFSET=3
readonly _ID3V1_TITLE_LEN=30
readonly _ID3V1_ARTIST_OFFSET=33
readonly _ID3V1_ARTIST_LEN=30
readonly _ID3V1_ALBUM_OFFSET=63
readonly _ID3V1_ALBUM_LEN=30
readonly _ID3V1_YEAR_OFFSET=93
readonly _ID3V1_YEAR_LEN=4
readonly _ID3V1_COMMENT_OFFSET=97
readonly _ID3V1_COMMENT_LEN=30
readonly _ID3V1_GENRE_OFFSET=127
readonly _ID3V1_GENRE_LEN=1

# PNG color types
readonly _PNG_COLOR_GREYSCALE=0
readonly _PNG_COLOR_TRUECOLOR=2
readonly _PNG_COLOR_INDEXED=3
readonly _PNG_COLOR_GREYSCALE_ALPHA=4
readonly _PNG_COLOR_TRUECOLOR_ALPHA=6

# --- Helpers ---

# Read N bytes at offset from file, return decimal value
# Usage: _media::_read_uint file offset bytes [endian]
# endian: "big" (default) or "little"
_media::_read_uint() {
	local _file="$1" _offset="$2" _bytes="$3" _endian="${4:-big}"
	local _hex
	_hex=$(od -An -tx1 -j"$_offset" -N"$_bytes" "$_file" 2>/dev/null | tr -d ' \n')
	local _val=0 _i=0
	local _len=${#_hex}
	if [[ "$_endian" == "little" ]]; then
		# Read bytes in reverse order
		local _pos=$((_len - 2))
		while (( _pos >= 0 )); do
			_val=$(( _val * 256 + 16#${_hex:$_pos:2} ))
			(( _pos -= 2 ))
		done
	else
		# Big-endian
		while (( _i < _len )); do
			_val=$(( _val * 256 + 16#${_hex:$_i:2} ))
			(( _i += 2 ))
		done
	fi
	echo "$_val"
}

# Read N bytes as hex string
_media::_read_hex() {
	local _file="$1" _offset="$2" _bytes="$3"
	od -An -tx1 -j"$_offset" -N"$_bytes" "$_file" 2>/dev/null | tr -d ' \n'
}

# Read string at offset (N bytes)
_media::_read_string() {
	local _file="$1" _offset="$2" _bytes="$3"
	dd if="$_file" bs=1 skip="$_offset" count="$_bytes" 2>/dev/null | tr -d '\0'
}

# Get file size
_media::_file_size() {
	local _file="$1"
	stat -c%s "$_file" 2>/dev/null || wc -c < "$_file" 2>/dev/null
}

# Get first 4 bytes as hex
_media::_magic4() {
	od -An -tx1 -N4 "$1" 2>/dev/null | tr -d ' \n'
}

# Get first 3 bytes as hex
_media::_magic3() {
	od -An -tx1 -N3 "$1" 2>/dev/null | tr -d ' \n'
}

# --- TYPE DETECTION ---

media::type() {
	local _file="$1" _magic
	_magic=$(_media::_magic4 "$_file") || { echo "unknown"; return 1; }
	case "$_magic" in
		${_MEDIA_MAGIC_PNG}*)         echo "image" ;;
		${_MEDIA_MAGIC_JPEG}*)       echo "image" ;;
		${_MEDIA_MAGIC_BMP}*)        echo "image" ;;
		${_MEDIA_MAGIC_WAVE}*)       echo "audio" ;;
		${_MEDIA_MAGIC_FLAC}*)       echo "audio" ;;
		${_MEDIA_MAGIC_MP3_ID3V2}*)  echo "audio" ;;
		${_MEDIA_MAGIC_MP3_FRAME}*)  echo "audio" ;;
		${_MEDIA_MAGIC_MP3_FRAME2}*) echo "audio" ;;
		${_MEDIA_MAGIC_MP3_FRAME3}*) echo "audio" ;;
		${_MEDIA_MAGIC_MP3_FRAME4}*) echo "audio" ;;
		${_MEDIA_MAGIC_OGG}*)        echo "audio" ;;
		*)                           echo "other" ;;
	esac
}

media::format() {
	local _file="$1" _magic
	_magic=$(_media::_magic4 "$_file") || { echo "unknown"; return 1; }
	case "$_magic" in
		${_MEDIA_MAGIC_PNG}*)         echo "PNG" ;;
		${_MEDIA_MAGIC_JPEG}*)       echo "JPEG" ;;
		${_MEDIA_MAGIC_BMP}*)        echo "BMP" ;;
		${_MEDIA_MAGIC_WAVE}*)       echo "WAV" ;;
		${_MEDIA_MAGIC_FLAC}*)       echo "FLAC" ;;
		${_MEDIA_MAGIC_MP3_ID3V2}*)  echo "MP3" ;;
		${_MEDIA_MAGIC_MP3_FRAME}*)  echo "MP3" ;;
		${_MEDIA_MAGIC_MP3_FRAME2}*) echo "MP3" ;;
		${_MEDIA_MAGIC_MP3_FRAME3}*) echo "MP3" ;;
		${_MEDIA_MAGIC_MP3_FRAME4}*) echo "MP3" ;;
		${_MEDIA_MAGIC_OGG}*)        echo "OGG" ;;
		*)
			# Check for ID3v1 at end of file
			local _size _tag
			_size=$(_media::_file_size "$_file")
			[[ -z "$_size" ]] && { echo "unknown"; return 1; }
			_tag=$(_media::_read_hex "$_file" $((_size - 128)) 3)
			[[ "$_tag" == "$_ID3V1_TAG" ]] && { echo "MP3"; return; }
			echo "unknown"
			;;
	esac
}

# --- IMAGE FUNCTIONS ---

media::image::width() {
	local _file="$1" _magic
	_magic=$(_media::_magic4 "$_file") || return 1
	case "$_magic" in
		${_MEDIA_MAGIC_PNG}*)
			_media::_read_uint "$_file" $_PNG_WIDTH_OFFSET 4
			;;
		${_MEDIA_MAGIC_BMP}*)
			_media::_read_uint "$_file" $_BMP_WIDTH_OFFSET 4 little
			;;
		${_MEDIA_MAGIC_JPEG}*)
			# JPEG width requires EXIF parsing — not implemented
			echo "unknown"
			return 1
			;;
		*)
			echo "unknown"
			return 1
			;;
	esac
}

media::image::height() {
	local _file="$1" _magic
	_magic=$(_media::_magic4 "$_file") || return 1
	case "$_magic" in
		${_MEDIA_MAGIC_PNG}*)
			local _h
			_h=$(_media::_read_uint "$_file" $_PNG_HEIGHT_OFFSET 4)
			echo "$_h"
			;;
		${_MEDIA_MAGIC_BMP}*)
			local _h
			_h=$(_media::_read_uint "$_file" $_BMP_HEIGHT_OFFSET 4 little)
			# BMP height is negative if top-down
			(( _h < 0 )) && _h=$(( -_h ))
			echo "$_h"
			;;
		*)
			echo "unknown"
			return 1
			;;
	esac
}

media::image::depth() {
	local _file="$1" _magic
	_magic=$(_media::_magic4 "$_file") || return 1
	case "$_magic" in
		${_MEDIA_MAGIC_PNG}*)
			_media::_read_uint "$_file" $_PNG_DEPTH_OFFSET 1
			;;
		${_MEDIA_MAGIC_BMP}*)
			_media::_read_uint "$_file" $_BMP_BPP_OFFSET 2 little
			;;
		*)
			echo "unknown"
			return 1
			;;
	esac
}

media::image::channels() {
	local _file="$1" _magic
	_magic=$(_media::_magic4 "$_file") || return 1
	case "$_magic" in
		${_MEDIA_MAGIC_PNG}*)
			local _type
			_type=$(_media::_read_uint "$_file" $_PNG_TYPE_OFFSET 1)
			case "$_type" in
				$_PNG_COLOR_GREYSCALE)       echo "1" ;;
				$_PNG_COLOR_TRUECOLOR)       echo "3" ;;
				$_PNG_COLOR_INDEXED)         echo "1" ;;
				$_PNG_COLOR_GREYSCALE_ALPHA) echo "2" ;;
				$_PNG_COLOR_TRUECOLOR_ALPHA) echo "4" ;;
				*)                           echo "unknown" ;;
			esac
			;;
		${_MEDIA_MAGIC_BMP}*)
			local _bpp
			_bpp=$(_media::_read_uint "$_file" $_BMP_BPP_OFFSET 2 little)
			case "$_bpp" in
				1|4|8|16) echo "1" ;;
				24)       echo "3" ;;
				32)       echo "4" ;;
				*)        echo "unknown" ;;
			esac
			;;
		*)
			echo "unknown"
			return 1
			;;
	esac
}

media::image::format() {
	media::format "$1"
}

media::image::info() {
	local _file="$1"
	local _type _format _width _height _depth _channels
	_type=$(media::type "$_file") || return 1
	[[ "$_type" == "image" ]] || { echo "not an image"; return 1; }
	_format=$(media::format "$_file")
	_width=$(media::image::width "$_file")
	_height=$(media::image::height "$_file")
	_depth=$(media::image::depth "$_file")
	_channels=$(media::image::channels "$_file")
	printf 'format=%s width=%s height=%s depth=%s channels=%s\n' \
		"$_format" "$_width" "$_height" "$_depth" "$_channels"
}

# --- AUDIO FUNCTIONS ---

media::audio::format() {
	media::format "$1"
}

media::audio::sample_rate() {
	local _file="$1" _magic
	_magic=$(_media::_magic4 "$_file") || return 1
	case "$_magic" in
		${_MEDIA_MAGIC_WAVE}*)
			_media::_read_uint "$_file" $_WAV_SAMPLE_RATE_OFFSET 4 little
			;;
		${_MEDIA_MAGIC_FLAC}*)
			# FLAC sample rate is 20 bits at bit 80 of STREAMINFO
			local _bytes
			_bytes=$(_media::_read_hex "$_file" $_FLAC_STREAMINFO_OFFSET 6)
			# Extract 20-bit sample rate from bytes 10-12
			local _b10 _b11 _b12
			_b10=$((16#${_bytes:20:2}))
			_b11=$((16#${_bytes:22:2}))
			_b12=$((16#${_bytes:24:2}))
			echo $((_b10 * 65536 + _b11 * 256 + _b12))
			;;
		${_MEDIA_MAGIC_MP3_ID3V2}*)
			# MP3 sample rate requires parsing frame header — complex
			echo "unknown"
			return 1
			;;
		*)
			echo "unknown"
			return 1
			;;
	esac
}

media::audio::channels() {
	local _file="$1" _magic
	_magic=$(_media::_magic4 "$_file") || return 1
	case "$_magic" in
		${_MEDIA_MAGIC_WAVE}*)
			_media::_read_uint "$_file" $_WAV_CHANNELS_OFFSET 2 little
			;;
		${_MEDIA_MAGIC_FLAC}*)
			# FLAC channels is 4 bits at bit 98 of STREAMINFO
			local _byte _channels
			_byte=$(_media::_read_hex "$_file" $((_FLAC_STREAMINFO_OFFSET + 12)) 1)
			_channels=$((( 16#${_byte} >> 4 ) + 1))
			echo "$_channels"
			;;
		*)
			echo "unknown"
			return 1
			;;
	esac
}

media::audio::bits() {
	local _file="$1" _magic
	_magic=$(_media::_magic4 "$_file") || return 1
	case "$_magic" in
		${_MEDIA_MAGIC_WAVE}*)
			_media::_read_uint "$_file" $_WAV_BITS_OFFSET 2 little
			;;
		${_MEDIA_MAGIC_FLAC}*)
			# FLAC bits per sample is 5 bits at bit 100 of STREAMINFO
			local _byte _bits
			_byte=$(_media::_read_hex "$_file" $((_FLAC_STREAMINFO_OFFSET + 12)) 1)
			_bits=$(( ( 16#${_byte} & 0x0F ) + 1 ))
			echo "$_bits"
			;;
		*)
			echo "unknown"
			return 1
			;;
	esac
}

media::audio::duration() {
	local _file="$1" _magic
	_magic=$(_media::_magic4 "$_file") || return 1
	case "$_magic" in
		${_MEDIA_MAGIC_WAVE}*)
			local _size _rate _channels _bits _bps _data_size
			_size=$(_media::_file_size "$_file")
			_rate=$(_media::_read_uint "$_file" $_WAV_SAMPLE_RATE_OFFSET 4 little)
			_channels=$(_media::_read_uint "$_file" $_WAV_CHANNELS_OFFSET 2 little)
			_bits=$(_media::_read_uint "$_file" $_WAV_BITS_OFFSET 2 little)
			_data_size=$(_media::_read_uint "$_file" $_WAV_SIZE_OFFSET 4 little)
			_bps=$((_rate * _channels * _bits / 8))
			(( _bps > 0 )) && echo $((_data_size / _bps)) || echo "unknown"
			;;
		${_MEDIA_MAGIC_FLAC}*)
			local _size _rate
			_size=$(_media::_file_size "$_file")
			_rate=$(_media::_audio::flac_sample_rate "$_file")
			# FLAC is lossless, size varies — rough estimate
			(( _rate > 0 )) && echo $((_size / _rate / 4)) || echo "unknown"
			;;
		*)
			echo "unknown"
			return 1
			;;
	esac
}

media::audio::bitrate() {
	local _file="$1" _magic
	_magic=$(_media::_magic4 "$_file") || return 1
	case "$_magic" in
		${_MEDIA_MAGIC_WAVE}*)
			local _size _header_size
			_size=$(_media::_file_size "$_file")
			_header_size=$(_media::_read_uint "$_file" $_WAV_DATA_OFFSET 4)
			_header_size=$((_header_size + 8))
			local _rate _channels _bits _bps _data_size _duration
			_rate=$(_media::_read_uint "$_file" $_WAV_SAMPLE_RATE_OFFSET 4)
			_channels=$(_media::_read_uint "$_file" $_WAV_CHANNELS_OFFSET 2)
			_bits=$(_media::_read_uint "$_file" $_WAV_BITS_OFFSET 2)
			_data_size=$(_media::_read_uint "$_file" $_WAV_SIZE_OFFSET 4)
			_bps=$((_rate * _channels * _bits / 8))
			(( _bps > 0 )) && _duration=$((_data_size / _bps)) || _duration=1
			echo $(( ((_size - _header_size) * 8) / _duration / 1000 ))
			;;
		*)
			echo "unknown"
			return 1
			;;
	esac
}

media::audio::tags() {
	local _file="$1" _magic
	_magic=$(_media::_magic4 "$_file") || return 1
	case "$_magic" in
		${_MEDIA_MAGIC_MP3_ID3V2}*)
			# ID3v2 — complex frame parsing, return placeholder
			echo "id3v2 detected (frame parsing not implemented)"
			;;
		*)
			# Check for ID3v1 at end
			local _size _tag
			_size=$(_media::_file_size "$_file")
			_tag=$(_media::_read_hex "$_file" $((_size - 128)) 3)
			if [[ "$_tag" == "$_ID3V1_TAG" ]]; then
				local _title _artist _album _year
				_title=$(_media::_read_string "$_file" $((_size - 125)) $_ID3V1_TITLE_LEN)
				_artist=$(_media::_read_string "$_file" $((_size - 95)) $_ID3V1_ARTIST_LEN)
				_album=$(_media::_read_string "$_file" $((_size - 65)) $_ID3V1_ALBUM_LEN)
				_year=$(_media::_read_string "$_file" $((_size - 35)) $_ID3V1_YEAR_LEN)
				printf 'title=%s artist=%s album=%s year=%s\n' "$_title" "$_artist" "$_album" "$_year"
			else
				echo "no tags found"
			fi
			;;
	esac
}

media::audio::tag::get() {
	local _file="$1" _tag="$2" _magic
	_magic=$(_media::_magic4 "$_file") || return 1
	local _size
	_size=$(_media::_file_size "$_file")
	local _tag_header
	_tag_header=$(_media::_read_hex "$_file" $((_size - 128)) 3)
	[[ "$_tag_header" != "$_ID3V1_TAG" ]] && return 1
	case "$_tag" in
		title)  _media::_read_string "$_file" $((_size - 125)) $_ID3V1_TITLE_LEN ;;
		artist) _media::_read_string "$_file" $((_size - 95)) $_ID3V1_ARTIST_LEN ;;
		album)  _media::_read_string "$_file" $((_size - 65)) $_ID3V1_ALBUM_LEN ;;
		year)   _media::_read_string "$_file" $((_size - 35)) $_ID3V1_YEAR_LEN ;;
		*)      return 1 ;;
	esac
}

media::audio::info() {
	local _file="$1"
	local _type _format _duration _bitrate _rate _channels _bits
	_type=$(media::type "$_file") || return 1
	[[ "$_type" == "audio" ]] || { echo "not audio"; return 1; }
	_format=$(media::format "$_file")
	_duration=$(media::audio::duration "$_file")
	_bitrate=$(media::audio::bitrate "$_file")
	_rate=$(media::audio::sample_rate "$_file")
	_channels=$(media::audio::channels "$_file")
	_bits=$(media::audio::bits "$_file")
	printf 'format=%s duration=%s bitrate=%s sample_rate=%s channels=%s bits=%s\n' \
		"$_format" "$_duration" "$_bitrate" "$_rate" "$_channels" "$_bits"
}

# --- VIDEO STUB ---

media::video::format() {
	echo "unknown"
	return 1
}

media::video::resolution() {
	echo "unknown"
	return 1
}

media::video::duration() {
	echo "unknown"
	return 1
}

media::video::info() {
	echo "video parsing not implemented"
	return 1
}

# --- INFO ---

media::info() {
	local _file="$1"
	local _type
	_type=$(media::type "$_file") || return 1
	case "$_type" in
		image) media::image::info "$_file" ;;
		audio) media::audio::info "$_file" ;;
		video) media::video::info "$_file" ;;
		*)     echo "type=$_type format=unknown" ;;
	esac
}
