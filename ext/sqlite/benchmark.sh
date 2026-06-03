#!/usr/bin/env bash
# benchmark — measures query vs query::fast performance on ext/sqlite.
# Generates 1000 rows, runs 100 iterations of a COUNT(*) and a SELECT.
# Requires: ext/sqlite (source main.sh + ext/sqlite/sqlite.sh first)

set -eo pipefail

source ./main.sh
source ext/sqlite/sqlite.sh

_db=$(mktemp -t bench-XXXX.db)
trap 'rm -f "$_db"' EXIT

echo "=== Populating 1000 rows ==="
sqlite::exec "$_db" "CREATE TABLE t(id INTEGER PRIMARY KEY, name TEXT, val INTEGER);"
# Generate inserts via Python and pipe to sqlite::exec via -cmd
_sql=$(python3 -c '
print("BEGIN;")
for i in range(1000):
    print(f"INSERT INTO t VALUES({i}, '\''name_{i}'\'', {i*7 % 100});")
print("COMMIT;")
')
sqlite3 "$_db" "$_sql"
_c=$(sqlite::one "$_db" "SELECT count(*) FROM t;")
echo "row count: $_c"

ITERS=100
echo ""
echo "=== Benchmark: COUNT(*) over $ITERS iterations ==="
echo -n "sqlite::query:    "
start=$EPOCHREALTIME
for ((i=0; i<ITERS; i++)); do
	sqlite::query "$_db" "SELECT count(*) FROM t;" >/dev/null
done
end=$EPOCHREALTIME
slow_ms=$(python3 -c "print(f'{($end - $start) * 1000:.1f}')")
echo "${slow_ms} ms total, $(python3 -c "print(f'{($end - $start) * 1000 / $ITERS:.2f}')") ms/op"

echo -n "sqlite::query::fast: "
start=$EPOCHREALTIME
for ((i=0; i<ITERS; i++)); do
	unset -v rows
	sqlite::query::fast "$_db" "SELECT count(*) FROM t;" rows
done
end=$EPOCHREALTIME
fast_ms=$(python3 -c "print(f'{($end - $start) * 1000:.1f}')")
echo "${fast_ms} ms total, $(python3 -c "print(f'{($end - $start) * 1000 / $ITERS:.2f}')") ms/op"

echo ""
echo "=== Benchmark: SELECT id, name, val over $ITERS iterations ==="
echo -n "sqlite::query:    "
start=$EPOCHREALTIME
for ((i=0; i<ITERS; i++)); do
	sqlite::query "$_db" "SELECT id, name, val FROM t WHERE val > 50;" >/dev/null
done
end=$EPOCHREALTIME
slow_ms=$(python3 -c "print(f'{($end - $start) * 1000:.1f}')")
echo "${slow_ms} ms total, $(python3 -c "print(f'{($end - $start) * 1000 / $ITERS:.2f}')") ms/op"

echo -n "sqlite::query::fast: "
start=$EPOCHREALTIME
for ((i=0; i<ITERS; i++)); do
	unset -v rows
	sqlite::query::fast "$_db" "SELECT id, name, val FROM t WHERE val > 50;" rows
done
end=$EPOCHREALTIME
fast_ms=$(python3 -c "print(f'{($end - $start) * 1000:.1f}')")
echo "${fast_ms} ms total, $(python3 -c "print(f'{($end - $start) * 1000 / $ITERS:.2f}')") ms/op"

echo ""
echo "=== Benchmark: fts::search on 100 indexed docs ($ITERS iters) ==="
if sqlite::has fts5; then
	sqlite::fts::create "$_db" docs title
	for i in {1..100}; do
		sqlite::fts::index "$_db" docs title "document number $i about the quick brown fox"
	done
	echo -n "sqlite::fts::search 'fox':  "
	start=$EPOCHREALTIME
	for ((i=0; i<ITERS; i++)); do
		sqlite::fts::search "$_db" docs title "fox" >/dev/null
	done
	end=$EPOCHREALTIME
	fts_ms=$(python3 -c "print(f'{($end - $start) * 1000:.1f}')")
	echo "${fts_ms} ms total, $(python3 -c "print(f'{($end - $start) * 1000 / $ITERS:.2f}')") ms/op"
else
	echo "FTS5 not available, skipping"
fi
