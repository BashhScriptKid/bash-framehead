# `random`

Pseudo-random number generators — from trivial built-in LCGs to cryptographic-grade algorithms, all in pure Bash. **25 functions.** Stateful PRNGs return both the result and the new state as a space-separated string.

---

## Seed Generation

Use `/dev/urandom` to obtain initial seeds for PRNG state.

| Function | Description |
|----------|-------------|
| `random::seed32` | Seed from `/dev/urandom` — returns a 32-bit unsigned integer |
| `random::seed64` | Seed from `/dev/urandom` — returns a 64-bit value (may be negative in bash) |

```bash
seed1=$(random::seed32)
seed2=$(random::seed64)
```

## Built-in Fallback

| Function | Description |
|----------|-------------|
| `random::native` | Bash's built-in `$RANDOM` — 15-bit LCG, period: 2¹⁵, **quality: poor** |
| `random::native::range` | `$RANDOM`-based value in [min, max] inclusive |

> **Use only for quick throwaway needs.** `$RANDOM` reseeds from PID+time in subshells.

---

## PRNG Algorithms

All generators return `"result new_state..."` for next-step chaining. Quality ratings: **poor** < **moderate** < **good** < **excellent**.

| Algorithm | Quality | Period | Use Case |
|-----------|---------|--------|----------|
| `random::middle_square` | Very poor | Variable, short | Historical demo only |
| `random::lcg` | Poor–moderate | 2³² | Simple simulations |
| `random::lcg::glibc` | Poor–moderate | 2³² | Glibc `rand()` compat |
| `random::xorshift32` | Moderate | 2³²−1 | Fast non-secure |
| `random::xorshift64` | Moderate | 2⁶⁴−1 | Fast non-secure |
| `random::mulberry32` | Good | 2³² | Simple fast 32-bit |
| `random::xorshiftr128plus` | Good | 2¹²⁸−1 | Used in V8/SpiderMonkey `Math.random()` |
| `random::splitmix64` | Good | 2⁶⁴ | Seeding other PRNGs |
| `random::wyrand` | Excellent | 2⁶⁴ | Hashing, fast generation |
| `random::pcg32` | Excellent | 2⁶⁴ | General purpose, simulation |
| `random::pcg32::fast` | Excellent | 2⁶⁴ | PCG32 with hardcoded increment |
| `random::xoshiro256ss` | Excellent | 2²⁵⁶−1 | General purpose, floating point |
| `random::xoshiro256p` | Excellent | 2²⁵⁶−1 | Faster output, slightly weaker low bits |
| `random::well512` | Excellent | 2⁵¹²−1 | Simulation, games |
| `random::isaac` | Cryptographic-adjacent | 2⁸²⁹⁵ | Security-adjacent tasks (simplified, educational) |

```bash
# PCG32 — excellent quality, simple state
state=$(random::seed64)
read result state < <(random::pcg32 "$state" 1)
echo "$result"

# Xoshiro256** — highest quality
seed=$(random::seed64)
read s0 s1 s2 s3 < <(random::splitmix64::seed_xoshiro "$seed")
read result s0 s1 s2 s3 < <(random::xoshiro256ss "$s0" "$s1" "$s2" "$s3")

# Xorshift128+ — fast, good quality
s0=$(random::seed64); s1=$(random::seed64)
read result s0 s1 < <(random::xorshiftr128plus "$s0" "$s1")
```

## Multi-Word State Initialisation

| Function | Description |
|----------|-------------|
| `random::splitmix64::seed_xoshiro` | Expand a single 64-bit seed into four words for xoshiro256 |
| `random::well512::init` | Initialise WELL512 state (1 index + 16 words) from a single seed |
| `random::isaac::init` | Initialise simplified ISAAC state from a single seed |

## Algorithm Notes

- **middle_square**: von Neumann, 1946. Historical curiosity — degenerates to zero for many seeds. Education only.
- **lcg**: Numerical Recipes parameters. Classic `X_{n+1} = (a*X_n + c) mod m`.
- **xorshift32/64**: Marsaglia, 2003. Simple bitwise shifts and xors. Fast, no multiplication.
- **xorshiftr128plus**: Vigna, 2014. Used in V8, SpiderMonkey, WebKit. Good quality.
- **xoshiro256ss/256p**: Blackman & Vigna, 2018. Successor to xorshift128+. Excellent quality.
- **pcg32**: O'Neill, 2014. LCG + permutation output function. Passes all known statistical tests.
- **splitmix64**: Steele/Lea/Flood, 2014 (Java 8). Excellent for seeding other PRNGs.
- **wyrand**: Wang Yi, 2019. Passes BigCrush. The output function of the wyhash family.
- **well512**: Panneton/L'Ecuyer/Matsumoto, 2006. Better equidistribution than Mersenne Twister.
- **isaac**: Jenkins, 1996. Simplified educational implementation. The real ISAAC uses 256-word state.

## Dependencies

- **Requires**: `runtime`
- **External tools**: `/dev/urandom` (for seeding); all PRNG logic is pure Bash
