#!/usr/bin/env python3
"""Quick-test LeafEngines endpoints. Reads config from env vars or defaults."""

import json, os, sys, uuid
from urllib.request import Request, urlopen
from urllib.error import HTTPError

# Config: prefer env vars, fall back to free-tier defaults
BASE = os.environ.get("LEAFENGINES_BASE_URL",
                      "https://wzgnxkoeqzvyn.supabase.co/functions/v1")
KEY  = os.environ.get("LEAFENGINES_API_KEY",
                      "leaf-test-370df0a2e62e")
FIPS = "13247"  # Rockdale County GA

def call_ep(name, body):
    """POST to an endpoint and return (status, parsed_json_or_error_string)."""
    url = f"{BASE}/{name}"
    data = json.dumps(body).encode()
    req = Request(url, data=data, method="POST")
    req.add_header("Content-Type", "application/json")
    req.add_header("x-api-key", KEY)
    try:
        with urlopen(req, timeout=30) as resp:
            return resp.status, json.loads(resp.read())
    except HTTPError as exc:
        body_text = exc.read().decode()[:200]
        return exc.code, body_text

# Endpoint definitions: name -> request body
ENDPOINTS = {
    "county-lookup": {
        "term": "Rockdale County GA",
    },
    "get-soil-data": {
        "county_fips": FIPS,
        "county_name": "Rockdale County",
        "state_code": "GA",
    },
    "territorial-water-quality": {
        "fips_code": FIPS,
        "state_code": "GA",
        "admin_unit_name": "Rockdale County",
    },
    "agricultural-intelligence": {
        "query": "What crops grow best here?",
        "context": {
            "county_fips": FIPS,
            "county_name": "Rockdale County",
            "state_code": "GA",
        },
    },
    "carbon-credit-calculator": {
        "county_fips": FIPS,
        "county_name": "Rockdale County",
        "state_code": "GA",
    },
    "multi-parameter-planting-calendar": {
        "county_fips": FIPS,
        "crop_type": "corn",
    },
}

results = {}
for name, body in ENDPOINTS.items():
    status, data = call_ep(name, body)
    ok = "PASS" if status == 200 else "FAIL"
    results[name] = {"status": status, "ok": ok}
    print(f"  {ok}  {name:40s}  {status}")

passed = sum(1 for r in results.values() if r["ok"] == "PASS")
print(f"\n{passed}/{len(results)} endpoints passed")
