---
name: agricultural-intelligence
title: LeafEngines Agricultural Intelligence
description: |
 Agricultural intelligence API — USDA soil analysis, EPA water quality,
 AI crop recommendations, plant identification, carbon credits, and
 environmental impact scoring for any US county. Free tier available
 (no credit card). Patent-protected algorithms. 9 tools across 4
 pricing tiers.
trigger: |
 When the user asks about soil data, water quality, crop recommendations,
 plant identification, carbon credits, VRT prescriptions, environmental
 impact, planting optimization, or county/FIPS lookups for US locations.
 Also when the user mentions LeafEngines, SoilSidekick Pro, or
 agricultural intelligence.
required_environment_variables:
 - LEAFENGINES_API_KEY
---

# LeafEngines Agricultural Intelligence

USDA soil data, EPA water quality, AI crop recommendations, and environmental
intelligence for any US county. Free tier available — no credit card required.

## Authentication

### Option 1: API Key (recommended for agents)

```bash
export LEAFENGINES_API_KEY=ak_your_api_key_here
```

Pass as `x-api-key` header or `Authorization: Bearer ak_...` on every call.

### Option 2: Free Tier (no key needed)

```
x-free-tier: true
```

Free tier includes: basic soil analysis, county lookup, 20 data calls/day,
5 AI calls/day, 3 plant identifications/day.

### Option 3: Test Key (works immediately)

```
x-api-key: leaf-test-370df0a2e62e
```

## Base URL

```
https://wzgnxkoeqzvyn.supabase.co/functions/v1
```

## County Resolution (always start here)

Most endpoints require a 5-digit FIPS code. Users rarely know FIPS codes —
they say "Rockdale County GA" or "Conyers, Georgia". Always resolve first.

### Step 1: Try county-lookup

```bash
curl -s -X POST "$BASE_URL/county-lookup" \
  -H "x-api-key: $LEAFENGINES_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"term": "Rockdale County GA"}'
```

Returns: `{ "counties": [{ "fips_code": "13247", "county_name": "Rockdale County", "state_code": "GA", "state_name": "Georgia" }] }`

### Step 2: Census Geocoder fallback (for street addresses)

If county-lookup can't resolve a full address:

```bash
curl -s "https://geocoding.geo.census.gov/geocoder/geographies/onelineaddress?address=2330+Lochinver+Lane+SW+Conyers+GA+30094&benchmark=2020&vintage=2020&format=json"
```

Extract FIPS from `result.addressMatches[0].geographies.Counties[0].GEOID`.
Use a 2-digit state FIPS → 2-letter state code lookup for `state_code`.

### Step 3: Direct FIPS input

If the user provides a 5-digit number (e.g. "37119"), pass it directly as
`county_fips` — it's already a FIPS code. Call county-lookup with the FIPS
to get the county_name and state_code for downstream calls.

## Tools (9 endpoints)

### Commoditized Tier ($0.001/call)

#### 1. get_soil_data

USDA SSURGO soil analysis: pH, NPK, organic matter, drainage, texture,
recommendations.

```bash
curl -s -X POST "$BASE_URL/get-soil-data" \
  -H "x-api-key: $LEAFENGINES_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"county_fips": "13247", "county_name": "Rockdale County", "state_code": "GA"}'
```

**Required:** `county_fips` (5-digit string)
**Optional:** `county_name`, `state_code` (recommended for richer responses)

**Key response fields to surface:**
- pH level, organic matter %
- Nitrogen / Phosphorus / Potassium levels
- Drainage class, soil texture
- Recommendations array

#### 2. county_lookup

Resolve location names to FIPS codes. Search by county name, state, or
FIPS code.

```bash
curl -s -X POST "$BASE_URL/county-lookup" \
  -H "x-api-key: $LEAFENGINES_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"term": "Travis County Texas"}'
```

**Required:** `term` (2-100 chars)

#### 3. territorial_water_quality

EPA water quality data: contaminants, violation status, utility name,
water grade.

```bash
curl -s -X POST "$BASE_URL/territorial-water-quality" \
  -H "x-api-key: $LEAFENGINES_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"fips_code": "13247", "state_code": "GA", "admin_unit_name": "Rockdale County"}'
```

**Required:** `fips_code`, `state_code`, `admin_unit_name`
**NOTE:** This endpoint uses `fips_code` (not `county_fips`) and
`admin_unit_name` (not `county_name`). Field names differ from other
endpoints.

**Key response fields to surface:**
- Grade (A-F)
- Contaminants table: name, level, MCL, violation flag
- Utility name

### Enhanced Tier ($0.003/call)

#### 4. agricultural_intelligence

AI-powered agricultural Q&A: crop recommendations, yield predictions,
planting schedules, sustainability scores.

```bash
curl -s -X POST "$BASE_URL/agricultural-intelligence" \
  -H "x-api-key: $LEAFENGINES_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query": "What crops grow best here?", "context": {"county_fips": "13247", "county_name": "Rockdale County", "state_code": "GA"}}'
```

**Required:** `query`
**Optional:** `context` object with `county_fips`, `county_name`, `state_code`

#### 5. safe_identification

Plant identification with toxic lookalike warnings, confidence scores,
and habitat info.

```bash
curl -s -X POST "$BASE_URL/safe-identification" \
  -H "x-api-key: $LEAFENGINES_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"image": "https://example.com/photo.jpg", "location": "Georgia", "use_case": "foraging"}'
```

**Required:** `image` (URL), `location`, `use_case`
**Optional:** `additional_context`

### Proprietary Tier ($0.01/call)

#### 6. carbon_credit_calculator

Carbon credit potential with estimated credits, monetary value, and
verification steps.

```bash
curl -s -X POST "$BASE_URL/carbon-credit-calculator" \
  -H "x-api-key: $LEAFENGINES_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"county_fips": "13247", "county_name": "Rockdale County", "state_code": "GA"}'
```

**Required:** `county_fips`, `county_name`, `state_code`

#### 7. generate_vrt_prescription

Variable Rate Technology prescription maps for precision agriculture.

```bash
curl -s -X POST "$BASE_URL/generate-vrt-prescription" \
  -H "x-api-key: $LEAFENGINES_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"county_fips": "13247", "county_name": "Rockdale County", "state_code": "GA"}'
```

**Required:** `county_fips`, `county_name`, `state_code`

### Exclusive Tier ($0.02/call)

#### 8. environmental_impact_analysis

Patent-pending Environmental Compatibility Score: runoff risk,
contamination risk, biodiversity impact, carbon footprint, satellite
vegetation health. AlphaEarth 64-dim satellite embeddings + USDA/EPA/NOAA
data fusion.

```bash
curl -s -X POST "$BASE_URL/environmental-impact-engine" \
  -H "x-api-key: $LEAFENGINES_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"analysis_id": "uuid-here", "county_fips": "13247", "county_name": "Rockdale County", "state_code": "GA", "soil_data": {"drainage_class": "moderate", "slope_percentage": 5, "organic_matter_percentage": 2.5}}'
```

**Required:** `analysis_id` (UUID), `county_fips`, `soil_data` object
**Optional:** `proposed_treatments` array, `water_body_data` object

#### 9. planting_optimization

Multi-parameter phenology model: optimal planting windows, yield
predictions, sustainability scores. Proprietary algorithms.

```bash
curl -s -X POST "$BASE_URL/multi-parameter-planting-calendar" \
  -H "x-api-key: $LEAFENGINES_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"county_fips": "13247", "crop_type": "corn"}'
```

**Required:** `county_fips`, `crop_type`

## Response Formatting for Chat

When presenting results to users in a conversational context:

### Soil Data
```
Soil Analysis — {county_name}, {state_code}
pH: {value} | Organic Matter: {value}%
Nitrogen: {level} | Phosphorus: {level} | Potassium: {level}
Drainage: {class} | Texture: {texture}
Recommendations: {bulleted list}
```

### Water Quality
```
Water Quality — {county_name} | Grade: {grade}
Utility: {utility_name}
Contaminants:
  - {name}: {level} (MCL: {mcl}) {VIOLATION / OK}
```

### Agricultural Intelligence
Header: "Agricultural Intelligence — {county_name}, {state_code}"
Then render the structured response fields (crops, planting schedule,
recommendations, risk factors) from the API response.

### Plant Identification
```
Plant: {common_name} ({scientific_name})
Confidence: {score}%
Safety: {safe/caution/dangerous}
Lookalikes: {list with toxicity warnings}
Habitat: {description}
```

## Rate Limits by Tier

| Tier | req/min | req/hour | req/day |
|------|---------|----------|---------|
| Free | 10 | 100 | 1,000 |
| Starter | 30 | 500 | 5,000 |
| Pro | 100 | 2,000 | 25,000 |
| Enterprise | 500 | 10,000 | 100,000 |

## Response Time SLAs

| Category | Target | Max | Endpoints |
|----------|--------|-----|-----------|
| Fast | 200ms | 500ms | county-lookup |
| Standard | 500ms | 1.5s | get-soil-data, territorial-water-quality |
| Complex | 2s | 5s | agricultural-intelligence, safe-identification |
| Heavy | 5s | 15s | environmental-impact-engine, generate-vrt-prescription |

## Integration Channels

| Channel | Install | Best For |
|---------|---------|----------|
| MCP Server | `npm install -g @ancientwhispers54/leafengines-mcp-server` | Claude Desktop, Cursor, any MCP client |
| n8n Nodes | `npm install n8n-nodes-leafengines` | Business automation |
| Node-RED | `npm install node-red-contrib-leafengines` | IoT/edge automation |
| QGIS Plugin | QGIS Plugin Manager (ID 4987) | GIS professionals |
| Direct API | HTTP POST to Supabase edge functions | Custom integrations |

## Pricing

- **Free tier:** No credit card. Test key: `leaf-test-370df0a2e62e`
- **Commoditized:** $0.001/call (soil, county, water)
- **Enhanced:** $0.003/call (AI, plant ID)
- **Proprietary:** $0.01/call (carbon, VRT)
- **Exclusive:** $0.02/call (environmental score, planting optimization)
- **Subscriptions:** Starter $49/mo, Pro $149/mo, Enterprise $1,999/mo

## Pitfalls

- **Field names differ across endpoints:** `territorial-water-quality` uses
  `fips_code` and `admin_unit_name`, not `county_fips` and `county_name`.
  Always check the endpoint's specific field names before calling.
- **FIPS codes are 5-digit strings:** Pad with leading zeros if needed
  (e.g., "01301" not "1301").
- **county-lookup before downstream calls:** Most endpoints need FIPS,
  county_name, and state_code. Resolve all three from county-lookup before
  calling soil/water/ag endpoints.
- **Free tier has daily limits:** 20 data calls, 5 AI calls, 3 IDs per day.
  Check `X-RateLimit-Remaining` headers.
- **Photo uploads:** Use a signed URL, never inline base64. 2MB edge
  function payload limit.
- **ai.gateway.lovable.dev** endpoints are being replaced — use the
  Supabase base URL above for all calls.

## Links

- **API Docs:** https://app.soilsidekickpro.com/api-docs
- **MCP Docs:** https://app.soilsidekickpro.com/mcp
- **OpenAPI Spec:** https://github.com/QWarranto/soil-sidekick-pro-guide/blob/main/sdks/openapi-spec.yaml
- **npm MCP Server:** https://www.npmjs.com/package/@ancientwhispers54/leafengines-mcp-server
- **GitHub:** https://github.com/QWarranto/leafengines-agricultural-intelligence
- **Support:** support@soilsidekickpro.com
- **Partnerships:** partnerships@leafengines.com

## License

Integration code: Apache 2.0 / MIT. API service: Commercial with free
tier. Core algorithms: Patent-protected (U.S. #19/320,727, #19/544,827).
