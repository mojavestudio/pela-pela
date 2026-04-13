#!/bin/bash

# Test script for PelaPela API endpoints
# Usage: ./test-api.sh [base_url]

BASE_URL="${1:-http://localhost:8787}"

echo "🧪 Testing PelaPela API"
echo "Base URL: $BASE_URL"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

test_endpoint() {
    local name=$1
    local endpoint=$2
    
    echo -n "Testing $name... "
    
    response=$(curl -s -w "\n%{http_code}" "$BASE_URL$endpoint")
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n-1)
    
    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✓ OK${NC} (HTTP $http_code)"
        # Pretty print first 200 chars of response
        echo "$body" | jq -C '.' 2>/dev/null | head -n 5 || echo "$body" | head -c 200
        echo ""
    else
        echo -e "${RED}✗ FAILED${NC} (HTTP $http_code)"
        echo "$body"
        echo ""
    fi
}

# Test endpoints
echo "=== Basic Endpoints ==="
test_endpoint "Root" "/"
test_endpoint "Health" "/health"

echo ""
echo "=== Network Endpoints ==="
test_endpoint "Network Nodes" "/api/network/nodes?limit=5"
test_endpoint "Network Edges" "/api/network/edges?limit=5"

echo ""
echo "=== Skill Tree Endpoints ==="
test_endpoint "Skill Tree" "/api/skill-tree"

echo ""
echo "=== Lesson Endpoints ==="
test_endpoint "All Lessons" "/api/lessons?limit=5"
test_endpoint "Beginner Lessons" "/api/lessons?difficulty=beginner&limit=3"
test_endpoint "Learning Paths" "/api/learning-paths"

echo ""
echo "=== Data Endpoints ==="
test_endpoint "Vocabulary" "/api/vocabulary?limit=5"
test_endpoint "Grammar" "/api/grammar?limit=5"

echo ""
echo "✅ Testing complete!"
