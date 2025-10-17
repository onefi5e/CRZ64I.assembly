#!/usr/bin/env bash
# Simple validator for benchmark JSON outputs
# Usage: ./validate.sh results.json

FILE="$1"
if [ -z "$FILE" ]; then
  echo "Usage: $0 results.json"
  exit 2
fi

jq -e '.[] | select(.cycles_per_op < 0 or .latency_ns < 0 or .speed_ops_per_sec < 0 or .duration_ns < 0)' "$FILE" >/dev/null
if [ $? -eq 0 ]; then
  echo "Validation failed: found negative values"
  exit 1
fi

echo "Basic validation passed for $FILE"
