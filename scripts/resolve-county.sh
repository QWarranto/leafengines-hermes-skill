#!/usr/bin/env bash
# resolve-county.sh — Resolve a place name/address/FIPS to county info
# Usage: ./resolve-county.sh "Rockdale County GA"
# Output: JSON with fips_code, county_name, state_code, state_name

set -euo pipefail

TERM="${1:?Usage: resolve-county.sh <place-name-or-fips>}"
BASE_URL="${LEAFENGINES_BASE_URL:-https://wzgnxkoeqzvyn.supabase.co/functions/v1}"
API_KEY="${LEAFENGINES_API_KEY:-leaf-test-370df0a2e62e}"

# Step 1: Try county-lookup
RESULT=$(curl -s -X POST "$BASE_URL/county-lookup" \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"term\": \"$TERM\"}")

COUNT=$(echo "$RESULT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d.get('counties',[])))" 2>/dev/null || echo "0")

if [ "$COUNT" -gt 0 ]; then
  echo "$RESULT" | python3 -c "
import json, sys
d = json.load(sys.stdin)
c = d['counties'][0]
print(json.dumps({
  'fips_code': c.get('fips_code', c.get('FIPS', '')),
  'county_name': c.get('county_name', c.get('name', '')),
  'state_code': c.get('state_code', c.get('state_abbreviation', '')),
  'state_name': c.get('state_name', c.get('state', ''))
}, indent=2))
"
  exit 0
fi

# Step 2: Fallback to Census Geocoder (for full addresses)
echo "county-lookup returned no results, trying Census Geocoder..." >&2
ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$TERM'))")
CENSUS=$(curl -s "https://geocoding.geo.census.gov/geocoder/geographies/onelineaddress?address=${ENCODED}&benchmark=2020&vintage=2020&format=json")

MATCHES=$(echo "$CENSUS" | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d.get('result',{}).get('addressMatches',[])))" 2>/dev/null || echo "0")

if [ "$MATCHES" -gt 0 ]; then
  echo "$CENSUS" | python3 -c "
import json, sys
d = json.load(sys.stdin)
m = d['result']['addressMatches'][0]
county = m['geographies']['Counties'][0]
geoid = county['GEOID']
state_fips = geoid[:2]

STATE_MAP = {
  '01':'AL','02':'AK','04':'AZ','05':'AR','06':'CA','08':'CO','09':'CT',
  '10':'DE','11':'DC','12':'FL','13':'GA','15':'HI','16':'ID','17':'IL',
  '18':'IN','19':'IA','20':'KS','21':'KY','22':'LA','23':'ME','24':'MD',
  '25':'MA','26':'MI','27':'MN','28':'MS','29':'MO','30':'MT','31':'NE',
  '32':'NV','33':'NH','34':'NJ','35':'NM','36':'NY','37':'NC','38':'ND',
  '39':'OH','40':'OK','41':'OR','42':'PA','44':'RI','45':'SC','46':'SD',
  '47':'TN','48':'TX','49':'UT','50':'VT','51':'VA','53':'WA','54':'WV',
  '55':'WI','56':'WY','60':'AS','66':'GU','69':'MP','72':'PR','78':'VI'
}

print(json.dumps({
  'fips_code': geoid,
  'county_name': county.get('NAME', ''),
  'state_code': STATE_MAP.get(state_fips, state_fips),
  'state_name': county.get('STATENAME', '')
}, indent=2))
"
  exit 0
fi

echo '{"error": "Could not resolve location"}' >&2
exit 1
