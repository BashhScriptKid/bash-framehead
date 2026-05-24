# ext/neural/demo — Demos

## XOR Classifier (`xor.sh`)

A 2→4→1 feedforward network trained on the XOR truth table.

**Architecture:**
```
input (2) → linear (2→4) → relu → linear (4→1) → sigmoid → output
```

**Training loop** (manual, step-by-step):
1. Forward pass: compute layer outputs
2. Loss: mean squared error against target
3. Backward pass: chain gradients through sigmoid → linear → relu → linear
4. Update: SGD with learning rate 0.5

**Results after 90 epochs:**
```
0 ⊕ 0 = 0.11   (target: 0)
0 ⊕ 1 = 0.95   (target: 1)
1 ⊕ 0 = 0.95   (target: 1)
1 ⊕ 1 = 0.04   (target: 0)
```

## N-gram Text Generation (`ngram_gen.sh`)

Trains a trigram (order=3) Markov model on conversation data, then generates
text via backoff sampling.

**How it works:**

### Training
1. **Tokenize**: split each line into words, lowercase, assign integer IDs.
   Build vocabulary mapping.
2. **Build n-grams**: slide a window of `order` tokens across the corpus.
   For each window, the first N-1 tokens form the *context*, the Nth token
   is the *next* prediction. Store unique next tokens per context.
3. **Output model**: vocab table + context→candidates mapping.

### Generation (backoff sampling)
1. Start with an empty prompt (or seed words).
2. For each generation step, try to match the longest context first:
   - Try order=N: does `context_N` appear in the model? → sample from candidates
   - If not, try order=N-1, N-2, ..., down to 1
   - If no match at any order, stop
3. Append the chosen token, slide the window, repeat.

**Corpus:** `ext/neural/data/conv.txt` — conversation transcripts.

## Attention Smoke Test (`attention_smoke.sh` — planned)

Verifies `neural::attention::scaled_dot_product` produces correct shapes
and row-normalized outputs on a small 4-token synthetic sequence.
