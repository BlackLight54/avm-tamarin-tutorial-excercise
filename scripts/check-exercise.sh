#!/usr/bin/env bash
# check-exercise.sh — run the exercise with a dishonest coordinator and show
# your column next to the expected one.
#
#   scripts/check-exercise.sh                 checks exercise/mychannel.spthy
#   scripts/check-exercise.sh --solution      checks exercise/solution/mychannel.spthy
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

THEORY="exercise/exercise.spthy"
if [[ "${1:-}" == "--solution" ]]; then
  # Build a temporary copy of the exercise that includes the solution instead.
  mkdir -p results/solution
  cp exercise/solution/mychannel.spthy results/solution/mychannel.spthy
  sed 's|#include "../model/process.spthy"|#include "../../model/process.spthy"|' exercise/exercise.spthy > results/solution/exercise.spthy
  THEORY="results/solution/exercise.spthy"
fi

mkdir -p results
LOG="results/exercise.log"
scripts/tamarin --prove -D=ADV_A "$THEORY" > "$LOG" 2>&1
status=$?

if grep -q "error" "$LOG" && ! grep -q "summary of summaries" "$LOG"; then
  echo "Tamarin did not accept the theory:"
  echo
  sed -n '1,40p' "$LOG"
  exit 1
fi

LEMMAS=(delivery_works no_bifurcation non_repudiation faithful_history authorized_progression instance_isolation value_secrecy)
LABELS=("sanity delivery_works" "G1  no_bifurcation" "G2  non_repudiation" "G3  faithful_history" "G4  authorized_progression" "G7  instance_isolation" "G6a value_secrecy")
EXPECTED=(V F V F V F F)

echo
printf "%-30s %-8s %-8s\n" "lemma" "yours" "expected"
printf "%-30s %-8s %-8s\n" "------------------------------" "--------" "--------"
all_ok=1
for i in "${!LEMMAS[@]}"; do
  lem="${LEMMAS[$i]}"
  if grep -qE "^  ${lem} \((all-traces|exists-trace)\): verified" "$LOG"; then val="V"
  elif grep -qE "^  ${lem} \((all-traces|exists-trace)\): falsified" "$LOG"; then val="F"
  else val="?"; fi
  mark=""
  [[ "$val" == "${EXPECTED[$i]}" ]] || { mark="  <-- differs"; all_ok=0; }
  printf "%-30s %-8s %-8s%s\n" "${LABELS[$i]}" "$val" "${EXPECTED[$i]}" "$mark"
done
echo
if [[ $all_ok -eq 1 ]]; then
  echo "Your channel behaves like the loose-coupling platform. Compare it with exercise/solution/mychannel.spthy."
else
  echo "Not there yet. If delivery_works is F, nothing gets through your channel and the rest is vacuous."
  echo "Full log: $LOG"
fi
