#!/usr/bin/env bash
# hash.sh — bash-frameheader hashing lib
# Hashing of strings and data. For file checksums see fs::checksum::*.
#
# CRYPTOGRAPHIC NOTE: md5 and sha1 are included for completeness and
# non-security uses (checksums, caching keys, deduplication). Do not
# use them for password hashing or security-sensitive applications.
# Use sha256 or sha512 for anything security-adjacent.
#
# GRACEFUL DEGRADATION: every hash::* and hash::hmac::* function prefers a
# system tool (md5sum, sha1sum, sha256sum, sha512sum, shasum, b2sum,
# openssl) for speed, then falls back to a pure-Bash engine (_hash::*::digest
# below) so these functions work even with zero external dependencies. The
# pure-Bash path is orders of magnitude slower than the system tool — fine
# for graceful degradation on short strings, not for hashing large files.

# --- INTERNAL HELPERS ---

# Feed a string to a hash command portably
# Usage: _hash::pipe string command [args...]
#        echo "string" | _hash::pipe "" command [args...]
_hash::pipe() {
	local _str="$1"; shift
	if [[ -z "$_str" && ! -t 0 ]]; then
		cat | "$@"
	else
		printf '%s' "$_str" | "$@"
	fi
}

# Internal: read primary input from arg or stdin
_hash::read_input() {
	local -n _hash_read_result="$1"
	if [[ $# -ge 2 ]]; then
		_hash_read_result="$2"
	elif [[ ! -t 0 ]]; then
		_hash_read_result=$(cat)
	else
		_hash_read_result=""
	fi
}

# --- PURE-BASH DIGEST ENGINES (fallback tier) ---
#
# Every engine below takes a byte-value array (by nameref, one element per
# byte, 0-255) and prints a lowercase hex digest. Operating on byte arrays
# rather than strings lets hash::hmac::* feed raw XOR'd key material
# straight into these engines without round-tripping through text.
#
# Known limitation shared with the rest of this file: Bash strings cannot
# hold embedded NUL bytes, so a message containing \0 will be truncated
# before it ever reaches these engines.

# Populate a byte-value array from a string.
# Usage: _hash::str_to_bytes out_arrayname string
_hash::str_to_bytes() {
	local -n _hash_stb_out="$1"
	local str="$2"
	# LC_ALL=C is a special variable bash re-checks on assignment (even
	# just `local`), so ${str:i:1} iterates raw bytes, not multibyte
	# codepoints — matching what md5sum/sha256sum/etc. hash.
	local LC_ALL=C
	local i
	_hash_stb_out=()
	for (( i=0; i<${#str}; i++ )); do
		printf -v '_hash_stb_out[i]' '%d' "'${str:i:1}"
	done
}

# Render a byte-value array as a lowercase hex string.
# Usage: _hash::bytes_to_hex in_arrayname
_hash::bytes_to_hex() {
	local -n _hash_bth_in="$1"
	local i out=""
	for (( i=0; i<${#_hash_bth_in[@]}; i++ )); do
		printf -v out '%s%02x' "$out" "${_hash_bth_in[i]}"
	done
	printf '%s' "$out"
}

# Parse a hex string into a byte-value array (inverse of _hash::bytes_to_hex).
# Usage: _hash::hex_to_bytes out_arrayname hex
_hash::hex_to_bytes() {
	local -n _hash_htb_out="$1"
	local hex="$2"
	local i
	_hash_htb_out=()
	for (( i=0; i<${#hex}; i+=2 )); do
		_hash_htb_out+=($(( 16#${hex:i:2} )))
	done
}

# MD5 (RFC 1321).
# Usage: _hash::md5::digest bytes_arrayname
_hash::md5::digest() {
	local -n _md5_msg="$1"
	local orig_len=${#_md5_msg[@]}
	local -a padded
	padded=("${_md5_msg[@]}")

	# Round table K/S — standard published constants for the algorithm,
	# adapted from the public-domain-style reference at
	# github.com/bahamas10/bash-md5. Local (not module-global) so sourcing
	# this file twice in one shell never hits a readonly/redeclare clash.
	local -a _MD5_S=(
		7 12 17 22  7 12 17 22  7 12 17 22  7 12 17 22
		5  9 14 20  5  9 14 20  5  9 14 20  5  9 14 20
		4 11 16 23  4 11 16 23  4 11 16 23  4 11 16 23
		6 10 15 21  6 10 15 21  6 10 15 21  6 10 15 21
	)
	local -a _MD5_K=(
		0xd76aa478 0xe8c7b756 0x242070db 0xc1bdceee
		0xf57c0faf 0x4787c62a 0xa8304613 0xfd469501
		0x698098d8 0x8b44f7af 0xffff5bb1 0x895cd7be
		0x6b901122 0xfd987193 0xa679438e 0x49b40821
		0xf61e2562 0xc040b340 0x265e5a51 0xe9b6c7aa
		0xd62f105d 0x02441453 0xd8a1e681 0xe7d3fbc8
		0x21e1cde6 0xc33707d6 0xf4d50d87 0x455a14ed
		0xa9e3e905 0xfcefa3f8 0x676f02d9 0x8d2a4c8a
		0xfffa3942 0x8771f681 0x6d9d6122 0xfde5380c
		0xa4beea44 0x4bdecfa9 0xf6bb4b60 0xbebfbc70
		0x289b7ec6 0xeaa127fa 0xd4ef3085 0x04881d05
		0xd9d4d039 0xe6db99e5 0x1fa27cf8 0xc4ac5665
		0xf4292244 0x432aff97 0xab9423a7 0xfc93a039
		0x655b59c3 0x8f0ccc92 0xffeff47d 0x85845dd1
		0x6fa87e4f 0xfe2ce6e0 0xa3014314 0x4e0811a1
		0xf7537e82 0xbd3af235 0x2ad7d2bb 0xeb86d391
	)

	padded+=(0x80)
	while (( ${#padded[@]} % 64 != 56 )); do padded+=(0); done

	local bit_len_lo=$(( (orig_len * 8) & 0xFFFFFFFF ))
	local bit_len_hi=$(( (orig_len >> 29) & 0xFFFFFFFF ))
	local i
	for (( i=0; i<4; i++ )); do padded+=($(( (bit_len_lo >> (i*8)) & 0xFF ))); done
	for (( i=0; i<4; i++ )); do padded+=($(( (bit_len_hi >> (i*8)) & 0xFF ))); done

	local a0=0x67452301 b0=0xefcdab89 c0=0x98badcfe d0=0x10325476
	local block_count=$(( ${#padded[@]} / 64 )) blk

	for (( blk=0; blk<block_count; blk++ )); do
		local base=$(( blk * 64 ))
		local -a M=()
		local j idx
		for (( j=0; j<16; j++ )); do
			idx=$(( base + j*4 ))
			M[j]=$(( padded[idx] | (padded[idx+1] << 8) | (padded[idx+2] << 16) | (padded[idx+3] << 24) ))
		done

		local A=$a0 B=$b0 C=$c0 D=$d0 F g rotated

		for (( i=0; i<64; i++ )); do
			if (( i < 16 )); then
				F=$(( (B & C) | ((~B) & D) )); g=$i
			elif (( i < 32 )); then
				F=$(( (D & B) | ((~D) & C) )); g=$(( (5*i + 1) % 16 ))
			elif (( i < 48 )); then
				F=$(( B ^ C ^ D )); g=$(( (3*i + 5) % 16 ))
			else
				F=$(( C ^ (B | ~D) )); g=$(( (7*i) % 16 ))
			fi

			F=$(( (F + A + _MD5_K[i] + M[g]) & 0xFFFFFFFF ))
			A=$D; D=$C; C=$B
			rotated=$(( ((F << _MD5_S[i]) | (F >> (32 - _MD5_S[i]))) & 0xFFFFFFFF ))
			B=$(( (B + rotated) & 0xFFFFFFFF ))
		done

		a0=$(( (a0 + A) & 0xFFFFFFFF )); b0=$(( (b0 + B) & 0xFFFFFFFF ))
		c0=$(( (c0 + C) & 0xFFFFFFFF )); d0=$(( (d0 + D) & 0xFFFFFFFF ))
	done

	local -a outbytes=()
	local word
	for word in "$a0" "$b0" "$c0" "$d0"; do
		for (( i=0; i<4; i++ )); do
			outbytes+=($(( (word >> (i*8)) & 0xFF )))
		done
	done
	_hash::bytes_to_hex outbytes
}

# SHA-1 (RFC 3174).
# Usage: _hash::sha1::digest bytes_arrayname
_hash::sha1::digest() {
	local -n _sha1_msg="$1"
	local orig_len=${#_sha1_msg[@]}
	local -a padded
	padded=("${_sha1_msg[@]}")

	padded+=(0x80)
	while (( ${#padded[@]} % 64 != 56 )); do padded+=(0); done

	local bit_len_lo=$(( (orig_len * 8) & 0xFFFFFFFF ))
	local bit_len_hi=$(( (orig_len >> 29) & 0xFFFFFFFF ))
	local i
	for (( i=3; i>=0; i-- )); do padded+=($(( (bit_len_hi >> (i*8)) & 0xFF ))); done
	for (( i=3; i>=0; i-- )); do padded+=($(( (bit_len_lo >> (i*8)) & 0xFF ))); done

	local h0=0x67452301 h1=0xEFCDAB89 h2=0x98BADCFE h3=0x10325476 h4=0xC3D2E1F0
	local block_count=$(( ${#padded[@]} / 64 )) blk

	for (( blk=0; blk<block_count; blk++ )); do
		local base=$(( blk * 64 ))
		local -a W=()
		local j idx wtmp
		for (( j=0; j<16; j++ )); do
			idx=$(( base + j*4 ))
			W[j]=$(( (padded[idx] << 24) | (padded[idx+1] << 16) | (padded[idx+2] << 8) | padded[idx+3] ))
		done
		for (( j=16; j<80; j++ )); do
			wtmp=$(( W[j-3] ^ W[j-8] ^ W[j-14] ^ W[j-16] ))
			W[j]=$(( ((wtmp << 1) | (wtmp >> 31)) & 0xFFFFFFFF ))
		done

		local A=$h0 B=$h1 C=$h2 D=$h3 E=$h4
		local F K temp rotA rotB

		for (( i=0; i<80; i++ )); do
			if (( i < 20 )); then
				F=$(( (B & C) | ((~B) & D) )); K=0x5A827999
			elif (( i < 40 )); then
				F=$(( B ^ C ^ D )); K=0x6ED9EBA1
			elif (( i < 60 )); then
				F=$(( (B & C) | (B & D) | (C & D) )); K=0x8F1BBCDC
			else
				F=$(( B ^ C ^ D )); K=0xCA62C1D6
			fi

			rotA=$(( ((A << 5) | (A >> 27)) & 0xFFFFFFFF ))
			temp=$(( (rotA + F + E + K + W[i]) & 0xFFFFFFFF ))
			E=$D; D=$C
			rotB=$(( ((B << 30) | (B >> 2)) & 0xFFFFFFFF ))
			C=$rotB; B=$A; A=$temp
		done

		h0=$(( (h0 + A) & 0xFFFFFFFF )); h1=$(( (h1 + B) & 0xFFFFFFFF ))
		h2=$(( (h2 + C) & 0xFFFFFFFF )); h3=$(( (h3 + D) & 0xFFFFFFFF ))
		h4=$(( (h4 + E) & 0xFFFFFFFF ))
	done

	local -a outbytes=()
	local word
	for word in "$h0" "$h1" "$h2" "$h3" "$h4"; do
		for (( i=3; i>=0; i-- )); do
			outbytes+=($(( (word >> (i*8)) & 0xFF )))
		done
	done
	_hash::bytes_to_hex outbytes
}

# SHA-256 (FIPS 180-4).
# Usage: _hash::sha256::digest bytes_arrayname
_hash::sha256::digest() {
	local -n _sha256_msg="$1"
	local orig_len=${#_sha256_msg[@]}
	local -a padded
	padded=("${_sha256_msg[@]}")

	# Local (not module-global) so sourcing this file twice in one shell
	# never hits a readonly/redeclare clash.
	local -a _SHA256_K=(
		0x428a2f98 0x71374491 0xb5c0fbcf 0xe9b5dba5 0x3956c25b 0x59f111f1 0x923f82a4 0xab1c5ed5
		0xd807aa98 0x12835b01 0x243185be 0x550c7dc3 0x72be5d74 0x80deb1fe 0x9bdc06a7 0xc19bf174
		0xe49b69c1 0xefbe4786 0x0fc19dc6 0x240ca1cc 0x2de92c6f 0x4a7484aa 0x5cb0a9dc 0x76f988da
		0x983e5152 0xa831c66d 0xb00327c8 0xbf597fc7 0xc6e00bf3 0xd5a79147 0x06ca6351 0x14292967
		0x27b70a85 0x2e1b2138 0x4d2c6dfc 0x53380d13 0x650a7354 0x766a0abb 0x81c2c92e 0x92722c85
		0xa2bfe8a1 0xa81a664b 0xc24b8b70 0xc76c51a3 0xd192e819 0xd6990624 0xf40e3585 0x106aa070
		0x19a4c116 0x1e376c08 0x2748774c 0x34b0bcb5 0x391c0cb3 0x4ed8aa4a 0x5b9cca4f 0x682e6ff3
		0x748f82ee 0x78a5636f 0x84c87814 0x8cc70208 0x90befffa 0xa4506ceb 0xbef9a3f7 0xc67178f2
	)

	padded+=(0x80)
	while (( ${#padded[@]} % 64 != 56 )); do padded+=(0); done

	local bit_len_lo=$(( (orig_len * 8) & 0xFFFFFFFF ))
	local bit_len_hi=$(( (orig_len >> 29) & 0xFFFFFFFF ))
	local i
	for (( i=3; i>=0; i-- )); do padded+=($(( (bit_len_hi >> (i*8)) & 0xFF ))); done
	for (( i=3; i>=0; i-- )); do padded+=($(( (bit_len_lo >> (i*8)) & 0xFF ))); done

	local h0=0x6a09e667 h1=0xbb67ae85 h2=0x3c6ef372 h3=0xa54ff53a
	local h4=0x510e527f h5=0x9b05688c h6=0x1f83d9ab h7=0x5be0cd19
	local block_count=$(( ${#padded[@]} / 64 )) blk

	for (( blk=0; blk<block_count; blk++ )); do
		local base=$(( blk * 64 ))
		local -a W=()
		local j idx s0 s1
		for (( j=0; j<16; j++ )); do
			idx=$(( base + j*4 ))
			W[j]=$(( (padded[idx] << 24) | (padded[idx+1] << 16) | (padded[idx+2] << 8) | padded[idx+3] ))
		done
		# sigma0/sigma1 rotr32 inlined (see SHA-512 NOTE below for why).
		for (( j=16; j<64; j++ )); do
			s0=$(( (((W[j-15] >> 7) | (W[j-15] << 25)) & 0xFFFFFFFF) ^ (((W[j-15] >> 18) | (W[j-15] << 14)) & 0xFFFFFFFF) ^ (W[j-15] >> 3) ))
			s1=$(( (((W[j-2] >> 17) | (W[j-2] << 15)) & 0xFFFFFFFF) ^ (((W[j-2] >> 19) | (W[j-2] << 13)) & 0xFFFFFFFF) ^ (W[j-2] >> 10) ))
			W[j]=$(( (W[j-16] + s0 + W[j-7] + s1) & 0xFFFFFFFF ))
		done

		local A=$h0 B=$h1 C=$h2 D=$h3 E=$h4 F=$h5 G=$h6 H=$h7
		local S1 ch temp1 S0 maj temp2

		for (( i=0; i<64; i++ )); do
			S1=$(( (((E >> 6) | (E << 26)) & 0xFFFFFFFF) ^ (((E >> 11) | (E << 21)) & 0xFFFFFFFF) ^ (((E >> 25) | (E << 7)) & 0xFFFFFFFF) ))
			ch=$(( (E & F) ^ ((~E) & G) ))
			temp1=$(( (H + S1 + ch + _SHA256_K[i] + W[i]) & 0xFFFFFFFF ))
			S0=$(( (((A >> 2) | (A << 30)) & 0xFFFFFFFF) ^ (((A >> 13) | (A << 19)) & 0xFFFFFFFF) ^ (((A >> 22) | (A << 10)) & 0xFFFFFFFF) ))
			maj=$(( (A & B) ^ (A & C) ^ (B & C) ))
			temp2=$(( (S0 + maj) & 0xFFFFFFFF ))

			H=$G; G=$F; F=$E
			E=$(( (D + temp1) & 0xFFFFFFFF ))
			D=$C; C=$B; B=$A
			A=$(( (temp1 + temp2) & 0xFFFFFFFF ))
		done

		h0=$(( (h0 + A) & 0xFFFFFFFF )); h1=$(( (h1 + B) & 0xFFFFFFFF ))
		h2=$(( (h2 + C) & 0xFFFFFFFF )); h3=$(( (h3 + D) & 0xFFFFFFFF ))
		h4=$(( (h4 + E) & 0xFFFFFFFF )); h5=$(( (h5 + F) & 0xFFFFFFFF ))
		h6=$(( (h6 + G) & 0xFFFFFFFF )); h7=$(( (h7 + H) & 0xFFFFFFFF ))
	done

	local -a outbytes=()
	local word
	for word in "$h0" "$h1" "$h2" "$h3" "$h4" "$h5" "$h6" "$h7"; do
		for (( i=3; i>=0; i-- )); do
			outbytes+=($(( (word >> (i*8)) & 0xFF )))
		done
	done
	_hash::bytes_to_hex outbytes
}

# SHA-512 (FIPS 180-4).
# NOTE: Bash's `>>` sign-extends negative (high-bit-set) 64-bit values, so a
# plain `x >> n` is wrong for the unsigned right shifts SHA-512 needs.
# `(x < 0 ? (((x >> 1) & 0x7FFF...) >> (n - 1)) : (x >> n))` is the fix:
# clearing the sign-extended bit after a 1-bit shift makes the remaining
# (n-1)-bit shift safe, since the value is now non-negative. This is
# inlined (rather than a real _hash::ushr64 function) to avoid forking a
# subshell on every one of these per round, across 80 rounds per block.
# Usage: _hash::sha512::digest bytes_arrayname
_hash::sha512::digest() {
	local -n _sha512_msg="$1"
	local orig_len=${#_sha512_msg[@]}
	local -a padded
	padded=("${_sha512_msg[@]}")

	# Local (not module-global) so sourcing this file twice in one shell
	# never hits a readonly/redeclare clash.
	local -a _SHA512_K=(
		0x428a2f98d728ae22 0x7137449123ef65cd 0xb5c0fbcfec4d3b2f 0xe9b5dba58189dbbc
		0x3956c25bf348b538 0x59f111f1b605d019 0x923f82a4af194f9b 0xab1c5ed5da6d8118
		0xd807aa98a3030242 0x12835b0145706fbe 0x243185be4ee4b28c 0x550c7dc3d5ffb4e2
		0x72be5d74f27b896f 0x80deb1fe3b1696b1 0x9bdc06a725c71235 0xc19bf174cf692694
		0xe49b69c19ef14ad2 0xefbe4786384f25e3 0x0fc19dc68b8cd5b5 0x240ca1cc77ac9c65
		0x2de92c6f592b0275 0x4a7484aa6ea6e483 0x5cb0a9dcbd41fbd4 0x76f988da831153b5
		0x983e5152ee66dfab 0xa831c66d2db43210 0xb00327c898fb213f 0xbf597fc7beef0ee4
		0xc6e00bf33da88fc2 0xd5a79147930aa725 0x06ca6351e003826f 0x142929670a0e6e70
		0x27b70a8546d22ffc 0x2e1b21385c26c926 0x4d2c6dfc5ac42aed 0x53380d139d95b3df
		0x650a73548baf63de 0x766a0abb3c77b2a8 0x81c2c92e47edaee6 0x92722c851482353b
		0xa2bfe8a14cf10364 0xa81a664bbc423001 0xc24b8b70d0f89791 0xc76c51a30654be30
		0xd192e819d6ef5218 0xd69906245565a910 0xf40e35855771202a 0x106aa07032bbd1b8
		0x19a4c116b8d2d0c8 0x1e376c085141ab53 0x2748774cdf8eeb99 0x34b0bcb5e19b48a8
		0x391c0cb3c5c95a63 0x4ed8aa4ae3418acb 0x5b9cca4f7763e373 0x682e6ff3d6b2b8a3
		0x748f82ee5defb2fc 0x78a5636f43172f60 0x84c87814a1f0ab72 0x8cc702081a6439ec
		0x90befffa23631e28 0xa4506cebde82bde9 0xbef9a3f7b2c67915 0xc67178f2e372532b
		0xca273eceea26619c 0xd186b8c721c0c207 0xeada7dd6cde0eb1e 0xf57d4f7fee6ed178
		0x06f067aa72176fba 0x0a637dc5a2c898a6 0x113f9804bef90dae 0x1b710b35131c471b
		0x28db77f523047d84 0x32caab7b40c72493 0x3c9ebe0a15c9bebc 0x431d67c49c100d4c
		0x4cc5d4becb3e42b6 0x597f299cfc657e2a 0x5fcb6fab3ad6faec 0x6c44198c4a475817
	)

	padded+=(0x80)
	while (( ${#padded[@]} % 128 != 112 )); do padded+=(0); done

	# 128-bit big-endian bit-length suffix; top 64 bits are always 0 here
	# (would need > 2 exabytes of input to touch them).
	local bit_len=$(( orig_len * 8 ))
	local i
	for (( i=0; i<8; i++ )); do padded+=(0); done
	for (( i=7; i>=0; i-- )); do padded+=($(( (bit_len >> (i*8)) & 0xFF ))); done

	local h0=0x6a09e667f3bcc908 h1=0xbb67ae8584caa73b h2=0x3c6ef372fe94f82b h3=0xa54ff53a5f1d36f1
	local h4=0x510e527fade682d1 h5=0x9b05688c2b3e6c1f h6=0x1f83d9abfb41bd6b h7=0x5be0cd19137e2179
	local block_count=$(( ${#padded[@]} / 128 )) blk

	for (( blk=0; blk<block_count; blk++ )); do
		local base=$(( blk * 128 ))
		local -a W=()
		local j idx s0 s1 x k
		for (( j=0; j<16; j++ )); do
			idx=$(( base + j*8 ))
			W[j]=0
			for (( k=0; k<8; k++ )); do
				W[j]=$(( (W[j] << 8) | padded[idx+k] ))
			done
		done
		for (( j=16; j<80; j++ )); do
			x=${W[j-15]}
			s0=$(( ( (x < 0 ? (((x >> 1) & 0x7FFFFFFFFFFFFFFF) >> 0) : (x >> 1)) | (x << 63) ) ^ \
			       ( (x < 0 ? (((x >> 1) & 0x7FFFFFFFFFFFFFFF) >> 7)  : (x >> 8)) | (x << 56) ) ^ \
			       (x < 0 ? (((x >> 1) & 0x7FFFFFFFFFFFFFFF) >> 6)  : (x >> 7)) ))
			x=${W[j-2]}
			s1=$(( ( (x < 0 ? (((x >> 1) & 0x7FFFFFFFFFFFFFFF) >> 18) : (x >> 19)) | (x << 45) ) ^ \
			       ( (x < 0 ? (((x >> 1) & 0x7FFFFFFFFFFFFFFF) >> 60) : (x >> 61)) | (x << 3) ) ^ \
			       (x < 0 ? (((x >> 1) & 0x7FFFFFFFFFFFFFFF) >> 5)  : (x >> 6)) ))
			W[j]=$(( W[j-16] + s0 + W[j-7] + s1 ))
		done

		local A=$h0 B=$h1 C=$h2 D=$h3 E=$h4 F=$h5 G=$h6 H=$h7
		local S1 ch temp1 S0 maj temp2

		for (( i=0; i<80; i++ )); do
			x=$E
			S1=$(( ( (x < 0 ? (((x >> 1) & 0x7FFFFFFFFFFFFFFF) >> 13) : (x >> 14)) | (x << 50) ) ^ \
			       ( (x < 0 ? (((x >> 1) & 0x7FFFFFFFFFFFFFFF) >> 17) : (x >> 18)) | (x << 46) ) ^ \
			       ( (x < 0 ? (((x >> 1) & 0x7FFFFFFFFFFFFFFF) >> 40) : (x >> 41)) | (x << 23) ) ))
			ch=$(( (E & F) ^ ((~E) & G) ))
			temp1=$(( H + S1 + ch + _SHA512_K[i] + W[i] ))
			x=$A
			S0=$(( ( (x < 0 ? (((x >> 1) & 0x7FFFFFFFFFFFFFFF) >> 27) : (x >> 28)) | (x << 36) ) ^ \
			       ( (x < 0 ? (((x >> 1) & 0x7FFFFFFFFFFFFFFF) >> 33) : (x >> 34)) | (x << 30) ) ^ \
			       ( (x < 0 ? (((x >> 1) & 0x7FFFFFFFFFFFFFFF) >> 38) : (x >> 39)) | (x << 25) ) ))
			maj=$(( (A & B) ^ (A & C) ^ (B & C) ))
			temp2=$(( S0 + maj ))

			H=$G; G=$F; F=$E
			E=$(( D + temp1 ))
			D=$C; C=$B; B=$A
			A=$(( temp1 + temp2 ))
		done

		h0=$(( h0 + A )); h1=$(( h1 + B )); h2=$(( h2 + C )); h3=$(( h3 + D ))
		h4=$(( h4 + E )); h5=$(( h5 + F )); h6=$(( h6 + G )); h7=$(( h7 + H ))
	done

	local -a outbytes=()
	local word
	for word in "$h0" "$h1" "$h2" "$h3" "$h4" "$h5" "$h6" "$h7"; do
		for (( i=7; i>=0; i-- )); do
			outbytes+=($(( (word >> (i*8)) & 0xFF )))
		done
	done
	_hash::bytes_to_hex outbytes
}

# Keccak-f[1600] permutation on a 25-lane state (flat, st[x + 5y]).
# rotl64 is inlined via the same ushr64 ternary trick as SHA-512 — this
# runs 24 rounds x (5 theta + 24 rho/pi + 25 chi) lane ops per block.
# Usage: _hash::keccakf1600 state_arrayname (25 elements, mutated in place)
_hash::keccakf1600() {
	local -n _kf_st="$1"
	local r i j t t2 tt n
	local b0 b1 b2 b3 b4

	# Local (not module-global) so sourcing this file twice in one shell
	# never hits a readonly/redeclare clash.
	local -a _KECCAK_RNDC=(
		0x0000000000000001 0x0000000000008082 0x800000000000808a 0x8000000080008000
		0x000000000000808b 0x0000000080000001 0x8000000080008081 0x8000000000008009
		0x000000000000008a 0x0000000000000088 0x0000000080008009 0x000000008000000a
		0x000000008000808b 0x800000000000008b 0x8000000000008089 0x8000000000008003
		0x8000000000008002 0x8000000000000080 0x000000000000800a 0x800000008000000a
		0x8000000080008081 0x8000000000008080 0x0000000080000001 0x8000000080008008
	)
	local -a _KECCAK_ROTC=(1 3 6 10 15 21 28 36 45 55 2 14 27 41 56 8 25 43 62 18 39 61 20 44)
	local -a _KECCAK_PILN=(10 7 11 17 18 3 5 16 8 21 24 4 15 23 19 13 12 2 20 14 22 9 6 1)

	for (( r=0; r<24; r++ )); do
		# Theta
		b0=$(( _kf_st[0] ^ _kf_st[5] ^ _kf_st[10] ^ _kf_st[15] ^ _kf_st[20] ))
		b1=$(( _kf_st[1] ^ _kf_st[6] ^ _kf_st[11] ^ _kf_st[16] ^ _kf_st[21] ))
		b2=$(( _kf_st[2] ^ _kf_st[7] ^ _kf_st[12] ^ _kf_st[17] ^ _kf_st[22] ))
		b3=$(( _kf_st[3] ^ _kf_st[8] ^ _kf_st[13] ^ _kf_st[18] ^ _kf_st[23] ))
		b4=$(( _kf_st[4] ^ _kf_st[9] ^ _kf_st[14] ^ _kf_st[19] ^ _kf_st[24] ))

		tt=$b1; t=$(( (tt < 0 ? (((tt >> 1) & 0x7FFFFFFFFFFFFFFF) >> 62) : (tt >> 63)) | (tt << 1) )); t=$(( b4 ^ t ))
		for (( j=0; j<25; j+=5 )); do _kf_st[j+0]=$(( _kf_st[j+0] ^ t )); done
		tt=$b2; t=$(( (tt < 0 ? (((tt >> 1) & 0x7FFFFFFFFFFFFFFF) >> 62) : (tt >> 63)) | (tt << 1) )); t=$(( b0 ^ t ))
		for (( j=0; j<25; j+=5 )); do _kf_st[j+1]=$(( _kf_st[j+1] ^ t )); done
		tt=$b3; t=$(( (tt < 0 ? (((tt >> 1) & 0x7FFFFFFFFFFFFFFF) >> 62) : (tt >> 63)) | (tt << 1) )); t=$(( b1 ^ t ))
		for (( j=0; j<25; j+=5 )); do _kf_st[j+2]=$(( _kf_st[j+2] ^ t )); done
		tt=$b4; t=$(( (tt < 0 ? (((tt >> 1) & 0x7FFFFFFFFFFFFFFF) >> 62) : (tt >> 63)) | (tt << 1) )); t=$(( b2 ^ t ))
		for (( j=0; j<25; j+=5 )); do _kf_st[j+3]=$(( _kf_st[j+3] ^ t )); done
		tt=$b0; t=$(( (tt < 0 ? (((tt >> 1) & 0x7FFFFFFFFFFFFFFF) >> 62) : (tt >> 63)) | (tt << 1) )); t=$(( b3 ^ t ))
		for (( j=0; j<25; j+=5 )); do _kf_st[j+4]=$(( _kf_st[j+4] ^ t )); done

		# Rho + Pi
		t=${_kf_st[1]}
		for (( i=0; i<24; i++ )); do
			j=${_KECCAK_PILN[i]}
			t2=${_kf_st[j]}
			n=${_KECCAK_ROTC[i]}
			_kf_st[j]=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> (63 - n)) : (t >> (64 - n))) | (t << n) ))
			t=$t2
		done

		# Chi
		for (( j=0; j<25; j+=5 )); do
			b0=${_kf_st[j+0]}; b1=${_kf_st[j+1]}; b2=${_kf_st[j+2]}; b3=${_kf_st[j+3]}; b4=${_kf_st[j+4]}
			_kf_st[j+0]=$(( b0 ^ ((~b1) & b2) ))
			_kf_st[j+1]=$(( b1 ^ ((~b2) & b3) ))
			_kf_st[j+2]=$(( b2 ^ ((~b3) & b4) ))
			_kf_st[j+3]=$(( b3 ^ ((~b4) & b0) ))
			_kf_st[j+4]=$(( b4 ^ ((~b0) & b1) ))
		done

		# Iota
		_kf_st[0]=$(( _kf_st[0] ^ _KECCAK_RNDC[r] ))
	done
}

# SHA3-256: Keccak-f[1600] sponge, rate 136 bytes (1088 bits), SHA-3 domain
# separation byte 0x06.
# Usage: _hash::sha3_256::digest bytes_arrayname
_hash::sha3_256::digest() {
	local -n _sha3_msg="$1"
	local -a padded
	padded=("${_sha3_msg[@]}")
	local rate=136

	padded+=(0x06)
	while (( ${#padded[@]} % rate != 0 )); do padded+=(0); done
	padded[${#padded[@]}-1]=$(( padded[${#padded[@]}-1] | 0x80 ))

	local -a st=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
	local block_count=$(( ${#padded[@]} / rate ))
	local blk lane base idx k word

	for (( blk=0; blk<block_count; blk++ )); do
		base=$(( blk * rate ))
		for (( lane=0; lane<17; lane++ )); do
			idx=$(( base + lane*8 ))
			word=0
			for (( k=7; k>=0; k-- )); do
				word=$(( (word << 8) | padded[idx+k] ))
			done
			st[lane]=$(( st[lane] ^ word ))
		done
		_hash::keccakf1600 st
	done

	local -a outbytes=()
	local i
	for (( lane=0; lane<4; lane++ )); do
		word=${st[lane]}
		for (( i=0; i<8; i++ )); do
			outbytes+=($(( (word >> (i*8)) & 0xFF )))
		done
	done
	_hash::bytes_to_hex outbytes
}

# BLAKE2b-512 (RFC 7693), unkeyed — matches the b2sum/openssl default
# (64-byte digest) that hash::blake2b already emits.
# Usage: _hash::blake2b::digest bytes_arrayname
_hash::blake2b::digest() {
	local -n _b2b_msg="$1"
	local total_len=${#_b2b_msg[@]}
	local -a padded
	padded=("${_b2b_msg[@]}")

	# Local (not module-global) so sourcing this file twice in one shell
	# never hits a readonly/redeclare clash.
	local -a _BLAKE2B_IV=(
		0x6a09e667f3bcc908 0xbb67ae8584caa73b 0x3c6ef372fe94f82b 0xa54ff53a5f1d36f1
		0x510e527fade682d1 0x9b05688c2b3e6c1f 0x1f83d9abfb41bd6b 0x5be0cd19137e2179
	)
	local -a _BLAKE2B_SIGMA=(
		0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
		14 10 4 8 9 15 13 6 1 12 0 2 11 7 5 3
		11 8 12 0 5 2 15 13 10 14 3 6 7 1 9 4
		7 9 3 1 13 12 11 14 2 6 5 10 4 0 15 8
		9 0 5 7 2 4 10 15 14 1 11 12 6 8 3 13
		2 12 6 10 0 11 8 3 4 13 7 5 15 14 1 9
		12 5 1 15 14 13 4 10 0 7 6 3 9 2 8 11
		13 11 7 14 12 1 3 9 5 0 15 4 8 6 2 10
		6 15 14 9 11 3 0 8 12 2 13 7 1 4 10 5
		10 2 8 4 7 6 1 5 15 11 9 14 3 12 13 0
	)

	# BLAKE2b always compresses at least one (possibly all-zero) block.
	while (( ${#padded[@]} % 128 != 0 || ${#padded[@]} == 0 )); do padded+=(0); done

	local h0=$(( _BLAKE2B_IV[0] ^ 0x01010040 )) h1=${_BLAKE2B_IV[1]} h2=${_BLAKE2B_IV[2]} h3=${_BLAKE2B_IV[3]}
	local h4=${_BLAKE2B_IV[4]} h5=${_BLAKE2B_IV[5]} h6=${_BLAKE2B_IV[6]} h7=${_BLAKE2B_IV[7]}
	local block_count=$(( ${#padded[@]} / 128 )) blk bytes_compressed=0

	for (( blk=0; blk<block_count; blk++ )); do
		local base=$(( blk * 128 ))
		local -a m=()
		local j idx k
		for (( j=0; j<16; j++ )); do
			idx=$(( base + j*8 ))
			m[j]=0
			for (( k=7; k>=0; k-- )); do
				m[j]=$(( (m[j] << 8) | padded[idx+k] ))
			done
		done

		local is_last=0
		if (( blk == block_count - 1 )); then
			is_last=1; bytes_compressed=$total_len
		else
			bytes_compressed=$(( bytes_compressed + 128 ))
		fi

		local v0=$h0 v1=$h1 v2=$h2 v3=$h3 v4=$h4 v5=$h5 v6=$h6 v7=$h7
		local v8=${_BLAKE2B_IV[0]} v9=${_BLAKE2B_IV[1]} v10=${_BLAKE2B_IV[2]} v11=${_BLAKE2B_IV[3]}
		local v12=${_BLAKE2B_IV[4]} v13=${_BLAKE2B_IV[5]} v14=${_BLAKE2B_IV[6]} v15=${_BLAKE2B_IV[7]}

		v12=$(( v12 ^ bytes_compressed ))
		# v13 would XOR the high 64 bits of the byte counter; always 0 here
		# (inputs never approach 2^64 bytes).
		(( is_last )) && v14=$(( ~v14 ))

		local r sbase x y t
		for (( r=0; r<12; r++ )); do
			sbase=$(( (r % 10) * 16 ))

			# Each G(v,a,b,c,d,x,y) mixes one column or diagonal of the
			# state; rotr64 by 32/24/16/63 is inlined via the ushr64
			# ternary trick (see SHA-512 NOTE) since this runs 8x/round.
			x=${m[_BLAKE2B_SIGMA[sbase+0]]}; y=${m[_BLAKE2B_SIGMA[sbase+1]]}
			v0=$(( v0 + v4 + x )); t=$(( v12 ^ v0 )); v12=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 31) : (t >> 32)) | (t << 32) ))
			v8=$(( v8 + v12 )); t=$(( v4 ^ v8 )); v4=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 23) : (t >> 24)) | (t << 40) ))
			v0=$(( v0 + v4 + y )); t=$(( v12 ^ v0 )); v12=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 15) : (t >> 16)) | (t << 48) ))
			v8=$(( v8 + v12 )); t=$(( v4 ^ v8 )); v4=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 62) : (t >> 63)) | (t << 1) ))

			x=${m[_BLAKE2B_SIGMA[sbase+2]]}; y=${m[_BLAKE2B_SIGMA[sbase+3]]}
			v1=$(( v1 + v5 + x )); t=$(( v13 ^ v1 )); v13=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 31) : (t >> 32)) | (t << 32) ))
			v9=$(( v9 + v13 )); t=$(( v5 ^ v9 )); v5=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 23) : (t >> 24)) | (t << 40) ))
			v1=$(( v1 + v5 + y )); t=$(( v13 ^ v1 )); v13=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 15) : (t >> 16)) | (t << 48) ))
			v9=$(( v9 + v13 )); t=$(( v5 ^ v9 )); v5=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 62) : (t >> 63)) | (t << 1) ))

			x=${m[_BLAKE2B_SIGMA[sbase+4]]}; y=${m[_BLAKE2B_SIGMA[sbase+5]]}
			v2=$(( v2 + v6 + x )); t=$(( v14 ^ v2 )); v14=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 31) : (t >> 32)) | (t << 32) ))
			v10=$(( v10 + v14 )); t=$(( v6 ^ v10 )); v6=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 23) : (t >> 24)) | (t << 40) ))
			v2=$(( v2 + v6 + y )); t=$(( v14 ^ v2 )); v14=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 15) : (t >> 16)) | (t << 48) ))
			v10=$(( v10 + v14 )); t=$(( v6 ^ v10 )); v6=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 62) : (t >> 63)) | (t << 1) ))

			x=${m[_BLAKE2B_SIGMA[sbase+6]]}; y=${m[_BLAKE2B_SIGMA[sbase+7]]}
			v3=$(( v3 + v7 + x )); t=$(( v15 ^ v3 )); v15=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 31) : (t >> 32)) | (t << 32) ))
			v11=$(( v11 + v15 )); t=$(( v7 ^ v11 )); v7=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 23) : (t >> 24)) | (t << 40) ))
			v3=$(( v3 + v7 + y )); t=$(( v15 ^ v3 )); v15=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 15) : (t >> 16)) | (t << 48) ))
			v11=$(( v11 + v15 )); t=$(( v7 ^ v11 )); v7=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 62) : (t >> 63)) | (t << 1) ))

			x=${m[_BLAKE2B_SIGMA[sbase+8]]}; y=${m[_BLAKE2B_SIGMA[sbase+9]]}
			v0=$(( v0 + v5 + x )); t=$(( v15 ^ v0 )); v15=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 31) : (t >> 32)) | (t << 32) ))
			v10=$(( v10 + v15 )); t=$(( v5 ^ v10 )); v5=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 23) : (t >> 24)) | (t << 40) ))
			v0=$(( v0 + v5 + y )); t=$(( v15 ^ v0 )); v15=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 15) : (t >> 16)) | (t << 48) ))
			v10=$(( v10 + v15 )); t=$(( v5 ^ v10 )); v5=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 62) : (t >> 63)) | (t << 1) ))

			x=${m[_BLAKE2B_SIGMA[sbase+10]]}; y=${m[_BLAKE2B_SIGMA[sbase+11]]}
			v1=$(( v1 + v6 + x )); t=$(( v12 ^ v1 )); v12=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 31) : (t >> 32)) | (t << 32) ))
			v11=$(( v11 + v12 )); t=$(( v6 ^ v11 )); v6=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 23) : (t >> 24)) | (t << 40) ))
			v1=$(( v1 + v6 + y )); t=$(( v12 ^ v1 )); v12=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 15) : (t >> 16)) | (t << 48) ))
			v11=$(( v11 + v12 )); t=$(( v6 ^ v11 )); v6=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 62) : (t >> 63)) | (t << 1) ))

			x=${m[_BLAKE2B_SIGMA[sbase+12]]}; y=${m[_BLAKE2B_SIGMA[sbase+13]]}
			v2=$(( v2 + v7 + x )); t=$(( v13 ^ v2 )); v13=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 31) : (t >> 32)) | (t << 32) ))
			v8=$(( v8 + v13 )); t=$(( v7 ^ v8 )); v7=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 23) : (t >> 24)) | (t << 40) ))
			v2=$(( v2 + v7 + y )); t=$(( v13 ^ v2 )); v13=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 15) : (t >> 16)) | (t << 48) ))
			v8=$(( v8 + v13 )); t=$(( v7 ^ v8 )); v7=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 62) : (t >> 63)) | (t << 1) ))

			x=${m[_BLAKE2B_SIGMA[sbase+14]]}; y=${m[_BLAKE2B_SIGMA[sbase+15]]}
			v3=$(( v3 + v4 + x )); t=$(( v14 ^ v3 )); v14=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 31) : (t >> 32)) | (t << 32) ))
			v9=$(( v9 + v14 )); t=$(( v4 ^ v9 )); v4=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 23) : (t >> 24)) | (t << 40) ))
			v3=$(( v3 + v4 + y )); t=$(( v14 ^ v3 )); v14=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 15) : (t >> 16)) | (t << 48) ))
			v9=$(( v9 + v14 )); t=$(( v4 ^ v9 )); v4=$(( (t < 0 ? (((t >> 1) & 0x7FFFFFFFFFFFFFFF) >> 62) : (t >> 63)) | (t << 1) ))
		done

		h0=$(( h0 ^ v0 ^ v8 )); h1=$(( h1 ^ v1 ^ v9 ))
		h2=$(( h2 ^ v2 ^ v10 )); h3=$(( h3 ^ v3 ^ v11 ))
		h4=$(( h4 ^ v4 ^ v12 )); h5=$(( h5 ^ v5 ^ v13 ))
		h6=$(( h6 ^ v6 ^ v14 )); h7=$(( h7 ^ v7 ^ v15 ))
	done

	local -a outbytes=()
	local word i
	for word in "$h0" "$h1" "$h2" "$h3" "$h4" "$h5" "$h6" "$h7"; do
		for (( i=0; i<8; i++ )); do
			outbytes+=($(( (word >> (i*8)) & 0xFF )))
		done
	done
	_hash::bytes_to_hex outbytes
}

# Generic HMAC (RFC 2104), layered on any of the byte-array digest engines
# above. block_size is the algorithm's internal block size in bytes (64 for
# MD5/SHA-1/SHA-256, 128 for SHA-512).
# Usage: _hash::hmac::generic digest_func block_size key message
_hash::hmac::generic() {
	local digest_func="$1" block_size="$2" key="$3" msg="$4"
	local -a key_bytes; _hash::str_to_bytes key_bytes "$key"

	if (( ${#key_bytes[@]} > $block_size )); then
		local hashed_key; hashed_key=$("$digest_func" key_bytes)
		_hash::hex_to_bytes key_bytes "$hashed_key"
	fi
	while (( ${#key_bytes[@]} < $block_size )); do key_bytes+=(0); done

	local -a msg_bytes; _hash::str_to_bytes msg_bytes "$msg"
	local -a ipad_block=() opad_block=()
	local i
	for (( i=0; i<$block_size; i++ )); do
		ipad_block+=($(( key_bytes[i] ^ 0x36 )))
		opad_block+=($(( key_bytes[i] ^ 0x5c )))
	done

	local -a inner=("${ipad_block[@]}" "${msg_bytes[@]}")
	local inner_hex; inner_hex=$("$digest_func" inner)
	local -a inner_bytes; _hash::hex_to_bytes inner_bytes "$inner_hex"

	local -a outer=("${opad_block[@]}" "${inner_bytes[@]}")
	"$digest_func" outer
}

# --- CRYPTOGRAPHIC ---

# MD5 hash of a string
# Usage: hash::md5 string
hash::md5() {
	local input; _hash::read_input input "$@"
		if runtime::has_command md5sum; then
				_hash::pipe "$input" md5sum | awk '{print $1}'
		elif runtime::has_command md5; then
				_hash::pipe "$input" md5 -q 2>/dev/null || \
				_hash::pipe "$input" md5 | awk '{print $NF}'
		else
				local -a _bytes; _hash::str_to_bytes _bytes "$input"
				_hash::md5::digest _bytes
				echo
		fi
}

# SHA1 hash of a string
hash::sha1() {
	local input; _hash::read_input input "$@"
		if runtime::has_command sha1sum; then
				_hash::pipe "$input" sha1sum | awk '{print $1}'
		elif runtime::has_command shasum; then
				_hash::pipe "$input" shasum -a 1 | awk '{print $1}'
		elif runtime::has_command openssl; then
				_hash::pipe "$input" openssl dgst -sha1 | awk '{print $NF}'
		else
				local -a _bytes; _hash::str_to_bytes _bytes "$input"
				_hash::sha1::digest _bytes
				echo
		fi
}

# SHA256 hash of a string
hash::sha256() {
	local input; _hash::read_input input "$@"
		if runtime::has_command sha256sum; then
				_hash::pipe "$input" sha256sum | awk '{print $1}'
		elif runtime::has_command shasum; then
				_hash::pipe "$input" shasum -a 256 | awk '{print $1}'
		elif runtime::has_command openssl; then
				_hash::pipe "$input" openssl dgst -sha256 | awk '{print $NF}'
		else
				local -a _bytes; _hash::str_to_bytes _bytes "$input"
				_hash::sha256::digest _bytes
				echo
		fi
}

# SHA512 hash of a string
hash::sha512() {
	local input; _hash::read_input input "$@"
		if runtime::has_command sha512sum; then
				_hash::pipe "$input" sha512sum | awk '{print $1}'
		elif runtime::has_command shasum; then
				_hash::pipe "$input" shasum -a 512 | awk '{print $1}'
		elif runtime::has_command openssl; then
				_hash::pipe "$input" openssl dgst -sha512 | awk '{print $NF}'
		else
				local -a _bytes; _hash::str_to_bytes _bytes "$input"
				_hash::sha512::digest _bytes
				echo
		fi
}

# SHA3-256 hash of a string
hash::sha3_256() {
	local input; _hash::read_input input "$@"
		if runtime::has_command openssl; then
				_hash::pipe "$input" openssl dgst -sha3-256 2>/dev/null | awk '{print $NF}'
		else
				local -a _bytes; _hash::str_to_bytes _bytes "$input"
				_hash::sha3_256::digest _bytes
				echo
		fi
}

# BLAKE2b hash of a string
hash::blake2b() {
	local input; _hash::read_input input "$@"
		if runtime::has_command b2sum; then
				_hash::pipe "$input" b2sum | awk '{print $1}'
		elif runtime::has_command openssl; then
				_hash::pipe "$input" openssl dgst -blake2b512 2>/dev/null | awk '{print $NF}'
		else
				local -a _bytes; _hash::str_to_bytes _bytes "$input"
				_hash::blake2b::digest _bytes
				echo
		fi
}

# --- HMAC ---

# HMAC-SHA256
# Usage: hash::hmac::sha256 key message
hash::hmac::sha256() {
		local key="$1" msg="$2"
		if runtime::has_command openssl; then
				printf '%s' "$msg" | \
						openssl dgst -sha256 -hmac "$key" 2>/dev/null | awk '{print $NF}'
		else
				_hash::hmac::generic _hash::sha256::digest 64 "$key" "$msg"
				echo
		fi
}

# HMAC-SHA512
# Usage: hash::hmac::sha512 key message
hash::hmac::sha512() {
		local key="$1" msg="$2"
		if runtime::has_command openssl; then
				printf '%s' "$msg" | \
						openssl dgst -sha512 -hmac "$key" 2>/dev/null | awk '{print $NF}'
		else
				_hash::hmac::generic _hash::sha512::digest 128 "$key" "$msg"
				echo
		fi
}

# HMAC-MD5
# Usage: hash::hmac::md5 key message
hash::hmac::md5() {
		local key="$1" msg="$2"
		if runtime::has_command openssl; then
				printf '%s' "$msg" | \
						openssl dgst -md5 -hmac "$key" 2>/dev/null | awk '{print $NF}'
		else
				_hash::hmac::generic _hash::md5::digest 64 "$key" "$msg"
				echo
		fi
}

# NON-CRYPTOGRAPHIC — pure bash implementations
# Fast, portable, suitable for hash tables, caching keys, bloom filters.
# NOT suitable for security use.

# DJB2 — Daniel J. Bernstein's hash, classic and fast
# Returns unsigned 32-bit integer
# Usage: hash::djb2 string
hash::djb2() {
	local input; _hash::read_input input "$@"
		local _str="$input" hash=5381 i char
		for (( i=0; i<${#_str}; i++ )); do
				char=$(printf '%d' "'${_str:$i:1}")
				hash=$(( ((hash << 5) + hash + char) & 0xFFFFFFFF ))
		done
		echo "$hash"
}

# DJB2a (xor variant) — slightly better distribution than djb2
hash::djb2a() {
	local input; _hash::read_input input "$@"
		local _str="$input" hash=5381 i char
		for (( i=0; i<${#_str}; i++ )); do
				char=$(printf '%d' "'${_str:$i:1}")
				hash=$(( ((hash << 5) + hash ^ char) & 0xFFFFFFFF ))
		done
		echo "$hash"
}

# SDBM hash — used in the SDBM database library
# Often outperforms DJB2 for database keys
hash::sdbm() {
	local input; _hash::read_input input "$@"
		local _str="$input" hash=0 i char
		for (( i=0; i<${#_str}; i++ )); do
				char=$(printf '%d' "'${_str:$i:1}")
				hash=$(( (char + (hash << 6) + (hash << 16) - hash) & 0xFFFFFFFF ))
		done
		echo "$hash"
}

# FNV-1a 32-bit — Fowler-Noll-Vo, excellent avalanche, widely used
# Period: 2^32
hash::fnv1a32() {
	local input; _hash::read_input input "$@"
		local _str="$input" hash=2166136261 i char
		for (( i=0; i<${#_str}; i++ )); do
				char=$(printf '%d' "'${_str:$i:1}")
				hash=$(( (hash ^ char) * 16777619 & 0xFFFFFFFF ))
		done
		echo "$hash"
}

# FNV-1a 64-bit — larger state, better for longer strings
# Note: bash uses signed 64-bit integers; result may be negative for large hashes
hash::fnv1a64() {
	local input; _hash::read_input input "$@"
		local _str="$input"
		local hash_lo=2166136261 hash_hi=0
		local fnv_prime_lo=16777619 i char

		for (( i=0; i<${#_str}; i++ )); do
				char=$(printf '%d' "'${_str:$i:1}")
				# XOR low 32 bits with byte
				hash_lo=$(( (hash_lo ^ char) & 0xFFFFFFFF ))
				# Multiply: (hi:lo) * prime — simplified since prime fits in 32 bits
				local new_lo=$(( (hash_lo * fnv_prime_lo) & 0xFFFFFFFF ))
				local carry=$(( hash_lo * fnv_prime_lo >> 32 ))
				hash_hi=$(( (hash_hi * fnv_prime_lo + carry) & 0xFFFFFFFF ))
				hash_lo=$new_lo
		done

		printf '%08x%08x\n' "$hash_hi" "$hash_lo"
}

# Adler-32 — fast checksum used in zlib/PNG
# Not a hash in the traditional sense but useful for data integrity
hash::adler32() {
	local input; _hash::read_input input "$@"
		local _str="$input"
		local a=1 b=0 i char MOD=65521

		for (( i=0; i<${#_str}; i++ )); do
				char=$(printf '%d' "'${_str:$i:1}")
				a=$(( (a + char) % MOD ))
				b=$(( (b + a) % MOD ))
		done

		echo $(( (b << 16) | a ))
}

# CRC32 — delegates to system tools, pure bash fallback is too slow for real use
# Usage: hash::crc32 string
hash::crc32() {
	local input; _hash::read_input input "$@"
		local _str="$input"
		if runtime::has_command crc32; then
				printf '%s' "$_str" | crc32 /dev/stdin 2>/dev/null
		elif runtime::has_command python3; then
				python3 -c "import binascii,sys; print('%08x' % (binascii.crc32(sys.argv[1].encode()) & 0xffffffff))" "$_str"
		elif runtime::has_command cksum; then
				# cksum uses CRC but with a different algorithm — close but not standard CRC32
				printf '%s' "$_str" | cksum | awk '{print $1}'
		else
				echo "hash::crc32: requires crc32, python3, or cksum" >&2
				return 1
		fi
}

# MurmurHash2 — pure bash, good distribution, faster than cryptographic hashes
# Austin Appleby, 2008
hash::murmur2() {
	local input; _hash::read_input input "$@"
		local _str="$input" seed="${2:-0}"
		local len="${#_str}"
		local m=2246822519 r=13
		local h=$(( seed ^ len ))
		local i=0 k

		while (( i + 4 <= len )); do
				local c0; c0=$(printf '%d' "'${_str:$i:1}")
				local c1; c1=$(printf '%d' "'${_str:$((i+1)):1}")
				local c2; c2=$(printf '%d' "'${_str:$((i+2)):1}")
				local c3; c3=$(printf '%d' "'${_str:$((i+3)):1}")
				k=$(( c0 | (c1 << 8) | (c2 << 16) | (c3 << 24) ))
				k=$(( (k * m) & 0xFFFFFFFF ))
				k=$(( k ^ (k >> r) ))
				k=$(( (k * m) & 0xFFFFFFFF ))
				h=$(( (h * m) & 0xFFFFFFFF ))
				h=$(( (h ^ k) & 0xFFFFFFFF ))
				(( i += 4 ))
		done

		# Handle remaining bytes
		local remaining=$(( len - i ))
		case "$remaining" in
		3) h=$(( h ^ ($(printf '%d' "'${_str:$((i+2)):1}") << 16) )) ;&
		2) h=$(( h ^ ($(printf '%d' "'${_str:$((i+1)):1}") << 8)  )) ;&
		1) h=$(( h ^ $(printf '%d' "'${_str:$i:1}") ))
			 h=$(( (h * m) & 0xFFFFFFFF ))
			 ;;
		esac

		h=$(( h ^ (h >> 13) ))
		h=$(( (h * m) & 0xFFFFFFFF ))
		h=$(( h ^ (h >> 15) ))

		echo "$h"
}

# --- UTILITY ---

# Verify a string against a known hash
# Usage: hash::verify string expected_hash algorithm
# Example: hash::verify "hello" "2cf24dba..." sha256
hash::verify() {
		local _str="$1" expected="$2" algo="${3:-sha256}"
		local actual
		actual=$(hash::"$algo" "$_str" 2>/dev/null) || return 1
		[[ "$actual" == "$expected" ]]
}

# Consistent hashing — map a value to a bucket (0 to n-1)
# Useful for load balancing, sharding, cache partitioning
# Usage: hash::slot n_buckets value
hash::slot() {
		local n="$1" value="$2"
		local h
		h=$(hash::fnv1a32 "$value")
		echo $(( h % n ))
}

# Generate a short hash — first n chars of sha256
# Usage: hash::short string [length]
hash::short() {
	local input; _hash::read_input input "$@"
		local _str="$input" len="${2:-8}"
		local full
		full=$(hash::sha256 "$_str") || return 1
		echo "${full:0:$len}"
}

# Hash multiple values into one — useful for cache keys from multiple inputs
# Usage: hash::combine val1 val2 val3 ...
hash::combine() {
		local combined
		combined=$(printf '%s\0' "$@" | hash::sha256 /dev/stdin 2>/dev/null) || \
		combined=$(printf '%s:' "$@" | hash::sha256)
		echo "$combined"
}

# Check if two strings have the same hash (constant-time safe via hash comparison)
# Usage: hash::equal string1 string2 [algorithm]
hash::equal() {
		local _hash_a _hash_b algo="${3:-sha256}"
		_hash_a=$(hash::"$algo" "$1" 2>/dev/null) || return 1
		_hash_b=$(hash::"$algo" "$2" 2>/dev/null) || return 1
		[[ "$_hash_a" == "$_hash_b" ]]
}

# Generate a hash-based UUID v5 (name-based, SHA1)
# Usage: hash::uuid5 namespace name
# Namespace can be a UUID or a well-known string
hash::uuid5() {
		# uuidgen doesn't support v5 on all platforms — fall back to sha1-based manual construction
		local raw
		raw=$(hash::sha1 "${1}:${2}")
		printf '%s-%s-%s-%s-%s\n' \
				"${raw:0:8}" "${raw:8:4}" "5${raw:13:3}" \
				"$(printf '%x' $(( (16#${raw:16:2} & 0x3f) | 0x80 )))${raw:18:2}" \
				"${raw:20:12}"
}

