# PelaPela API

Cloudflare Workers API for serving Japanese learning network and lesson plan data.

## Features

- 🚀 **Fast Global CDN**: Deployed on Cloudflare's edge network
- 📦 **R2 Storage**: Data stored in Cloudflare R2 buckets
- 🔒 **CORS Enabled**: Ready for frontend integration
- 📊 **Multiple Endpoints**: Network, lessons, vocabulary, grammar
- 🎯 **Pagination**: Efficient data retrieval with limit/offset
- 🔍 **Filtering**: Query by difficulty, type, JLPT level, etc.

## API Endpoints

### Root & Health

```
GET /                    # API information
GET /health             # Health check
```

### Network Data

```
GET /api/network/nodes          # Get network nodes
  ?limit=100                    # Number of nodes to return
  &offset=0                     # Pagination offset
  &type=grammar|vocabulary      # Filter by type

GET /api/network/edges          # Get network edges
  ?limit=100                    # Number of edges to return
  &offset=0                     # Pagination offset
  &source=node_id               # Filter by source node

GET /api/network/full           # Get complete network (nodes + edges)
```

### Skill Tree

```
GET /api/skill-tree             # Get complete skill tree
GET /api/skill-tree/node/:id    # Get specific skill node
```

### Lesson Plans

```
GET /api/lessons                # Get all lessons
  ?difficulty=beginner          # Filter by difficulty level
  &type=grammar_focus           # Filter by lesson type
  &limit=50                     # Number of lessons
  &offset=0                     # Pagination offset

GET /api/lessons/:id            # Get specific lesson

GET /api/learning-paths         # Get learning paths & difficulty levels
```

### Vocabulary & Grammar

```
GET /api/vocabulary             # Get vocabulary entries
  ?pos=Noun                     # Filter by part of speech
  &limit=100                    # Number of entries
  &offset=0                     # Pagination offset

GET /api/grammar                # Get grammar patterns
  ?level=JLPT N3                # Filter by JLPT level
  &limit=100                    # Number of patterns
  &offset=0                     # Pagination offset
```

## Setup

### Prerequisites

- Node.js 16+
- Cloudflare account
- Wrangler CLI

### Installation

```bash
npm install
```

### Configuration

1. **Create R2 bucket**:
```bash
wrangler r2 bucket create pelapela-data
```

2. **Upload data files** to R2:
```bash
# Upload network data
wrangler r2 object put pelapela-data/network_output/nodes.json --file ../network_output/nodes.json
wrangler r2 object put pelapela-data/network_output/edges.json --file ../network_output/edges.json

# Upload skill tree
wrangler r2 object put pelapela-data/skill_tree_output/skill_tree.json --file ../skill_tree_output/skill_tree.json

# Upload lesson plan
wrangler r2 object put pelapela-data/lesson_plan_output/lesson_plan.json --file ../lesson_plan_output/lesson_plan.json

# Upload clean data
wrangler r2 object put pelapela-data/data/clean/vocabulary_entry.json --file ../data/clean/vocabulary_entry.json
wrangler r2 object put pelapela-data/data/clean/grammar_pattern.json --file ../data/clean/grammar_pattern.json
```

3. **Update `wrangler.toml`** with your settings:
```toml
name = "pelapela-api"
main = "src/index.js"
compatibility_date = "2024-01-01"

[[r2_buckets]]
binding = "PELAPELA_DATA"
bucket_name = "pelapela-data"

[vars]
API_VERSION = "1.0.0"
CORS_ORIGIN = "*"
```

## Development

### Local Development

```bash
npm run dev
```

This starts a local server at `http://localhost:8787`

### Testing Endpoints

```bash
# Test root
curl http://localhost:8787/

# Test health
curl http://localhost:8787/health

# Test network nodes
curl http://localhost:8787/api/network/nodes?limit=10

# Test lessons
curl http://localhost:8787/api/lessons?difficulty=beginner&limit=5

# Test vocabulary
curl http://localhost:8787/api/vocabulary?pos=Noun&limit=20
```

## Deployment

### Deploy to Cloudflare

```bash
npm run deploy
```

### Production Environment

For production, update the CORS origin in `wrangler.toml`:

```toml
[env.production]
name = "pelapela-api-production"
vars = { CORS_ORIGIN = "https://yourdomain.com" }
```

Deploy to production:

```bash
wrangler deploy --env production
```

## Usage Examples

### JavaScript/TypeScript

```javascript
// Fetch lessons
const response = await fetch('https://pelapela-api.workers.dev/api/lessons?difficulty=beginner&limit=10');
const data = await response.json();

console.log(`Found ${data.data.length} lessons`);
data.data.forEach(lesson => {
  console.log(`- ${lesson.title.en} (${lesson.difficulty_level})`);
});
```

### Swift

```swift
let url = URL(string: "https://pelapela-api.workers.dev/api/lessons?difficulty=beginner")!
let (data, _) = try await URLSession.shared.data(from: url)
let response = try JSONDecoder().decode(LessonResponse.self, from: data)

for lesson in response.data {
    print("\(lesson.title.en) - \(lesson.difficultyLevel)")
}
```

### cURL

```bash
# Get beginner lessons
curl "https://pelapela-api.workers.dev/api/lessons?difficulty=beginner&limit=5"

# Get specific lesson
curl "https://pelapela-api.workers.dev/api/lessons/lesson_s1_u1_order_food_75c34d71"

# Get learning paths
curl "https://pelapela-api.workers.dev/api/learning-paths"

# Get vocabulary by part of speech
curl "https://pelapela-api.workers.dev/api/vocabulary?pos=Verb&limit=20"

# Get JLPT N3 grammar
curl "https://pelapela-api.workers.dev/api/grammar?level=JLPT%20N3&limit=10"
```

## Response Format

All endpoints return JSON with consistent structure:

### Success Response

```json
{
  "data": [...],
  "pagination": {
    "total": 342,
    "limit": 50,
    "offset": 0,
    "hasMore": true
  }
}
```

### Error Response

```json
{
  "error": "Not found",
  "message": "Additional error details"
}
```

## CORS

CORS is enabled by default. Configure allowed origins in `wrangler.toml`:

```toml
[vars]
CORS_ORIGIN = "*"  # Allow all origins (development)

[env.production]
vars = { CORS_ORIGIN = "https://yourdomain.com" }  # Restrict in production
```

## Rate Limiting

Cloudflare Workers have generous free tier limits:
- 100,000 requests/day (free tier)
- 1,000,000 requests/day (paid tier)

Consider adding rate limiting for production:

```javascript
// Example rate limiting (requires KV store)
const rateLimitKey = `ratelimit:${clientIP}`;
const count = await env.CACHE.get(rateLimitKey);

if (count && parseInt(count) > 100) {
  return jsonResponse({ error: 'Rate limit exceeded' }, 429, corsHeaders);
}
```

## Monitoring

### View Logs

```bash
npm run tail
```

### Cloudflare Dashboard

Monitor your Worker at:
https://dash.cloudflare.com/workers

## Data Updates

To update data in R2:

```bash
# Update lesson plan
wrangler r2 object put pelapela-data/lesson_plan_output/lesson_plan.json \
  --file ../lesson_plan_output/lesson_plan.json

# Update skill tree
wrangler r2 object put pelapela-data/skill_tree_output/skill_tree.json \
  --file ../skill_tree_output/skill_tree.json
```

## Cost Estimation

### Cloudflare Workers (Free Tier)
- 100,000 requests/day
- 10ms CPU time per request
- **Cost**: Free

### R2 Storage
- Storage: ~10MB of JSON data
- Requests: Class A (writes) and Class B (reads)
- **Cost**: ~$0.01/month

### Total: ~$0.01/month for moderate usage

## Troubleshooting

### R2 Bucket Not Found

```bash
# List buckets
wrangler r2 bucket list

# Create bucket if missing
wrangler r2 bucket create pelapela-data
```

### CORS Errors

Update `CORS_ORIGIN` in `wrangler.toml` to match your frontend domain.

### Data Not Loading

Check R2 object paths:

```bash
# List objects in bucket
wrangler r2 object list pelapela-data
```

## License

MIT

## Support

For issues and questions:
- GitHub Issues: https://github.com/yourusername/pelapela-api/issues
- Documentation: https://developers.cloudflare.com/workers/
