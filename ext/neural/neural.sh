#!/usr/bin/env bash
# ext/neural/neural.sh — machine learning extension
#
# Tensor operations (math::tensor::*), neural network building blocks,
# and two training lifecycles: dense (feedforward) and ngram (count-based).
#
# Dependencies:
#   core: runtime binary math pfloat
#   external: bc

# --- guard ---
declare -f 'runtime::bash_version' &>/dev/null || {
    echo "${BASH_SOURCE[0]}: runtime not found -- source bash-framehead.sh first" >&2
    return 1
}

_guard_core_deps=(math::tensor::new math::matrix::mul pfloat::ieee754::from_string
                  runtime::coproc::start runtime::coproc::send runtime::coproc::read
                  runtime::coproc::stop)
_guard_ext_deps=(bc)

for _guard_dep in "${_guard_core_deps[@]}"; do
    declare -f "$_guard_dep" &>/dev/null || {
        echo "${BASH_SOURCE[0]}: missing core function '$_guard_dep'" >&2
        return 1
    }
done

for _guard_dep in "${_guard_ext_deps[@]}"; do
    command -v "$_guard_dep" &>/dev/null || {
        echo "${BASH_SOURCE[0]}: missing external tool '$_guard_dep'" >&2
        return 1
    }
done

unset _guard_core_deps _guard_ext_deps _guard_dep
# --- end guard ---

# ==============================================================================
# MODE + BC COPROC
# ==============================================================================

_NEURAL_MODE="${_NEURAL_MODE:-fixed}"

# Set execution mode: fixed (pfloat integer), float (IEEE 754), bc (bc -l coproc).
# Usage: neural::mode <fixed|float|bc>
neural::mode() {
    case "$1" in
        fixed|float)
            runtime::coproc::stop _neural_bc 2>/dev/null || true
            _NEURAL_MODE=$1
            ;;
        bc)
            _NEURAL_MODE=bc
            if ! runtime::coproc::alive _neural_bc 2>/dev/null; then
                runtime::coproc::start _neural_bc bc -l
            fi
            ;;
        *)
            echo "neural::mode: unknown mode '$1' (expected fixed|float|bc)" >&2
            return 1
            ;;
    esac
}

# Internal: evaluate an expression through the current mode.
# Modes: bc → coproc; fixed/float → pfloat calls.
_neural::eval() {
    local expr=$1
    case "$_NEURAL_MODE" in
        bc)
            runtime::coproc::send _neural_bc "$expr"
            local r; r=$(runtime::coproc::read _neural_bc)
            echo "${r//[$'\r']/}"
            ;;
        fixed)
            local op a b
            read -r a op b <<< "$expr"
            case "$op" in
                +) pfloat::fixed::add "$a" "$b" ;;
                -) pfloat::fixed::sub "$a" "$b" ;;
                \*) pfloat::fixed::mul "$a" "$b" ;;
                /) pfloat::fixed::div "$a" "$b" ;;
            esac
            ;;
        float)
            echo "$expr" | bc -l 2>/dev/null
            ;;
    esac
}

# ==============================================================================
# ACTIVATIONS
# ==============================================================================

neural::relu() {
    local t=$1
    local data; data=$(_math::tensor_data "$t")
    local -a v; read -ra v <<< "$data"
    local i r=()
    for ((i = 0; i < ${#v[@]}; i++)); do
        (( $(echo "${v[$i]} > 0" | bc -l) )) && r+=("${v[$i]}") || r+=(0)
    done
    echo "shape $(_math::tensor_shape_dims "$t"): ${r[*]}"
}

neural::relu::backward() {
    local forward_out=$1 upstream_grad=$2
    local data; data=$(_math::tensor_data "$forward_out")
    local gd; gd=$(_math::tensor_data "$upstream_grad")
    local -a v g r; read -ra v <<< "$data"; read -ra g <<< "$gd"
    local i
    for ((i = 0; i < ${#v[@]}; i++)); do
        (( $(echo "${v[$i]} > 0" | bc -l) )) && r+=("${g[$i]}") || r+=(0)
    done
    echo "shape $(_math::tensor_shape_dims "$forward_out"): ${r[*]}"
}

neural::sigmoid() {
    local t=$1
    local d; d=$(_math::tensor_data "$t")
    local -a v r; read -ra v <<< "$d"
    local i
    for ((i = 0; i < ${#v[@]}; i++)); do
        r+=($(echo "1 / (1 + e(-(${v[$i]})))" | bc -l))
    done
    echo "shape $(_math::tensor_shape_dims "$t"): ${r[*]}"
}

neural::sigmoid::backward() {
    local forward_out=$1 upstream_grad=$2
    local data gd; data=$(_math::tensor_data "$forward_out"); gd=$(_math::tensor_data "$upstream_grad")
    local -a v g r; read -ra v <<< "$data"; read -ra g <<< "$gd"
    local i
    for ((i = 0; i < ${#v[@]}; i++)); do
        local sx=${v[$i]}
        r+=($(echo "${g[$i]} * $sx * (1 - $sx)" | bc -l))
    done
    echo "shape $(_math::tensor_shape_dims "$forward_out"): ${r[*]}"
}

neural::softmax() {
    local t=$1
    local d; d=$(_math::tensor_data "$t")
    local -a v; read -ra v <<< "$d"
    local bc_s; bc_s=$(mktemp "/tmp/fsbshf-nn-sm.XXXXXX")
    echo "scale=10" > "$bc_s"
    local i max_val=${v[0]}
    for ((i = 0; i < ${#v[@]}; i++)); do
        (( $(echo "${v[$i]} > $max_val" | bc -l) )) && max_val=${v[$i]}
    done
    # exp(x - max) for stability, then sum
    printf "0" >> "$bc_s"
    for ((i = 0; i < ${#v[@]}; i++)); do
        printf " + e(${v[$i]} - $max_val)" >> "$bc_s"
    done
    printf "\n" >> "$bc_s"
    local sum; sum=$(bc -l "$bc_s" 2>/dev/null)
    local -a r
    for ((i = 0; i < ${#v[@]}; i++)); do
        local ev; ev=$(echo "e(${v[$i]} - $max_val) / ($sum)" | bc -l)
        r+=("$ev")
    done
    rm -f "$bc_s"
    echo "shape $(_math::tensor_shape_dims "$t"): ${r[*]}"
}

neural::tanh() {
    local t=$1
    local d; d=$(_math::tensor_data "$t")
    local -a v r; read -ra v <<< "$d"
    local i
    for ((i = 0; i < ${#v[@]}; i++)); do
        r+=($(echo "(e(${v[$i]}) - e(-${v[$i]})) / (e(${v[$i]}) + e(-${v[$i]}))" | bc -l))
    done
    echo "shape $(_math::tensor_shape_dims "$t"): ${r[*]}"
}

neural::gelu() {
    local t=$1
    local d; d=$(_math::tensor_data "$t")
    local -a v r; read -ra v <<< "$d"
    local i
    for ((i = 0; i < ${#v[@]}; i++)); do
        local x=${v[$i]}
        r+=($(echo "$x * 0.5 * (1 + (e(0.7978845608 * ($x + 0.044715 * $x * $x * $x)) - e(-0.7978845608 * ($x + 0.044715 * $x * $x * $x))) / (e(0.7978845608 * ($x + 0.044715 * $x * $x * $x)) + e(-0.7978845608 * ($x + 0.044715 * $x * $x * $x))))" | bc -l))
    done
    echo "shape $(_math::tensor_shape_dims "$t"): ${r[*]}"
}

neural::leaky_relu() {
    local t=$1 alpha=${2:-0.01}
    local d; d=$(_math::tensor_data "$t")
    local -a v r; read -ra v <<< "$d"
    local i
    for ((i = 0; i < ${#v[@]}; i++)); do
        (( $(echo "${v[$i]} > 0" | bc -l) )) && r+=("${v[$i]}") || r+=($(echo "${v[$i]} * $alpha" | bc -l))
    done
    echo "shape $(_math::tensor_shape_dims "$t"): ${r[*]}"
}

# ==============================================================================
# LAYERS
# ==============================================================================

neural::linear::forward() {
    local W=$1 b=$2 x=$3
    local wx; wx=$(math::tensor::matmul "$W" "$x")
    # Broadcast bias: add b to each column of wx
    math::tensor::add "$wx" "$b"
}

neural::linear::backward() {
    local W=$1 b=$2 x=$3 dy=$4
    # dW = dy @ x^T
    local dW; dW=$(math::tensor::matmul "$dy" "$(math::tensor::transpose "$x" "1,0")")
    # db = dy (sum over batch dim, simplified: just dy for batch=1)
    local db=$dy
    # dx = W^T @ dy
    local dx; dx=$(math::tensor::matmul "$(math::tensor::transpose "$W" "1,0")" "$dy")
    printf '%s\n' "$dW" "$db" "$dx"
}

neural::dropout() {
    local t=$1 rate=$2
    if [[ "$_NEURAL_TRAINING" != "1" ]]; then
        echo "$t"
        return
    fi
    local d; d=$(_math::tensor_data "$t")
    local -a v r; read -ra v <<< "$d"
    local i
    for ((i = 0; i < ${#v[@]}; i++)); do
        if (( RANDOM % 100 > rate * 100 )); then
            r+=($(echo "${v[$i]} / (1 - $rate)" | bc -l))
        else
            r+=(0)
        fi
    done
    echo "shape $(_math::tensor_shape_dims "$t"): ${r[*]}"
}

neural::layer_norm() {
    local t=$1
    local d; d=$(_math::tensor_data "$t")
    local -a v; read -ra v <<< "$d"
    local n=${#v[@]} i sum=0
    for ((i = 0; i < n; i++)); do
        sum=$(echo "$sum + ${v[$i]}" | bc -l)
    done
    local mean; mean=$(echo "($sum) / $n" | bc -l)
    local vars=0
    for ((i = 0; i < n; i++)); do
        vars=$(echo "$vars + (${v[$i]} - $mean)^2" | bc -l)
    done
    local std; std=$(echo "sqrt($vars / $n)" | bc -l)
    local -a r
    for ((i = 0; i < n; i++)); do
        r+=($(echo "(${v[$i]} - $mean) / ($std + 0.000001)" | bc -l))
    done
    echo "shape $(_math::tensor_shape_dims "$t"): ${r[*]}"
}

# ==============================================================================
# LOSS + METRICS
# ==============================================================================

neural::mse::forward() {
    local pred=$1 target=$2
    local dp dt; dp=$(_math::tensor_data "$pred"); dt=$(_math::tensor_data "$target")
    local -a p t; read -ra p <<< "$dp"; read -ra t <<< "$dt"
    local n=${#p[@]} i sum=0
    for ((i = 0; i < n; i++)); do
        sum=$(echo "$sum + (${p[$i]} - ${t[$i]})^2" | bc -l)
    done
    echo "scale=10; ($sum) / $n" | bc -l
}

neural::mse::backward() {
    local pred=$1 target=$2
    local dp dt; dp=$(_math::tensor_data "$pred"); dt=$(_math::tensor_data "$target")
    local -a p t r; read -ra p <<< "$dp"; read -ra t <<< "$dt"
    local n=${#p[@]} i
    for ((i = 0; i < n; i++)); do
        r+=($(echo "2 * (${p[$i]} - ${t[$i]}) / $n" | bc -l))
    done
    echo "shape $(_math::tensor_shape_dims "$pred"): ${r[*]}"
}

neural::cross_entropy::forward() {
    local pred=$1 target=$2
    local dp dt; dp=$(_math::tensor_data "$pred"); dt=$(_math::tensor_data "$target")
    local -a p t; read -ra p <<< "$dp"; read -ra t <<< "$dt"
    local n=${#p[@]} i sum=0 eps=0.0000001
    for ((i = 0; i < n; i++)); do
        sum=$(echo "$sum - ${t[$i]} * l(${p[$i]} + $eps)" | bc -l)
    done
    echo "$sum"
}

neural::cross_entropy::backward() {
    local pred=$1 target=$2
    local dp dt; dp=$(_math::tensor_data "$pred"); dt=$(_math::tensor_data "$target")
    local -a p t r; read -ra p <<< "$dp"; read -ra t <<< "$dt"
    local n=${#p[@]} i
    for ((i = 0; i < n; i++)); do
        r+=($(echo "(${p[$i]} - ${t[$i]}) / $n" | bc -l))
    done
    echo "shape $(_math::tensor_shape_dims "$pred"): ${r[*]}"
}

neural::accuracy() {
    local pred=$1 target=$2
    local dp dt; dp=$(_math::tensor_data "$pred"); dt=$(_math::tensor_data "$target")
    local -a p t; read -ra p <<< "$dp"; read -ra t <<< "$dt"
    local correct=0 i max_idx=0 max_val=${p[0]}
    for ((i = 0; i < ${#p[@]}; i++)); do
        (( $(echo "${p[$i]} > $max_val" | bc -l) )) && { max_val=${p[$i]}; max_idx=$i; }
    done
    (( $(echo "${t[$max_idx]} > 0.5" | bc -l) )) && correct=1
    echo "$correct"
}

# ==============================================================================
# OPTIMIZERS
# ==============================================================================

neural::sgd::step() {
    local -n _nsgd_param=$1 _nsgd_grad=$2
    local lr=$3
    math::tensor::sub "${_nsgd_param}" "$(math::tensor::scale "${_nsgd_grad}" "$lr")"
}

# ==============================================================================
# DATA PIPELINE
# ==============================================================================

neural::data::tokenize() {
    local -A WORD_TO_ID
    local -a ID_TO_WORD ALL_IDS
    local id=0 line word
    while IFS= read -r line; do
        read -ra words <<< "$line"
        for word in "${words[@]}"; do
            word="${word,,}"
            if [[ -z "${WORD_TO_ID[$word]+x}" ]]; then
                WORD_TO_ID["$word"]=$id
                ID_TO_WORD+=("$word")
                (( id++ ))
            fi
            ALL_IDS+=("${WORD_TO_ID[$word]}")
        done
    done
    echo "# vocab"
    local i
    for ((i = 0; i < ${#ID_TO_WORD[@]}; i++)); do echo "${ID_TO_WORD[$i]}"; done
    echo "# tokens"
    echo "${ALL_IDS[*]}"
}

neural::data::one_hot() {
    local t=$1 depth=$2
    local data; data=$(_math::tensor_data "$t")
    local -a v; read -ra v <<< "$d"
    local n=${#v[@]} i j
    local -a r
    for ((i = 0; i < n; i++)); do
        for ((j = 0; j < depth; j++)); do
            (( j == v[i] )) && r+=(1) || r+=(0)
        done
    done
    echo "shape $depth $n: ${r[*]}"
}

neural::data::normalize() {
    local t=$1
    local d; d=$(_math::tensor_data "$t")
    local -a v; read -ra v <<< "$d"
    local n=${#v[@]} i sum=0
    for ((i = 0; i < n; i++)); do sum=$(echo "$sum + ${v[$i]}" | bc -l); done
    local mean; mean=$(echo "($sum) / $n" | bc -l)
    local vars=0
    for ((i = 0; i < n; i++)); do vars=$(echo "$vars + (${v[$i]} - $mean)^2" | bc -l); done
    local std; std=$(echo "sqrt($vars / $n)" | bc -l)
    local -a r
    for ((i = 0; i < n; i++)); do
        r+=($(echo "(${v[$i]} - $mean) / ($std + 0.000001)" | bc -l))
    done
    echo "shape $(_math::tensor_shape_dims "$t"): ${r[*]}"
}

neural::data::shuffle() {
    local t=$1 seed=${2:-42}
    local data; data=$(_math::tensor_data "$t")
    local -a v idx; read -ra v <<< "$data"
    local n=${#v[@]} i j tmp
    for ((i = 0; i < n; i++)); do idx+=($i); done
    # Fisher-Yates shuffle
    for ((i = n - 1; i > 0; i--)); do
        j=$((seed % (i + 1)))
        tmp=${idx[$i]}; idx[$i]=${idx[$j]}; idx[$j]=$tmp
    done
    local -a r
    for ((i = 0; i < n; i++)); do r+=("${v[${idx[$i]}]}"); done
    echo "shape $(_math::tensor_shape_dims "$t"): ${r[*]}"
}

# ==============================================================================
# MODEL PERSISTENCE
# ==============================================================================

neural::save_weights() {
    local model_name=$1 dir=$2
    mkdir -p "$dir"
    # Caller manages which params to save; we provide the primitives
    local -n _nsw_param=$3
    echo "${_nsw_param}" > "$dir/${model_name}.txt"
}

neural::load_weights() {
    local model_name=$1 dir=$2
    cat "$dir/${model_name}.txt" 2>/dev/null
}

# ==============================================================================
# DENSE LIFECYCLE
# ==============================================================================

# Simple model file: each line is "dense <out_dim> <activation>" or "input <dim>"
# Weights loaded from named files via load_weights

neural::dense::forward() {
    local model_file=$1 x=$2
    local line input_dim prev layers=()
    local -a layer_sizes layer_acts

    while IFS= read -r line; do
        [[ "$line" == \#* || -z "$line" ]] && continue
        case "$line" in
            input\ *) input_dim="${line#input }" ;;
            dense\ *)
                read -r _ out_dim act <<< "$line"
                layer_sizes+=("$out_dim")
                layer_acts+=("${act:-linear}")
                ;;
        esac
    done < "$model_file"

    # For now, return input as-is — weights must be loaded by caller
    echo "$x"
}

neural::dense::predict() {
    neural::dense::forward "$@"
}

# ==============================================================================
# NGRAM LIFECYCLE
# ==============================================================================

neural::ngram::train() {
    local order=${1:-4}
    local -A WORD_TO_ID NGRAM_COUNTS NGRAM_CONTEXTS CONTEXT_SEEN
    local -a ID_TO_WORD ALL_TOKENS
    local word_id=0 line

    # Tokenize
    while IFS= read -r line; do
        read -ra words <<< "$line"
        local word
        for word in "${words[@]}"; do
            word="${word,,}"
            if [[ -z "${WORD_TO_ID[$word]+x}" ]]; then
                WORD_TO_ID["$word"]=$word_id
                ID_TO_WORD+=("$word")
                (( word_id++ ))
            fi
            ALL_TOKENS+=("${WORD_TO_ID[$word]}")
        done
    done

    local VOCAB_SIZE=${#ID_TO_WORD[@]} TOKEN_COUNT=${#ALL_TOKENS[@]}

    # Build n-grams
    local o ctx_width i j
    for ((o = 1; o <= order; o++)); do
        ctx_width=$((o - 1))
        for ((i = 0; i <= TOKEN_COUNT - o; i++)); do
            local context="" next_token key ctx_key
            for ((j = 0; j < ctx_width; j++)); do
                context+="${ALL_TOKENS[$((i + j))]} "
            done
            context="${context% }"
            next_token="${ALL_TOKENS[$((i + ctx_width))]}"
            key="${o}:${context}|${next_token}"
            ctx_key="${o}:${context}"

            NGRAM_COUNTS["$key"]=$(( ${NGRAM_COUNTS["$key"]:-0} + 1 ))
            local seen_key="${ctx_key}|${next_token}"
            if [[ -z "${CONTEXT_SEEN[$seen_key]+x}" ]]; then
                CONTEXT_SEEN["$seen_key"]=1
                if [[ -z "${NGRAM_CONTEXTS[$ctx_key]+x}" ]]; then
                    NGRAM_CONTEXTS["$ctx_key"]="$next_token"
                else
                    NGRAM_CONTEXTS["$ctx_key"]+=" $next_token"
                fi
            fi
        done
    done

    # Output model
    echo "N=$order"
    echo "VOCAB_SIZE=$VOCAB_SIZE"
    local k
    for k in "${!ID_TO_WORD[@]}"; do echo "VOCAB $k ${ID_TO_WORD[$k]}"; done
    echo "---CONTEXTS---"
    for k in "${!NGRAM_CONTEXTS[@]}"; do
        echo "$k=${NGRAM_CONTEXTS[$k]}"
    done
}

neural::ngram::generate() {
    local MAX_N=3 prompt="" length=20
    local -A WORD_TO_ID NGRAM_CONTEXTS
    local -a ID_TO_WORD

    while IFS= read -r line; do
        case "$line" in
            N=*) MAX_N="${line#N=}" ;;
            VOCAB\ *) read -r _ id word <<< "$line"; WORD_TO_ID["$word"]=$id; ID_TO_WORD[$id]="$word" ;;
            ---CONTEXTS---) break ;;
        esac
    done

    while IFS= read -r line; do
        local key="${line%%=*}" vals="${line#*=}"
        NGRAM_CONTEXTS["$key"]="$vals"
    done

    # Generate from prompt
    local prompt_words=($prompt) step order word
    for ((step = 0; step < length; step++)); do
        local next_id=""
        for ((order = MAX_N; order >= 1; order--)); do
            if (( ${#prompt_words[@]} >= order - 1 )); then
                local ctx=""
                local start=$(( ${#prompt_words[@]} - order + 1 ))
                (( start < 0 )) && start=0
                local w
                for ((w = start; w < ${#prompt_words[@]}; w++)); do
                    word="${prompt_words[$w]}"
                    ctx+="${WORD_TO_ID[$word]:-0} "
                done
                ctx="${ctx% }"
                local candidates="${NGRAM_CONTEXTS[${order}:${ctx}]:-}"
                if [[ -n "$candidates" ]]; then
                    local -a ca; read -ra ca <<< "$candidates"
                    next_id="${ca[$((RANDOM % ${#ca[@]}))]}"
                    break
                fi
            fi
        done
        [[ -z "$next_id" ]] && break
        local next_word="${ID_TO_WORD[$next_id]}"
        echo -n "$next_word "
        prompt_words+=("$next_word")
    done
    echo
}
