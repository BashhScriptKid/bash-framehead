#!/usr/bin/env bash
# demo/ngram_gen.sh — n-gram text generation
# Trains on a subset of the conversation corpus from ext/neural/data/conv.txt
#
# Usage: bash ext/neural/demo/ngram_gen.sh

cd "$(dirname "${BASH_SOURCE[0]}")/../.."

source ./bash-framehead.sh
source ./ext/neural/neural.sh

CORPUS="ext/neural/data/conv.txt"
LINES=50

echo "=== N-Gram Text Generation ==="
echo "Training on $LINES lines of $CORPUS..."
echo ""

head -"$LINES" "$CORPUS" | neural::ngram::train 3 > /tmp/fsbshf-ngram-model.txt
echo "Model: $(wc -l < /tmp/fsbshf-ngram-model.txt) lines"
echo ""
echo "Generating samples..."
echo ""

for ((i = 1; i <= 3; i++)); do
		printf "  [%d] " "$i"
		< /tmp/fsbshf-ngram-model.txt neural::ngram::generate 2>/dev/null || true
		echo ""
done

rm -f /tmp/fsbshf-ngram-model.txt
echo ""
echo "Done."
