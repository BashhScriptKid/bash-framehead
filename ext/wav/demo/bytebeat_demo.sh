#!/usr/bin/env bash

# ---------------------------------------------------------------
# Bytebeat drum‑&‑bass demo (ext/wav/demo/bytebeat_demo.sh)
# Port of the AdvancedTechnology pseudocode, using pfloat::fixed
# for all floating‑point arithmetic.  bc is used only for the
# Math.sin call (Layer‑1 sine waves).
#
# Fast mode:  FAST_MODE=1 ./ext/wav/demo/bytebeat_demo.sh [out.wav]
# Uses fixed‑point integer arithmetic (scale 10^4) for
# sample‑generation hot path – ~10× faster, slightly noisier.
# ---------------------------------------------------------------

DIR="$(dirname "${BASH_SOURCE[0]}")"
source "${DIR}/../../../bash-framehead.sh"
source "${DIR}/../wav.sh"
source "${DIR}/../../../src/pfloat.sh"

# ---------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------
RATE=8000
CHANNELS=2
ENCODING=u8
BIT_DEPTH=8
OUTPUT="${1:-bytebeat.wav}"

# ---------------------------------------------------------------
# Global state
# ---------------------------------------------------------------
t=0
frame=0
start_ns=$(date +%s%N)
last_elapsed_ns=0
DATA=$(mktemp "/tmp/bytebeat-data.XXXXXX")
HDR=$(mktemp "/tmp/bytebeat-hdr.XXXXXX")

# ---------------------------------------------------------------
# Constants
# ---------------------------------------------------------------
BASE_INTERVAL=4096
HALF_INTERVAL=$(( BASE_INTERVAL / 2 ))
CONSTANT16=16
STRUCTURE_THRESHOLD=12
CONST1_5=1.5
BASE_MODULATION=0.1
FINE_MODULATION=0.01
MICRO_MODULATION=0.0001

# Fast-mode scaled constants (scale = 10^4)
if [[ -n "$FAST_MODE" ]]; then
    _S=10000
    _C1_5=15000
    _BASE_MOD=1000
    _FINE_MOD=100
    _MICRO_MOD=1
fi

# ---------------------------------------------------------------
# Envelope
# ---------------------------------------------------------------
envelope() {
    local period=$1 phaseOffset=${2:-0} periodMultiplier=${3:-1} amplitudeLimit=${4:-1}
    local _ct _st _cl _pos _rv _cv _lv
    pfloat::fixed::add::fast "$t" "$phaseOffset" _ct
    pfloat::fixed::mul::fast "$_ct" "$periodMultiplier" _st
    pfloat::fixed::mul::fast "$period" "$periodMultiplier" _cl
    pfloat::fixed::mod::fast "$_st" "$_cl" _pos
    pfloat::fixed::sub::fast "$period" "$_pos" _rv
    pfloat::fixed::div::fast "$_rv" "$period" _rv
    pfloat::fixed::max::fast "$_rv" "0" _cv
    pfloat::fixed::min::fast "$_cv" "$amplitudeLimit" _lv
    pfloat::fixed::div::fast "$_lv" "$amplitudeLimit" _rv
    echo "$_rv"
}

# ---------------------------------------------------------------
# noteFrequency
# ---------------------------------------------------------------
noteFrequency() {
    local noteIndex=$1
    local shifted=$(( noteIndex + 4 ))
    local _bp _oc _mr _t1 _t2
    pfloat::fixed::mul::fast "0.09" "$pitchScale" _bp
    pfloat::fixed::add::fast "1.45" "$_bp" _bp
    local octaveMultiplier=$(( 1 << (shifted / 7) ))
    local isUpper=$(( shifted % 7 > 3 ? 1 : 0 ))
    local microAdj=$(( (2 * shifted) % 14 - isUpper ))
    pfloat::fixed::pow::fast "1.0594" "$microAdj" _mr
    pfloat::fixed::mul::fast "$_bp" "$octaveMultiplier" _t1
    pfloat::fixed::mul::fast "$_t1" "$_mr" _t2
    echo "$_t2"
}

# ---------------------------------------------------------------
# randomMod
# ---------------------------------------------------------------
randomMod() {
    local x=$1
    local sq=$(( x * x ))
    local mask=$(( t & 495 ))
    local divisor=$(( mask + 1 ))
    local _dr _fp _r
    pfloat::fixed::div::fast "$sq" "$divisor" _dr
    pfloat::fixed::mod::fast "$_dr" "1" _fp
    pfloat::fixed::mul::fast "64" "$_fp" _r
    echo "$_r"
}

# ---------------------------------------------------------------
# phaseRamp
# ---------------------------------------------------------------
phaseRamp() {
    local _r
    pfloat::fixed::div::fast "$(( t % $1 ))" "$1" _r
    echo "$_r"
}

# ---------------------------------------------------------------
# bitwiseOsc
# ---------------------------------------------------------------
bitwiseOsc() {
    local noteIndex=$1
    local freqMultiplier=${2:-$(pfloat::fixed::add "1" "$FINE_MODULATION")}
    local oscMultiplier=${3:-1} bitShift=${4:-1} oscModStrength=${5:-$BASE_MODULATION} timeOffset=${6:-0}
    local _bf _tm _tm1 _tm2 _o1 _o2 _o1i _o2i _co _am _ai
    _bf=$(noteFrequency "$noteIndex")
    pfloat::fixed::mul::fast "$timeOffset" "$timeScale" _tm1
    pfloat::fixed::mul::fast "$oscModStrength" "$clockDivider" _tm2
    pfloat::fixed::add::fast "$_tm1" "$_tm2" _tm
    pfloat::fixed::add::fast "$_tm" "$t" _tm
    pfloat::fixed::mul::fast "$_bf" "$_tm" _o1
    pfloat::fixed::mul::fast "$freqMultiplier" "$_bf" _o2
    pfloat::fixed::mul::fast "$_o2" "$_tm" _o2
    pfloat::fixed::trunc::fast "$_o1" _o1i
    pfloat::fixed::trunc::fast "$_o2" _o2i
    _co=$(( _o1i | (_o2i << bitShift) ))
    pfloat::fixed::mul::fast "$oscMultiplier" "$_co" _am
    pfloat::fixed::trunc::fast "$_am" _ai
    echo $(( _ai % 256 ))
}

# ---------------------------------------------------------------
# layeredOsc  (pfloat version, used outside fast‑mode hot path)
# ---------------------------------------------------------------
layeredOsc() {
    local noteIndex=$1 voiceWeight=${2:-1}
    local _prb _tc _tc1 _fm _fm1 _bo _r
    _prb=$(phaseRamp "$BASE_INTERVAL")
    pfloat::fixed::mul::fast "$BASE_MODULATION" "$_prb" _tc1
    pfloat::fixed::add::fast "$FINE_MODULATION" "$_tc1" _tc
    pfloat::fixed::mul::fast "$alternatingFlag" "$_tc" _tc
    pfloat::fixed::mul::fast "$MICRO_MODULATION" "$channelOffset" _fm1
    pfloat::fixed::add::fast "$MICRO_MODULATION" "$_fm1" _fm
    pfloat::fixed::add::fast "1" "$_fm" _fm
    _bo=$(bitwiseOsc "$noteIndex" "$_fm" "$voiceWeight" "$((1 + oddEvenFlag))")
    pfloat::fixed::mul::fast "$_tc" "$_bo" _r
    echo "$_r"
}

# =================================================================
# FAST‑MODE hot path (integer fixed‑point, no subshells for math)
# =================================================================
if [[ -n "$FAST_MODE" ]]; then

_fast_mod() { _r=$(( $1 % $2 )); }
_fast_add() { _r=$(( $1 + $2 )); }
_fast_sub() { _r=$(( $1 - $2 )); }
_fast_mul() { _r=$(( $1 * $2 / _S )); }
_fast_div() { _r=$(( $1 * _S / $2 )); }
_fast_min() { _r=$(( $1 < $2 ? $1 : $2 )); }
_fast_max() { _r=$(( $1 > $2 ? $1 : $2 )); }
_fast_abs() { _r=$(( $1 < 0 ? -$1 : $1 )); }
_fast_trunc() { _r=$(( $1 / _S )); }

# Precomputed 1.0594^n lookup table (scaled by _S)
declare -a _TEMPER_TABLE
_fast_build_temper_table() {
    local i val=10000
    _TEMPER_TABLE=(0)  # index 0 placeholder
    _TEMPER_TABLE[0]=10000
    for ((i = 1; i <= 13; i++)); do
        val=$(( val * 10594 / 10000 ))
        _TEMPER_TABLE[i]=$val
    done
}
_fast_build_temper_table

# noteFrequency returning scaled value
_fast_note_freq() {
    local shifted=$(( $1 + 4 ))
    local basePitch=$(( 14500 + 900 * pitchScale / 100 ))
    local octaveMultiplier=$(( 1 << (shifted / 7) ))
    local isUpper=$(( shifted % 7 > 3 ? 1 : 0 ))
    local microAdj=$(( (2 * shifted) % 14 - isUpper ))
    local res=${_TEMPER_TABLE[$microAdj]:-10000}
    _r=$(( basePitch * octaveMultiplier * res / 10000 / 10000 ))
}

# randomMod returning scaled value (0 to 640000 = 64 * _S)
_fast_random_mod() {
    local sq=$(( $1 * $1 ))
    local mask=$(( t & 495 ))
    local divisor=$(( mask + 1 ))
    local div=$(( sq * _S / divisor ))
    local frac=$(( div % _S ))
    _r=$(( 64 * frac ))
}

# phaseRamp returning scaled 0‑1
_fast_phase_ramp() {
    _r=$(( (t % $1) * _S / $1 ))
}

# envelope returning scaled 0‑1
_fast_envelope() {
    local period=$1 phaseOffset=$2 periodMultiplier=$3 amplitudeLimit=$4
    local currentTime=$(( t * _S + phaseOffset ))
    local scaledTime=$(( currentTime * periodMultiplier / _S ))
    local cycleLength=$(( period * periodMultiplier / _S ))
    local pos=$(( cycleLength == 0 ? 0 : scaledTime % cycleLength ))
    local ramp=$(( (period - pos) * _S / (period == 0 ? 1 : period) ))
    (( ramp < 0 )) && ramp=0
    (( ramp > amplitudeLimit )) && ramp=$amplitudeLimit
    _r=$(( ramp * _S / (amplitudeLimit == 0 ? 1 : amplitudeLimit) ))
}

# bitwiseOsc returning integer 0‑255
_fast_bitwise_osc() {
    local noteIndex=$1
    local freqMultiplier=${2:-$(( _S + _FINE_MOD ))}  # 1 + fineMod scaled
    local oscMultiplier=${3:-$_S}                     # 1 scaled
    local bitShift=${4:-1}
    local oscModStrength=${5:-$_BASE_MOD}
    local timeOffset=${6:-0}
    local _basefreq
    _fast_note_freq "$noteIndex"; _basefreq=$_r
    local _tm1 _tm2
    _fast_mul "$timeOffset" "$timeScale"; _tm1=$_r
    _fast_mul "$oscModStrength" "$clockDivider"; _tm2=$_r
    local modulatedTime=$(( _tm1 + _tm2 + t * _S ))
    local osc1=$(( _basefreq * modulatedTime / _S ))
    local osc2=$(( freqMultiplier * osc1 ))  # freqMult * (baseFreq * modTime / _S) / _S = baseFreq * modTime * freqMult / _S^2
    local osc1i=$(( osc1 / _S ))
    local osc2i=$(( osc2 / _S ))
    local combined=$(( osc1i | (osc2i << bitShift) ))
    _r=$(( oscMultiplier * combined / _S % 256 ))
}

_fast_layered_osc() {
    local noteIndex=$1 voiceWeight=${2:-$_S}
    local _pr
    _fast_phase_ramp "$BASE_INTERVAL"; _pr=$_r
    local tc=$(( alternatingFlag * (_FINE_MOD + _BASE_MOD * _pr / _S) ))
    local fm=$(( _S + _MICRO_MOD + _MICRO_MOD * channelOffset / _S ))
    local _bo
    _fast_bitwise_osc "$noteIndex" "$fm" "$voiceWeight" "$((1 + oddEvenFlag))" "$_BASE_MOD" 0; _bo=$_r
    _r=$(( tc * _bo / _S ))
}

_fast_generate_channel() {
    local channelOffset=$1 channelMod=$2
    local lfoSlow=$(( t >> 11 ))
    local lfoSlower=$(( t >> 12 ))
    local songStructure=$(( t >> 13 ))
    local oddEvenFlag=$(( songStructure % 2 ))
    local slowPhase=$(( songStructure % 8 ))
    local macroStructure=$(( songStructure >> 3 ))
    local structureGate=$(( (songStructure % 32) < 31 ? 1 : 0 ))
    pitchScale=$(( macroStructure < 24 ? (songStructure >> 7) : (songStructure >> 6) ))
    local sixteenthCycle=$((( (songStructure >> 4) % 2 )))
    alternatingFlag=$(( sixteenthCycle == 0 ? 1 : 0 ))
    local integerTime=$t

    # timeScale (scaled)
    local inner_mod=$(( t % (HALF_INTERVAL * 64) ))
    local inner2=$(( ((t / 2) % (HALF_INTERVAL * 32)) / (HALF_INTERVAL * 2) ))
    local denominator=$(( 2 + inner2 ))
    local mod_res=$(( inner_mod % denominator ))
    if (( mod_res == 0 )); then
        timeScale=0
    else
        timeScale=$(( 4 * macroStructure * _S / mod_res ))
    fi

    # clockDivider (scaled)
    local cd_den=$(( (integerTime % HALF_INTERVAL) / 64 ))
    (( cd_den == 0 )) && cd_den=1
    clockDivider=$(( 80 * _S / cd_den ))

    # Noise sources
    local _nm _ni
    _fast_random_mod $(( t + channelOffset )); _nm=$_r
    _fast_random_mod $(( integerTime + channelOffset )); _ni=$_r

    # Rhythm divisor
    local xor_val=$(( 5 ^ lfoSlow ))
    local rhythmDivisor=$(( (xor_val % 7) % 2 + 1 ))
    (( slowPhase == 7 )) && rhythmDivisor=1

    local layer1=0 layer2=0 layer3=0 layer4=0
    local layer5=0 layer6=0 layer7=0 layer8=0

    # ---- Layer 1 ----
    if (( songStructure > 2 )); then
        local timeMod1=$(( t % (CONSTANT16 * HALF_INTERVAL) ))
        local cond=$(( (songStructure > 15 && alternatingFlag) ))
        local timeMod2=$(( timeMod1 % ((7 - 5 * cond) * HALF_INTERVAL) ))
        local timeMod3=$(( timeMod2 % (4 * HALF_INTERVAL) ))
        local freqDiv=$(( timeMod3 * _S / 8 / _S + 48 * _S ))
        local _fsv; pfloat::fixed::from_scaled::fast "$freqDiv" _fsv
        local sineVal=$(bc -l <<< "s(2000 / $_fsv)")
        local _av; pfloat::fixed::abs::fast "$sineVal" _av
        pfloat::fixed::mul::fast "64" "$_av" _av
        layer1=$(( $(printf "%.0f" "$_av") * _S ))
    fi

    # ---- Layer 2 ----
    if (( songStructure > 6 )); then
        local condition1=$(( alternatingFlag && songStructure > STRUCTURE_THRESHOLD ? 1 : 0 ))
        local condition2=$(( lfoSlow + songStructure ))
        local condition3=$(( slowPhase == 6 ? 1 : 0 ))
        local shiftAmount=$(( ( (condition1 ^ (condition2 - condition3)) % 3 ) + 1 - condition1 ))
        local envPeriod=$(( BASE_INTERVAL << shiftAmount ))  # scaled? no, period used as-is
        local envMult=$(( _C1_5 + (lfoSlower % 5) * _S ))
        local _env
        _fast_envelope "$(( envPeriod * _S ))" 0 "$envMult" "$(( _S / 10 ))"; _env=$_r  # amplitudeLimit=0.1
        layer2=$(( 22 * (_ni + _nm) / 100 * _env / _S * structureGate / _S ))
    fi

    # ---- Layer 3 ----
    if (( songStructure > 7 )); then
        local _e1 _e2 _e3
        _fast_envelope "$(( BASE_INTERVAL * _S ))" "$(( HALF_INTERVAL * _S ))" "$(( 4 * _S ))" "$_S"; _e1=$_r
        _fast_envelope "$(( 2 * BASE_INTERVAL * _S ))" "$(( BASE_INTERVAL * _S ))" "$(( 4 * _S ))" "$_S"; _e2=$_r
        _fast_envelope "$(( HALF_INTERVAL * 32 * _S ))" 0 "$(( 13 * _S / 10 ))" "$_S"; _e3=$_r
        local p1=$(( 5 * _nm / 10 * _e1 / _S * structureGate / _S ))
        local p2=$(( 54 * _ni / 100 * _e2 / _S ))
        local p3=$(( _BASE_MOD * (_ni + _nm) / _S * _e3 / _S ))
        local _pr
        _fast_phase_ramp "$BASE_INTERVAL"; _pr=$_r
        local p4=$(( 14 * (3 * _S - 2 * _S * structureGate / _S) / 100 * _nm / _S * _pr / _S ))
        layer3=$(( p1 + p2 + p3 + p4 ))
    fi

    # ---- Layer 4 ----
    if (( songStructure > 13 )); then
        local envMult=$(( (8 - slowPhase) * _S ))
        local _env
        _fast_envelope "$(( HALF_INTERVAL / 2 * _S ))" 0 "$envMult" "$_S"; _env=$_r
        layer4=$(( 3 * _ni / 10 * _env / _S * structureGate / _S ))
    fi

    # ---- Layer 5 ----
    if (( songStructure > 15 )); then
        local shouldPlay=$(( macroStructure == 11 || (macroStructure > 12 && sixteenthCycle) ? 1 : 0 ))
        local gateSignal=$(( shouldPlay ? ((7 ^ songStructure) % 3 + 1) % 2 : 1 ))
        local isValidPhase=$(( macroStructure % 4 != 2 + (songStructure < 24 || songStructure > 96) ? 1 : 0 ))
        local baseNote=$(( 9 + 4 * alternatingFlag ))
        local noteAdjustment=$(( oddEvenFlag ? -3 + lfoSlow % 4 + slowPhase : (lfoSlow % 4 == 3) ? 1 : 0 ))
        local finalNote=$(( baseNote - noteAdjustment + lfoSlower % 2 ))
        local co_ch=0; (( channelOffset || structureGate )) && co_ch=1
        local fMult=$(( _S + 250 * _FINE_MOD / 100 - 2 * _FINE_MOD * co_ch / _S ))
        local addMod=$(( 32 * alternatingFlag * channelMod ))
        local periodVariation=$(( ((t % (CONSTANT16 * HALF_INTERVAL) % (7 * HALF_INTERVAL)) >> STRUCTURE_THRESHOLD) % 4 ))
        local envelopePeriod=$(( HALF_INTERVAL / 2 * (1 + periodVariation) * _S ))
        local baseMult=$(( (macroStructure == 14 ? 1 : 0) * _S / 2 + 14 * _S / 10 ))
        local envMult=$(( baseMult - 2 * alternatingFlag * _S / 10 ))
        local notSixteenthCycle=$(( 1 - sixteenthCycle ))
        local oscArg1=$(( fMult + addMod ))
        local oscArg2=$(( 3 * (lfoSlower % 5) * _S / 10 ))
        local oscArg3=$(( 1 + (macroStructure % 14 > 10 ? 1 : 0) ))
        local _bo1 _bo2 _bo3 _lo1 _lo2 _e4
        _fast_bitwise_osc "$finalNote" "$oscArg1" "$_S" "$oscArg3" "$_S" "$oscArg2"; _bo1=$_r
        _fast_envelope "$envelopePeriod" 0 "$envMult" "$_MICRO_MOD"; _e4=$_r
        local mainOsc=$(( isValidPhase * (16 * _S / 100 - _FINE_MOD * notSixteenthCycle / _S) * _bo1 * _e4 / _S / _S ))
        _fast_bitwise_osc "$CONSTANT16" \
            "$(( _S + _MICRO_MOD + CONSTANT16 * channelMod * alternatingFlag ))" \
            "$_C1_5" "$((1 + oddEvenFlag))"; _bo2=$_r
        local _e5
        _fast_envelope "$(( HALF_INTERVAL * _S ))" 0 "$(( 2 * _S ))" "$_MICRO_MOD"; _e5=$_r
        local altOsc=$(( alternatingFlag * 14 * _bo2 / 100 * _e5 / _S ))
        _fast_layered_osc 2 "$_C1_5"; _lo1=$_r
        _fast_layered_osc "$((6 - (songStructure >> 1) % 4))" "$(( 3 * _S ))"; _lo2=$_r
        local lo2_scaled=$(( _C1_5 * (pitchScale != 0 ? 1 : 0) * _lo2 / _S ))
        local l5sum=$(( mainOsc + altOsc + _C1_5 * _lo1 / _S + lo2_scaled ))
        layer5=$(( gateSignal * l5sum / _S ))
    fi

    # ---- Layer 6 ----
    if (( songStructure % CONSTANT16 < 14 )); then
        local noteBase=$(( 9 + (slowPhase > 5 ? 1 : 0) ))
        local songStructureGT7=$(( songStructure > 7 ? 1 : 0 ))
        local fMult=$(( _S + _FINE_MOD + channelMod * songStructureGT7 ))
        local envPeriod=$(( HALF_INTERVAL / rhythmDivisor * _S ))
        local envMult=$(( 127 * _S / 100 + (slowPhase == 7 ? 1 : 0) * _S ))
        local _bo _e6
        _fast_bitwise_osc "$noteBase" "$fMult" "$_C1_5" 1 "$_S" 1; _bo=$_r
        _fast_envelope "$envPeriod" 0 "$envMult" "$_MICRO_MOD"; _e6=$_r
        layer6=$(( 9 * _FINE_MOD * _bo * _e6 / _S / _S ))
    fi

    # ---- Layer 7 ----
    if (( songStructure > 2 )); then
        local noteValue=$(( 2 - lfoSlower % 2 ))
        local songStructureGT6=$(( songStructure > 6 ? 1 : 0 ))
        local fMult=$(( _S + _FINE_MOD + songStructureGT6 * _S ))
        local timingGate=$(( (lfoSlow + 18) % CONSTANT16 < 3 ? 1 : 0 ))
        local _bo
        _fast_bitwise_osc "$noteValue" "$fMult" "$_C1_5" 0; _bo=$_r
        layer7=$(( STRUCTURE_THRESHOLD * _FINE_MOD * _bo * timingGate / _S / _S ))
    fi

    # ---- Layer 8 ----
    if (( songStructure > 96 )); then
        local notePart1=$(( lfoSlower % 8 ))
        local notePart2=$(( (CONSTANT16 * macroStructure) % 8 ))
        local notePart3=$(( ((1 << (slowPhase % 2)) * ((2 + (slowPhase > 5 ? 1 : 0)) * t >> 11) ) % 6 ))
        local noteIndex=$(( notePart1 + notePart2 + notePart3 ))
        local fMult=$(( _S + _FINE_MOD * channelOffset / _S ))
        local shiftPattern=$(( (macroStructure ^ lfoSlow) % 2 ))
        local envPeriod=$(( HALF_INTERVAL / 2 << shiftPattern * _S ))
        local reduction=$(( (3 - songStructure % 3) * _S / 4 ))
        local envMult=$(( 14 * _S / 10 - reduction ))
        local _bo _e8
        _fast_bitwise_osc "$noteIndex" "$fMult" "$_S" 1 "$(( 4 * _S / 10 ))" 0; _bo=$_r
        _fast_envelope "$envPeriod" 0 "$envMult" "$_FINE_MOD"; _e8=$_r
        layer8=$(( 13 * _BASE_MOD / 10 * sixteenthCycle * (macroStructure % 4 != 2 ? 1 : 0) * _bo * _e8 / _S / _S / _S ))
    fi

    # Combine & clamp
    local l12=$(( layer1 + layer2 )) l34=$(( layer3 + layer4 ))
    local l56=$(( layer5 + layer6 )) l78=$(( layer7 + layer8 ))
    local sandwich=$(( l12 + l34 + l56 + l78 ))
    local scaled=$(( 12 * sandwich / 10 ))

    # Clamp to 0-255 in a single integer expression without subshell
    (( scaled = scaled < 0 ? 0 : (scaled > 255 * _S ? 255 * _S : scaled) ))
    _r=$(( scaled / _S ))
}

generateChannel() {
    _fast_generate_channel "$@"
    echo "$_r"
}

else
# =================================================================
# PFLOAT hot path (accurate, used when FAST_MODE is not set)
# =================================================================

generateChannel() {
    local channelOffset=$1 channelMod=$2
    local lfoSlow=$(( t >> 11 ))
    local lfoSlower=$(( t >> 12 ))
    local songStructure=$(( t >> 13 ))
    local oddEvenFlag=$(( songStructure % 2 ))
    local slowPhase=$(( songStructure % 8 ))
    local macroStructure=$(( songStructure >> 3 ))
    local structureGate=$(( (songStructure % 32) < 31 ? 1 : 0 ))
    local pitchScale=$(( macroStructure < 24 ? (songStructure >> 7) : (songStructure >> 6) ))
    local sixteenthCycle=$((( (songStructure >> 4) % 2 )))
    local alternatingFlag=$(( sixteenthCycle == 0 ? 1 : 0 ))
    local integerTime=$t

    # timeScale
    local inner_mod=$(( t % (HALF_INTERVAL * 64) ))
    local inner2=$(( ((t / 2) % (HALF_INTERVAL * 32)) / (HALF_INTERVAL * 2) ))
    local denominator=$(( 2 + inner2 ))
    local mod_res=$(( inner_mod % denominator ))
    if (( mod_res == 0 )); then
        timeScale=0
    else
        local _ts1; pfloat::fixed::mul::fast "4" "$macroStructure" _ts1
        pfloat::fixed::div::fast "$_ts1" "$mod_res" timeScale
    fi

    # clockDivider
    local cd_den=$(( (integerTime % HALF_INTERVAL) / 64 ))
    if (( cd_den == 0 )); then cd_den=1; fi
    pfloat::fixed::div::fast "80" "$cd_den" clockDivider

    # Noise sources
    local noiseCurrent=$(randomMod $(( t + channelOffset )) )
    local noiseInteger=$(randomMod $(( integerTime + channelOffset )) )

    # Rhythm divisor
    local xor_val=$(( 5 ^ lfoSlow ))
    local rhythmDivisor=$(( (xor_val % 7) % 2 + 1 ))
    if (( slowPhase == 7 )); then rhythmDivisor=1; fi

    local layer1=0 layer2=0 layer3=0 layer4=0
    local layer5=0 layer6=0 layer7=0 layer8=0

    # ---- Layer 1 ----
    if (( songStructure > 2 )); then
        local timeMod1=$(( t % (CONSTANT16 * HALF_INTERVAL) ))
        local cond=$(( (songStructure > 15 && alternatingFlag) ))
        local timeMod2=$(( timeMod1 % ((7 - 5 * cond) * HALF_INTERVAL) ))
        local timeMod3=$(( timeMod2 % (4 * HALF_INTERVAL) ))
        local _fd; pfloat::fixed::div::fast "$timeMod3" "8" _fd
        pfloat::fixed::add::fast "$_fd" "48" _fd
        local sineVal=$(bc -l <<< "s(2000 / $_fd)")
        local _av; pfloat::fixed::abs::fast "$sineVal" _av
        pfloat::fixed::mul::fast "64" "$_av" layer1
    fi

    # ---- Layer 2 ----
    if (( songStructure > 6 )); then
        local condition1=$(( alternatingFlag && songStructure > STRUCTURE_THRESHOLD ? 1 : 0 ))
        local condition2=$(( lfoSlow + songStructure ))
        local condition3=$(( slowPhase == 6 ? 1 : 0 ))
        local shiftAmount=$(( ( (condition1 ^ (condition2 - condition3)) % 3 ) + 1 - condition1 ))
        local envPeriod=$(( BASE_INTERVAL >> shiftAmount ))
        local _em; pfloat::fixed::add::fast "$CONST1_5" "$(( lfoSlower % 5 ))" _em
        local env=$(envelope "$envPeriod" 0 "$_em" 0.1)
        local _ni; local _ns; pfloat::fixed::add::fast "$noiseInteger" "$noiseCurrent" _ns
        pfloat::fixed::mul::fast "$env" "$structureGate" _ni
        pfloat::fixed::mul::fast "$_ns" "$_ni" _ni
        pfloat::fixed::mul::fast "0.22" "$_ni" layer2
    fi

    # ---- Layer 3 ----
    if (( songStructure > 7 )); then
        local _e1 _e2 _e3 _e4
        local _p1 _p2 _p3 _p4
        _e1=$(envelope "$BASE_INTERVAL" "$HALF_INTERVAL" 4)
        _e2=$(envelope "$((2*BASE_INTERVAL))" "$BASE_INTERVAL" 4)
        _e3=$(envelope "$((HALF_INTERVAL * 32))" 0 1.3)
        _e4=$(phaseRamp "$BASE_INTERVAL")
        local _t1 _t2 _t3 _t4 _t5
        pfloat::fixed::mul::fast "$_e1" "$structureGate" _t1
        pfloat::fixed::mul::fast "$noiseCurrent" "$_t1" _t1
        pfloat::fixed::mul::fast "0.5" "$_t1" _p1
        pfloat::fixed::mul::fast "$noiseInteger" "$_e2" _t2
        pfloat::fixed::mul::fast "0.54" "$_t2" _p2
        pfloat::fixed::add::fast "$noiseInteger" "$noiseCurrent" _t3
        pfloat::fixed::mul::fast "$_t3" "$_e3" _t3
        pfloat::fixed::mul::fast "$BASE_MODULATION" "$_t3" _p3
        pfloat::fixed::mul::fast "2" "$structureGate" _t4
        pfloat::fixed::sub::fast "3" "$_t4" _t4
        pfloat::fixed::mul::fast "$noiseCurrent" "$_e4" _t5
        pfloat::fixed::mul::fast "$_t4" "$_t5" _t5
        pfloat::fixed::mul::fast "0.14" "$_t5" _p4
        pfloat::fixed::add::fast "$_p1" "$_p2" _t1
        pfloat::fixed::add::fast "$_p3" "$_p4" _t2
        pfloat::fixed::add::fast "$_t1" "$_t2" layer3
    fi

    # ---- Layer 4 ----
    if (( songStructure > 13 )); then
        local envPeriod=$(( HALF_INTERVAL / 2 ))
        local envMult=$(( 8 - slowPhase ))
        local env=$(envelope "$envPeriod" 0 "$envMult" 1)
        local _t1; pfloat::fixed::mul::fast "$env" "$structureGate" _t1
        pfloat::fixed::mul::fast "$noiseInteger" "$_t1" _t1
        pfloat::fixed::mul::fast "0.3" "$_t1" layer4
    fi

    # ---- Layer 5 ----
    if (( songStructure > 15 )); then
        local shouldPlay=$(( macroStructure == 11 || (macroStructure > 12 && sixteenthCycle) ? 1 : 0 ))
        local gateSignal=$(( shouldPlay ? ((7 ^ songStructure) % 3 + 1) % 2 : 1 ))
        local isValidPhase=$(( macroStructure % 4 != 2 + (songStructure < 24 || songStructure > 96) ? 1 : 0 ))
        local baseNote=$(( 9 + 4 * alternatingFlag ))
        local noteAdjustment=$(( oddEvenFlag ? -3 + lfoSlow % 4 + slowPhase : (lfoSlow % 4 == 3) ? 1 : 0 ))
        local finalNote=$(( baseNote - noteAdjustment + lfoSlower % 2 ))
        local _t1 _t2 _t3 _t4 _t5
        local _cog=$(( channelOffset || structureGate ))
        pfloat::fixed::mul::fast "2.5" "$FINE_MODULATION" _t1
        pfloat::fixed::mul::fast "$FINE_MODULATION" "$_cog" _t2
        pfloat::fixed::mul::fast "2" "$_t2" _t2
        pfloat::fixed::sub::fast "$_t1" "$_t2" _t1
        pfloat::fixed::add::fast "1" "$_t1" _t1
        local fMult=$_t1
        pfloat::fixed::mul::fast "$alternatingFlag" "$channelMod" _t2
        pfloat::fixed::mul::fast "32" "$_t2" _t2
        local additionalMod=$_t2
        local periodVariation=$(( ((t % (CONSTANT16 * HALF_INTERVAL) % (7 * HALF_INTERVAL)) >> STRUCTURE_THRESHOLD) % 4 ))
        local envelopePeriod=$(( HALF_INTERVAL / 2 * (1 + periodVariation) ))
        local _bm; pfloat::fixed::mul::fast "0.5" "$(( macroStructure == 14 ? 1 : 0 ))" _bm
        pfloat::fixed::add::fast "$_bm" "1.4" _bm
        local _e5m; pfloat::fixed::mul::fast "0.2" "$alternatingFlag" _e5m
        pfloat::fixed::sub::fast "$_bm" "$_e5m" _e5m
        local notSixteenthCycle=$(( ! sixteenthCycle ))
        pfloat::fixed::add::fast "$fMult" "$additionalMod" _t3
        local oscArg1=$_t3
        pfloat::fixed::mul::fast "0.3" "$(( lfoSlower % 5 ))" _t4
        local oscArg2=$_t4
        local oscArg3=$(( 1 + (macroStructure % 14 > 10 ? 1 : 0) ))
        local _bo1=$(bitwiseOsc "$finalNote" "$oscArg1" "1" "$oscArg3" 1 "$oscArg2")
        local _e5v=$(envelope "$envelopePeriod" 0 "$_e5m" "$MICRO_MODULATION")
        pfloat::fixed::mul::fast "$FINE_MODULATION" "$notSixteenthCycle" _t5
        pfloat::fixed::sub::fast "0.16" "$_t5" _t5
        pfloat::fixed::mul::fast "$_bo1" "$_e5v" _t4
        pfloat::fixed::mul::fast "$_t5" "$_t4" _t4
        pfloat::fixed::mul::fast "$isValidPhase" "$_t4" _t4
        local mainOsc=$_t4
        local _bo2 _e5v2 _fm2
        pfloat::fixed::mul::fast "$channelMod" "$alternatingFlag" _fm2
        pfloat::fixed::mul::fast "$CONSTANT16" "$_fm2" _fm2
        pfloat::fixed::add::fast "$MICRO_MODULATION" "$_fm2" _fm2
        pfloat::fixed::add::fast "1" "$_fm2" _fm2
        _bo2=$(bitwiseOsc "$CONSTANT16" "$_fm2" "$CONST1_5" "$((1 + oddEvenFlag))")
        _e5v2=$(envelope "$HALF_INTERVAL" 0 2 "$MICRO_MODULATION")
        pfloat::fixed::mul::fast "$_bo2" "$_e5v2" _t5
        pfloat::fixed::mul::fast "0.14" "$_t5" _t5
        pfloat::fixed::mul::fast "$alternatingFlag" "$_t5" _t5
        local altOsc=$_t5
        local _lo1=$(layeredOsc 2 "$CONST1_5")
        pfloat::fixed::mul::fast "$CONST1_5" "$_lo1" _t3
        local layeredOsc1=$_t3
        local _lo2=$(layeredOsc "$((6 - (songStructure >> 1) % 4))" 3)
        pfloat::fixed::mul::fast "$(( pitchScale != 0 ? 1 : 0 ))" "$_lo2" _t4
        pfloat::fixed::mul::fast "$CONST1_5" "$_t4" _t4
        local layeredOsc2=$_t4
        pfloat::fixed::add::fast "$mainOsc" "$altOsc" _t1
        pfloat::fixed::add::fast "$layeredOsc1" "$layeredOsc2" _t2
        pfloat::fixed::add::fast "$_t1" "$_t2" _t1
        pfloat::fixed::mul::fast "$gateSignal" "$_t1" layer5
    fi

    # ---- Layer 6 ----
    if (( songStructure % CONSTANT16 < 14 )); then
        local noteBase=$(( 9 + (slowPhase > 5 ? 1 : 0) ))
        local songStructureGT7=$(( songStructure > 7 ? 1 : 0 ))
        local _fm _em _bo _e6
        pfloat::fixed::mul::fast "$channelMod" "$songStructureGT7" _fm
        pfloat::fixed::add::fast "$FINE_MODULATION" "$_fm" _fm
        pfloat::fixed::add::fast "1" "$_fm" _fm
        local envPeriod=$(( HALF_INTERVAL / rhythmDivisor ))
        pfloat::fixed::add::fast "1.27" "$(( slowPhase == 7 ? 1 : 0 ))" _em
        _bo=$(bitwiseOsc "$noteBase" "$_fm" "$CONST1_5" 1 1 1)
        _e6=$(envelope "$envPeriod" 0 "$_em" "$MICRO_MODULATION")
        pfloat::fixed::mul::fast "$_bo" "$_e6" _fm
        pfloat::fixed::mul::fast "9" "$FINE_MODULATION" _em
        pfloat::fixed::mul::fast "$_em" "$_fm" layer6
    fi

    # ---- Layer 7 ----
    if (( songStructure > 2 )); then
        local noteValue=$(( 2 - lfoSlower % 2 ))
        local songStructureGT6=$(( songStructure > 6 ? 1 : 0 ))
        local _fm _bo
        pfloat::fixed::add::fast "$FINE_MODULATION" "$songStructureGT6" _fm
        pfloat::fixed::add::fast "1" "$_fm" _fm
        local timingGate=$(( (lfoSlow + 18) % CONSTANT16 < 3 ? 1 : 0 ))
        _bo=$(bitwiseOsc "$noteValue" "$_fm" "$CONST1_5" 0)
        pfloat::fixed::mul::fast "$_bo" "$timingGate" _fm
        pfloat::fixed::mul::fast "$FINE_MODULATION" "$_fm" _fm
        pfloat::fixed::mul::fast "$STRUCTURE_THRESHOLD" "$_fm" layer7
    fi

    # ---- Layer 8 ----
    if (( songStructure > 96 )); then
        local notePart1=$(( lfoSlower % 8 ))
        local notePart2=$(( (CONSTANT16 * macroStructure) % 8 ))
        local notePart3=$(( ((1 << (slowPhase % 2)) * ((2 + (slowPhase > 5 ? 1 : 0)) * t >> 11) ) % 6 ))
        local noteIndex=$(( notePart1 + notePart2 + notePart3 ))
        local _fm _red _em8 _bo8 _e8
        pfloat::fixed::mul::fast "$FINE_MODULATION" "$channelOffset" _fm
        pfloat::fixed::add::fast "1" "$_fm" _fm
        local shiftPattern=$(( (macroStructure ^ lfoSlow) % 2 ))
        local envPeriod=$(( HALF_INTERVAL / 2 << shiftPattern ))
        pfloat::fixed::div::fast "$((3 - songStructure % 3))" "4" _red
        pfloat::fixed::sub::fast "1.4" "$_red" _em8
        _bo8=$(bitwiseOsc "$noteIndex" "$_fm" 1 1 0.4)
        _e8=$(envelope "$envPeriod" 0 "$_em8" "$FINE_MODULATION")
        pfloat::fixed::mul::fast "$_bo8" "$_e8" _fm
        pfloat::fixed::mul::fast "$(( macroStructure % 4 != 2 ? 1 : 0 ))" "$_fm" _fm
        pfloat::fixed::mul::fast "$sixteenthCycle" "$_fm" _fm
        pfloat::fixed::mul::fast "$BASE_MODULATION" "$_fm" _fm
        pfloat::fixed::mul::fast "1.3" "$_fm" layer8
    fi

    # Combine & clamp
    local _s1 _s2 _s3 _s4 _sc
    pfloat::fixed::add::fast "$layer1" "$layer2" _s1
    pfloat::fixed::add::fast "$layer3" "$layer4" _s2
    pfloat::fixed::add::fast "$layer5" "$layer6" _s3
    pfloat::fixed::add::fast "$layer7" "$layer8" _s4
    pfloat::fixed::add::fast "$_s1" "$_s2" _s1
    pfloat::fixed::add::fast "$_s3" "$_s4" _s2
    pfloat::fixed::add::fast "$_s1" "$_s2" _s1
    pfloat::fixed::mul::fast "1.2" "$_s1" _sc
    pfloat::fixed::min::fast "$_sc" "255" _sc
    pfloat::fixed::trunc::fast "$_sc" _sc
    echo "$_sc"
}

fi

# ---------------------------------------------------------------
# Signal handling – finalize WAV on Ctrl+C
# ---------------------------------------------------------------
cleanup() {
    local totalBytes=$(wc -c < "$DATA")
    local totalFrames=$(( totalBytes / CHANNELS ))
    wav::header "$RATE" "$CHANNELS" "$BIT_DEPTH" "$totalFrames" > "$HDR"
    cat "$HDR" "$DATA" > "$OUTPUT"
    rm -f "$DATA" "$HDR"
    printf "\nFinished – %s written (%d seconds rendered)\n" "$OUTPUT" "$((totalFrames / RATE))"
    exit 0
}
trap cleanup INT TERM

# ---------------------------------------------------------------
# Rendering loop
# ---------------------------------------------------------------
CHANNEL_MOD="${_MICRO_MOD:-$MICRO_MODULATION}"
while true; do
    left=$(generateChannel 0 0)
    right=$(generateChannel 1 "$CHANNEL_MOD")
    wav::write::sample "$ENCODING" "$left" >> "$DATA"
    wav::write::sample "$ENCODING" "$right" >> "$DATA"
    ((t++))
    ((frame++))
    now_ns=$(date +%s%N)
    elapsed_ns=$(( now_ns - start_ns ))
    if (( elapsed_ns - last_elapsed_ns >= 1000000 )); then
        elapsed=$(bc -l <<< "scale=6; $elapsed_ns/1000000000")
        audio_time=$(bc -l <<< "scale=6; $t / $RATE")
        printf "\rRendered %s seconds (wall %s) samples %d" "$audio_time" "$elapsed" "$t"
        last_elapsed_ns=$elapsed_ns
    fi
done
