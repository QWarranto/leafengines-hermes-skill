#!/usr/bin/env python3
"""Parse county-lookup JSON result and extract county info."""

import json, sys

with open(sys.argv[1]) as f:
    data = json.load(f)

counties = data.get("counties", [])
if not counties:
    sys.exit(1)

c = counties[0]
print(json.dumps({
    "fips_code": c.get("fips_code") or c.get("FIPS", ""),
    "county_name": c.get("county_name") or c.get("name", ""),
    "state_code": c.get("state_code") or c.get("state_abbreviation", ""),
    "state_name": c.get("state_name") or c.get("state", "")
}, indent=2))
