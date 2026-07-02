# LeafEngines Agricultural Intelligence — Hermes Skill

> 🏆 **Global Startup Awards 2026 — North America Regional Nominee**

Agricultural intelligence for Hermes agents — USDA soil analysis, EPA water quality,
AI crop recommendations, plant identification, carbon credits, and environmental impact
scoring for any US county.

## Install

```bash
hermes skills install QWarranto/leafengines-hermes-skill
```

## Quick Start

Set your API key (free tier available — no credit card):

```bash
export LEAFENGINES_API_KEY=leaf-test-370df0a2e62e
```

Then ask your agent: "What's the soil pH in Rockdale County, Georgia?"

## What's Included

- **SKILL.md** — Full tool reference, auth patterns, county resolution flow, response formatting
- **scripts/resolve-county.sh** — CLI tool to resolve place names → FIPS codes
- **scripts/quick-test.py** — Smoke test all endpoints with free-tier key
- **references/endpoint-field-mapping.md** — Cross-endpoint field name reference (prevents 400s)

## Integration Channels

| Channel | Package |
|---------|---------|
| MCP Server | `@ancientwhispers54/leafengines-mcp-server` |
| n8n Nodes | `n8n-nodes-leafengines` |
| Node-RED | `node-red-contrib-leafengines` |
| QGIS Plugin | ID 4987 |
| Direct API | Supabase edge functions |

## License

Skill code: MIT. API service: Commercial with free tier.
