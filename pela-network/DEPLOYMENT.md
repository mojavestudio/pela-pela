# Deployment Guide

Complete guide to deploying the PelaPela API to Cloudflare Workers.

## Prerequisites

1. **Cloudflare Account**: Sign up at https://dash.cloudflare.com
2. **Node.js**: Version 16 or higher
3. **Wrangler CLI**: Installed globally or via npm

## Step-by-Step Deployment

### 1. Install Dependencies

```bash
cd pelapela-api
npm install
```

### 2. Authenticate with Cloudflare

```bash
npx wrangler login
```

This opens a browser window for authentication.

### 3. Create R2 Bucket

```bash
npx wrangler r2 bucket create pelapela-data
```

Verify bucket creation:

```bash
npx wrangler r2 bucket list
```

### 4. Upload Data Files

Use the provided script:

```bash
./scripts/upload-data.sh
```

Or manually upload each file:

```bash
# Network data
npx wrangler r2 object put pelapela-data/network_output/nodes.json \
  --file ../network_output/nodes.json

npx wrangler r2 object put pelapela-data/network_output/edges.json \
  --file ../network_output/edges.json

# Skill tree
npx wrangler r2 object put pelapela-data/skill_tree_output/skill_tree.json \
  --file ../skill_tree_output/skill_tree.json

# Lesson plan
npx wrangler r2 object put pelapela-data/lesson_plan_output/lesson_plan.json \
  --file ../lesson_plan_output/lesson_plan.json

# Clean data
npx wrangler r2 object put pelapela-data/data/clean/vocabulary_entry.json \
  --file ../data/clean/vocabulary_entry.json

npx wrangler r2 object put pelapela-data/data/clean/grammar_pattern.json \
  --file ../data/clean/grammar_pattern.json
```

Verify uploads:

```bash
npx wrangler r2 object list pelapela-data
```

### 5. Test Locally

```bash
npm run dev
```

Visit http://localhost:8787 to test the API locally.

Test endpoints:

```bash
# In another terminal
./examples/test-api.sh http://localhost:8787
```

### 6. Deploy to Production

```bash
npm run deploy
```

Your API will be deployed to: `https://pelapela-api.YOUR_SUBDOMAIN.workers.dev`

### 7. Configure Custom Domain (Optional)

1. Go to Cloudflare Dashboard → Workers & Pages
2. Select your worker (`pelapela-api`)
3. Click "Triggers" tab
4. Add custom domain (requires domain on Cloudflare)

Example: `api.pelapela.com`

### 8. Update CORS Settings

For production, update `wrangler.toml`:

```toml
[env.production]
name = "pelapela-api-production"
vars = { CORS_ORIGIN = "https://yourdomain.com" }
```

Deploy production:

```bash
npx wrangler deploy --env production
```

## Verification

### Test Deployed API

```bash
# Replace with your actual worker URL
export API_URL="https://pelapela-api.YOUR_SUBDOMAIN.workers.dev"

# Test health endpoint
curl $API_URL/health

# Test lessons
curl "$API_URL/api/lessons?limit=5"

# Test vocabulary
curl "$API_URL/api/vocabulary?limit=10"
```

### Monitor Logs

```bash
npm run tail
```

Or view in dashboard:
https://dash.cloudflare.com/workers

## Updating Data

When you regenerate data files:

```bash
# Re-run the upload script
./scripts/upload-data.sh

# Or upload specific files
npx wrangler r2 object put pelapela-data/lesson_plan_output/lesson_plan.json \
  --file ../lesson_plan_output/lesson_plan.json
```

No need to redeploy the worker - R2 changes are immediate.

## Environment Variables

Set secrets (not in version control):

```bash
npx wrangler secret put API_KEY
# Enter your secret when prompted
```

Access in worker:

```javascript
const apiKey = env.API_KEY;
```

## Rollback

If deployment fails, rollback to previous version:

```bash
npx wrangler rollback
```

## Cost Estimation

### Free Tier
- 100,000 requests/day
- 10ms CPU time per request
- Sufficient for development and small projects

### Paid Tier ($5/month)
- 10 million requests/month
- 50ms CPU time per request
- Recommended for production

### R2 Storage
- Storage: ~$0.015/GB/month
- Class A operations (writes): $4.50/million
- Class B operations (reads): $0.36/million
- Free egress (no bandwidth charges)

**Estimated monthly cost for 100K requests/day:**
- Workers: Free (or $5 for paid tier)
- R2 Storage: ~$0.01 (for ~10MB data)
- R2 Operations: ~$0.10
- **Total: ~$0.11/month (free tier) or ~$5.11/month (paid tier)**

## Troubleshooting

### Error: "Bucket not found"

```bash
# Verify bucket exists
npx wrangler r2 bucket list

# Create if missing
npx wrangler r2 bucket create pelapela-data
```

### Error: "Binding not found"

Check `wrangler.toml` has correct R2 binding:

```toml
[[r2_buckets]]
binding = "PELAPELA_DATA"
bucket_name = "pelapela-data"
```

### CORS Errors

Update CORS_ORIGIN in `wrangler.toml` to match your frontend domain.

### 500 Internal Server Error

Check logs:

```bash
npm run tail
```

Common causes:
- Missing data files in R2
- Malformed JSON in R2 objects
- Incorrect R2 bucket binding

### Data Not Loading

Verify R2 objects:

```bash
# List all objects
npx wrangler r2 object list pelapela-data

# Download and check a file
npx wrangler r2 object get pelapela-data/lesson_plan_output/lesson_plan.json \
  --file test.json
cat test.json | jq '.' | head
```

## Performance Optimization

### Enable Caching

Add cache headers in responses:

```javascript
return new Response(JSON.stringify(data), {
  headers: {
    'Content-Type': 'application/json',
    'Cache-Control': 'public, max-age=3600', // Cache for 1 hour
    ...corsHeaders
  }
});
```

### Use KV for Frequently Accessed Data

For hot data, consider KV instead of R2:

```toml
[[kv_namespaces]]
binding = "CACHE"
id = "your-kv-namespace-id"
```

```javascript
// Store in KV
await env.CACHE.put('lessons:beginner', JSON.stringify(lessons), {
  expirationTtl: 3600 // 1 hour
});

// Read from KV
const cached = await env.CACHE.get('lessons:beginner');
if (cached) {
  return jsonResponse(JSON.parse(cached), 200, corsHeaders);
}
```

## Security Best Practices

1. **Restrict CORS in production**
2. **Add rate limiting** for public APIs
3. **Use API keys** for sensitive endpoints
4. **Enable Cloudflare WAF** for DDoS protection
5. **Monitor usage** in dashboard

## Next Steps

- [ ] Set up custom domain
- [ ] Configure production CORS
- [ ] Add rate limiting
- [ ] Set up monitoring alerts
- [ ] Create API documentation site
- [ ] Add authentication (if needed)

## Support

- Cloudflare Workers Docs: https://developers.cloudflare.com/workers/
- Cloudflare R2 Docs: https://developers.cloudflare.com/r2/
- Wrangler CLI Docs: https://developers.cloudflare.com/workers/wrangler/
