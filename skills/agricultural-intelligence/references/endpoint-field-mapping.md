# Endpoint Field Name Mapping

Each LeafEngines endpoint has its own request body schema. Field names are
NOT consistent across endpoints — this table prevents 400 errors.

| Endpoint | FIPS field | County name field | State field | Other required fields |
|----------|-----------|-------------------|-------------|----------------------|
| county-lookup | — | — | — | `term` |
| get-soil-data | `county_fips` | `county_name` | `state_code` | — |
| territorial-water-quality | `fips_code` | `admin_unit_name` | `state_code` | — |
| agricultural-intelligence | `county_fips` (in `context`) | `county_name` (in `context`) | `state_code` (in `context`) | `query` |
| safe-identification | — | — | — | `image`, `location`, `use_case` |
| environmental-impact-engine | `county_fips` | `county_name` | `state_code` | `analysis_id` (UUID), `soil_data` |
| carbon-credit-calculator | `county_fips` | `county_name` | `state_code` | — |
| generate-vrt-prescription | `county_fips` | `county_name` | `state_code` | — |
| multi-parameter-planting-calendar | `county_fips` | — | — | `crop_type` |
| live-agricultural-data | `county_fips` | `county_name` | `state_code` | `data_types` (array) |

## Common Mistakes

1. Sending `county_fips` to territorial-water-quality — it expects `fips_code`
2. Sending `county_name` to territorial-water-quality — it expects `admin_unit_name`
3. Sending `question` to agricultural-intelligence — it expects `query`
4. Forgetting `state_code` on endpoints that require it (400 validation error)
5. Passing only `county_fips` without `county_name` + `state_code` on endpoints
   that need all three (works but returns degraded responses)

## Full OpenAPI Spec

The canonical OpenAPI 3.0.3 spec (1,871 lines) lives at:
https://github.com/QWarranto/soil-sidekick-pro-guide/blob/main/sdks/openapi-spec.yaml
