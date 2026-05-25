#!/usr/bin/env bash
# demo/xor.sh — XOR classifier training
# 2→4→1 network, 4 samples, <100 epochs to converge
#
# Usage: source bash-framehead.sh && source ext/neural/neural.sh
#        bash ext/neural/demo/xor.sh

set -e
cd "$(dirname "${BASH_SOURCE[0]}")/../../.."

source ./bash-framehead.sh
source ./ext/neural/neural.sh

echo "=== XOR Classifier — 2→4→1 ==="
echo "Training on XOR truth table..."
echo ""

# XOR data: [0,0]→0, [0,1]→1, [1,0]→1, [1,1]→0
declare -a X_DATA=(
		"shape 2 1: 0 0"
		"shape 2 1: 0 1"
		"shape 2 1: 1 0"
		"shape 2 1: 1 1"
)
declare -a Y_DATA=(
		"shape 1 1: 0"
		"shape 1 1: 1"
		"shape 1 1: 1"
		"shape 1 1: 0"
)

# Initialize weights (small random-ish values)
W1=$(math::tensor::new "4 2" "0.5 -0.3 0.8 0.1 -0.2 0.7 -0.9 0.4")
b1=$(math::tensor::new "1 4" "0 0 0 0")
W2=$(math::tensor::new "1 4" "0.3 -0.5 0.2 -0.1")
b2=$(math::tensor::new "1 1" "0")

lr="0.5"
epochs=100

for ((epoch = 0; epoch < epochs; epoch++)); do
		total_loss=0
		for ((s = 0; s < 4; s++)); do
				x="${X_DATA[$s]}"
				y_true="${Y_DATA[$s]}"

				# Forward
				h=$(neural::linear::forward "$W1" "$b1" "$x")
				h=$(neural::relu "$h")
				y_pred=$(neural::linear::forward "$W2" "$b2" "$h")
				y_pred_sig=$(neural::sigmoid "$y_pred")

				# Loss
				loss=$(neural::mse::forward "$y_pred_sig" "$y_true")
				total_loss=$(echo "$total_loss + $loss" | bc -l)

				# Backward (manual)
				# dL/dy_pred = MSE backward
				dL=$(neural::mse::backward "$y_pred_sig" "$y_true")
				# dL/dy_pred through sigmoid
				dL=$(neural::sigmoid::backward "$y_pred_sig" "$dL")
				# Layer 2 backward
				{ IFS= read -r dW2; IFS= read -r db2; IFS= read -r dx; } < <(neural::linear::backward "$W2" "$b2" "$h" "$dL")
				# dL/dh through relu
				dh=$(neural::relu::backward "$h" "$dx")
				# Layer 1 backward
				{ IFS= read -r dW1; IFS= read -r db1; IFS= read -r _; } < <(neural::linear::backward "$W1" "$b1" "$x" "$dh")

				# SGD step
				W1=$(neural::sgd::step W1 dW1 "$lr")
				b1=$(neural::sgd::step b1 db1 "$lr")
				W2=$(neural::sgd::step W2 dW2 "$lr")
				b2=$(neural::sgd::step b2 db2 "$lr")
		done

		avg_loss=$(echo "scale=6; $total_loss / 4" | bc -l)
		if (( epoch % 10 == 0 )); then
				printf "  epoch %3d  loss=%s\n" "$epoch" "$avg_loss"
		fi
		if (( $(echo "$avg_loss < 0.001" | bc -l) )); then
				printf "  epoch %3d  loss=%s  ← converged\n" "$epoch" "$avg_loss"
				break
		fi
done

echo ""
echo "=== Predictions ==="
for ((s = 0; s < 4; s++)); do
		x="${X_DATA[$s]}"
		y_true="${Y_DATA[$s]}"
		h=$(neural::linear::forward "$W1" "$b1" "$x")
		h=$(neural::relu "$h")
		y_pred=$(neural::linear::forward "$W2" "$b2" "$h")
		y_pred_sig=$(neural::sigmoid "$y_pred")
		pred_val=$(math::tensor::get "$y_pred_sig" "0,0")
		true_val=$(math::tensor::get "$y_true" "0,0")
		printf "  %s ⊕ %s = %.4f  (target: %d)\n" \
				"$(math::tensor::get "$x" "0,0")" "$(math::tensor::get "$x" "1,0")" \
				"$pred_val" "$true_val"
done
