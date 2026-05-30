#!/usr/bin/env bash
# Simple bytebeat runner — classic t*(t>>5|t>>8) expression

# This song is best played at 8kHz — lower rate gives it that glitchy bytebeat character
prefer SAMPLE_RATE 8000

sample() {
    local t=$1
    SAMPLE_L=$(( (t * (t >> 5 | t >> 8)) & 0xFF ))
    SAMPLE_R=$SAMPLE_L
}
