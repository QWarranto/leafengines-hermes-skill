#!/usr/bin/env bash
# resolve-county.sh — Resolve a place name/address/FIPS to county info
# Usage: ./resolve-county.sh "Rockdale County GA"

set -euo pipefail

TERM="${1:?Usage: resolve-county.sh <place-name-or-fips>}"
BASE_URL="${LEAFENGINES_BASE_URL:-https://wzgnxkoeqzvyn.supabase.co/functions/v1}"
API_KEY="${LEAFENGINES_API_KEY:-leaf-test-370df0a2e62e}"

# Step 1: county-lookup API
RESULT=$(curl -s -X POST "$BASE_URL/county-lookup" \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"term\": \"$TERM\"}")

# Parse with jq (preferred) or python3 fallback
if command -v jq &>/dev/null; then
  COUNT=$(echo "$RESULT" | jq '.counties | length')
  if [ "$COUNT" -gt 0 ]; then
    echo "$RESULT" | jq '.counties[0] | {fips_code: (.fips_code // .FIPS), county_name: (.county_name // .name), state_code: (.state_code // .state_abbreviation), state_name: (.state_name // .state)}'
    exit 0
  fi
else
  # Fallback: write to temp file and parse with python3 script
  TMPFILE=$(mktemp)
  echo "$RESULT" > "$TMPFILE"
  python3 "$(dirname "$0")/parse-county-result.py" "$TMPFILE"
  EXIT=$?
  rm -f "$TMPFILE"
  exit $EXIT
fi

# Step 2: Census Geocoder fallback for street addresses
echo "county-lookup returned no results, trying Census Geocoder..." >&2
ENCODED_TERM=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$TERM")
CENSUS=$(curl -s "https://geocoding.geo.census.gov/geocoder/geographies/onelineaddress?address=${ENCODED_TERM}&benchmark=2020&vintage=2020&format=json")

if command -v jq &>/dev/null; then
  MATCHES=$(echo "$CENSUS" | jq '.result.addressMatches | length')
  if [ "$MATCHES" -gt 0 ]; then
    echo "$CENSUS" | jq '.result.addressMatches[0].geographies.Counties[0] | {fips_code: .GEOID, county_name: .NAME, state_code: .STATE}'
    exit 0
  fi
fi

echo '{"error": "Could not resolve location"}' >&2
exit 1
