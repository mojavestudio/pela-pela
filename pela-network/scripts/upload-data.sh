#!/bin/bash

# Upload all data files to Cloudflare R2
# Run this script from the pelapela-api directory

set -e

BUCKET_NAME="pelapela-data"
PARENT_DIR=".."

echo "🚀 Uploading data to Cloudflare R2 bucket: $BUCKET_NAME"
echo ""

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    echo "❌ Error: wrangler CLI not found"
    echo "Install it with: npm install -g wrangler"
    exit 1
fi

# Create bucket if it doesn't exist
echo "📦 Ensuring R2 bucket exists..."
wrangler r2 bucket create $BUCKET_NAME 2>/dev/null || echo "Bucket already exists"
echo ""

# Upload network data
echo "📊 Uploading network data..."
if [ -f "$PARENT_DIR/network_output/nodes.json" ]; then
    wrangler r2 object put $BUCKET_NAME/network_output/nodes.json \
        --file "$PARENT_DIR/network_output/nodes.json"
    echo "  ✓ nodes.json uploaded"
else
    echo "  ⚠️  nodes.json not found"
fi

if [ -f "$PARENT_DIR/network_output/edges.json" ]; then
    wrangler r2 object put $BUCKET_NAME/network_output/edges.json \
        --file "$PARENT_DIR/network_output/edges.json"
    echo "  ✓ edges.json uploaded"
else
    echo "  ⚠️  edges.json not found"
fi

echo ""

# Upload skill tree
echo "🌳 Uploading skill tree..."
if [ -f "$PARENT_DIR/skill_tree_output/skill_tree.json" ]; then
    wrangler r2 object put $BUCKET_NAME/skill_tree_output/skill_tree.json \
        --file "$PARENT_DIR/skill_tree_output/skill_tree.json"
    echo "  ✓ skill_tree.json uploaded"
else
    echo "  ⚠️  skill_tree.json not found"
fi

echo ""

# Upload lesson plan
echo "📚 Uploading lesson plan..."
if [ -f "$PARENT_DIR/lesson_plan_output/lesson_plan.json" ]; then
    wrangler r2 object put $BUCKET_NAME/lesson_plan_output/lesson_plan.json \
        --file "$PARENT_DIR/lesson_plan_output/lesson_plan.json"
    echo "  ✓ lesson_plan.json uploaded"
else
    echo "  ⚠️  lesson_plan.json not found"
fi

echo ""

# Upload clean data
echo "🗂️  Uploading clean data..."
if [ -f "$PARENT_DIR/data/clean/vocabulary_entry.json" ]; then
    wrangler r2 object put $BUCKET_NAME/data/clean/vocabulary_entry.json \
        --file "$PARENT_DIR/data/clean/vocabulary_entry.json"
    echo "  ✓ vocabulary_entry.json uploaded"
else
    echo "  ⚠️  vocabulary_entry.json not found"
fi

if [ -f "$PARENT_DIR/data/clean/grammar_pattern.json" ]; then
    wrangler r2 object put $BUCKET_NAME/data/clean/grammar_pattern.json \
        --file "$PARENT_DIR/data/clean/grammar_pattern.json"
    echo "  ✓ grammar_pattern.json uploaded"
else
    echo "  ⚠️  grammar_pattern.json not found"
fi

echo ""
echo "✅ Upload complete!"
echo ""
echo "📋 List uploaded files:"
wrangler r2 object list $BUCKET_NAME
