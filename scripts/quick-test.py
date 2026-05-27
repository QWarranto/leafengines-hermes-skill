#!/usr/bin/env python3
"""Quick-test all LeafEngines endpoints with a free-tier key."""

import json, os, sys, uuid
from urllib.request import Request, urlopen
from urllib.error import HTTPError

BASE = os.environ.get("LEAFENGINES_BASE_URL", "https://wzgnxkoeqzvyn.supabase.co/functions/v1")
KEY = os.environ.get("LEAFENGINES_API_KEY", "leaf-test-370df0a2e62e")
FIPS = "13247"  # Rockdale County GA

ENDPOINTS = {
    "county-lookup":             {"term": "Rockdale County GA"},
    "get-soil-data":             {"county_fips": FIPS, "county_name": "Rockdale County", "state_code": "GA"},
    "territorial-water-quality": {"fips_code": FIPS, "state_code": "GA", "admin_unit_name": "Rockdale County"},
    "agricultural-intelligence": {"query": "What crops grow best here?", "context": {"county_fips": FIPS, "county_name": "Rockdale County", "state_code": "GA"}},
    "carbon-credit-calculator":  {"county_fips": FIPS, "county_name": "Rockdale County", "state_code": "GA"},
    "multi-parameter-planting-calendar": {"county_fips": FIPS, "crop_type": "corn"},
}

def call_ep(name, body):
    data = json.dumps(body).encode()
    req = Request(f"{BASE}/{name}", data=data, method="POST")
    req.add_header("Content-Type", "application/json")
    req.add_header("x-api-key", KEY)
    try:
        with urlopen(req, timeout=30) as resp:
            return resp.status, json.loads(resp.read())
    except HTTPError as e:
        return e.code, e.read().decode()[:200]

results = {}
for name, body in ENDPOINTS.items():
    status, data = call_ep(name, body)
    ok = "PASS" if status == 200 else "FAIL"
    results[name] = {"status": status, "ok": ok}
    print(f"  {ok}  {name:40s}  {status}")

passed = sum(1 for r in results.values() if r["ok"] == "PASS")
print(f"\n{passed}/{len(results)} endpoints passed")
