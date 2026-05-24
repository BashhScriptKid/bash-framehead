# ext/neural — Machine Learning

Pure-Bash machine learning: tensor operations, neural network building blocks,
and two training lifecycles — feedforward dense networks and count-based n-gram
models. Tensor ops live in `math::tensor::*` (generalizing `math::matrix::*`).

Uses a persistent `bc -l` coprocess via `runtime::coproc::*` for fast matmul,
softmax, sigmoid, and tanh.

## Dependencies

- **bash-framehead core**: `math::tensor::*`, `math::matrix::*`, `pfloat::ieee754::*`, `runtime::coproc::*`, `binary::*`
- **External**: `bc`

## Usage

### Mode

```bash
source ./bash-framehead.sh
source ./ext/neural/neural.sh

neural::mode bc       # persistent bc coproc (fastest for matmul/softmax)
neural::mode fixed    # pfloat fixed-point (fastest pure Bash, element-wise)
neural::mode float    # pfloat IEEE 754 (exact, slower)
```

### Tensor basics

```bash
t=$(math::tensor::new "2 3" "1 2 3 4 5 6")
math::tensor::shape "$t"      # "2 3"
math::tensor::get "$t" "0,2"  # "3"

a=$(math::tensor::new "2 3" "1 2 3 4 5 6")
b=$(math::tensor::new "3 2" "1 2 3 4 5 6")
c=$(math::tensor::matmul "$a" "$b")  # shape "2 2"
```

### Forward pass

```bash
# 2→4→1 XOR network
W1=$(math::tensor::new "4 2" "0.5 -0.3 0.8 0.1 -0.2 0.7 -0.9 0.4")
b1=$(math::tensor::new "1 4" "0 0 0 0")
W2=$(math::tensor::new "1 4" "0.3 -0.5 0.2 -0.1")
b2=$(math::tensor::new "1 1" "0")
x=$(math::tensor::new "2 1" "0 0")  # input: [0, 0] → XOR → 0

h=$(neural::linear::forward "$W1" "$b1" "$x")
h=$(neural::relu "$h")
y=$(neural::linear::forward "$W2" "$b2" "$h")
y=$(neural::sigmoid "$y")
echo "$y"
```

### Training

```bash
# Train a tiny XOR classifier (4 samples, ~100 epochs)
neural::dense::train ./demo/xor.nn ./demo/xor_data.txt ./demo/xor_labels.txt 100 0.1
```

### N-gram

```bash
# Train on a corpus
neural::ngram::train 3 < corpus.txt > model.txt

# Generate from the model
echo "" | neural::ngram::generate < model.txt
```

## API Reference

### Mode

#### `neural::mode <fixed|float|bc>`
Set the execution mode. In `bc` mode, a persistent `bc -l` coprocess is
spawned for fast bulk operations. Other modes kill the coprocess.

### Math::Tensor

Tensor format: `"shape N M K: v1 v2 v3 ..."` — space-separated, row-major.

#### `math::tensor::new <shape> [data]`
Allocate a zero-filled tensor or from space-separated data.

#### `math::tensor::shape <t>` / `rank <t>` / `size <t>`
Query dimensions, rank, and element count.

#### `math::tensor::get <t> <indices>` / `set <t> <indices> <val>`
Read/write a single element. Indices are comma-separated: `"0,1,2"`.

#### `math::tensor::add <a> <b>` / `sub` / `mul` / `scale <t> <f>`
Element-wise arithmetic. Shapes must match.

#### `math::tensor::matmul <a> <b>`
Generalized matrix multiplication: A[M×K] @ B[K×N] → shape M N. Uses bc for
bulk computation.

#### `math::tensor::dot <a> <b>`
Inner product of two 1-D vectors.

#### `math::tensor::transpose <t> <perm>`
Permute axes. `perm="1,0"` swaps 2-D matrix axes.

#### `math::tensor::reshape <t> <new_shape>` / `flatten <t>`
Change shape (same element count) or collapse to 1-D.

#### `math::tensor::reduce::sum <t> [axis]` / `reduce::max`
Reduce along an axis or over all elements.

### Activations

#### `neural::relu <t>` / `neural::relu::backward <forward_out> <upstream_grad>`
ReLU: max(0, x). Gradient: 1 if forward > 0 else 0.

#### `neural::leaky_relu <t> [alpha=0.01]`
Leaky ReLU: x if x > 0 else alpha*x.

#### `neural::sigmoid <t>` / `::backward`
1/(1+e^-x). Gradient: sigmoid(x) * (1 - sigmoid(x)).

#### `neural::tanh <t>`
Hyperbolic tangent: (e^x - e^-x) / (e^x + e^-x).

#### `neural::softmax <t>`
Softmax: e^x_i / sum(e^x). Numerically stable (subtracts max first).

#### `neural::gelu <t>`
GELU approximation via tanh.

### Layers

#### `neural::linear::forward <W> <b> <x>`
Fully-connected layer: matmul(W, x) + b (broadcast).

#### `neural::linear::backward <W> <b> <x> <dy>`
Returns gradients: dW, db, dx.

#### `neural::dropout <t> <rate>`
Random zero-out during training (`_NEURAL_TRAINING=1`), identity at inference.

#### `neural::layer_norm <t>`
Layer normalization: (x - mean) / std.

### Loss + Metrics

#### `neural::mse::forward <pred> <target>` / `::backward`
Mean squared error. Gradient: 2(pred - target)/N.

#### `neural::cross_entropy::forward <pred> <target>` / `::backward`
Cross-entropy: -sum(target * log(pred + eps)).

#### `neural::accuracy <pred> <target>`
Fraction where argmax matches (binary: threshold at 0.5).

### Optimizers

#### `neural::sgd::step <param> <grad> <lr>`
Stochastic gradient descent: param -= lr * grad.

### Data Pipeline

#### `neural::data::tokenize`
Read text from stdin, output vocab + token IDs.

#### `neural::data::one_hot <t> <depth>`
One-hot encode integer tensor indices.

#### `neural::data::normalize <t>`
Z-score normalize: (x - mean) / std.

#### `neural::data::shuffle <t> [seed=42]`
Fisher-Yates shuffle of tensor elements.

### Model Persistence

#### `neural::save_weights <name> <dir> <var>` / `neural::load_weights <name> <dir>`
Save/load tensor strings to/from text files.

### Dense Lifecycle

#### `neural::dense::forward <model_file> <x>`
Forward pass through a model file definition.

#### `neural::dense::predict <model_file> <x>`
Alias for `forward`.

### N-gram Lifecycle

#### `neural::ngram::train <order=4>`
Read text corpus from stdin, train n-gram model, output to stdout.

#### `neural::ngram::generate`
Read model from stdin, generate text from a seed prompt to stdout.

## Limitations

- **Slow for large models**: pure Bash + bc is orders of magnitude slower than
  any compiled language. Practical limit is ~100K parameters.
- **No autograd**: gradients must be computed manually or via `::backward` functions.
- **No GPU, no BLAS**: all computation is CPU, single-threaded.
- **bc required** for sigmoid, tanh, softmax, gelu, and all ::backward variants.
- **Float precision** varies by mode: fixed (~5 decimals), float/bc (~20 decimals).
- **Model format is minimal**: no JSON, no binary — line-based text files only.
