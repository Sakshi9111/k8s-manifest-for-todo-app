#!/bin/bash

# SBOM Debug and Test Script
# This script helps debug SBOM generation issues

set -e

APP_NAME="todo-app"
VERSION="2.0"

echo "=========================================="
echo "SBOM Generation Debug Script"
echo "=========================================="
echo ""

# Check if syft is installed
if ! command -v syft &> /dev/null; then
    echo "❌ Syft not found. Installing..."
    curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
    echo "✓ Syft installed"
else
    echo "✓ Syft found: $(syft version)"
fi

echo ""

# Create SBOM directory
mkdir -p sbom-output
echo "✓ Created sbom-output directory"
echo ""

# Test 1: Generate SBOM from current directory
echo "Test 1: Scanning current directory..."
echo "----------------------------"
syft dir:. -o json=sbom-output/test1-dir.json -v 2>&1 | tail -20

if [ -f sbom-output/test1-dir.json ]; then
    COUNT=$(jq '.artifacts | length' sbom-output/test1-dir.json)
    echo "✓ Directory scan: $COUNT packages found"
    if [ "$COUNT" -gt 0 ]; then
        echo "Sample packages:"
        jq -r '.artifacts[0:5] | .[] | "  - " + .name + " (" + .version + ")"' sbom-output/test1-dir.json
    else
        echo "⚠️  Warning: 0 packages found in directory scan"
    fi
else
    echo "❌ Failed to generate SBOM from directory"
fi

echo ""

# Test 2: Check if package.json exists
echo "Test 2: Checking package.json..."
echo "----------------------------"
if [ -f package.json ]; then
    echo "✓ package.json found"
    echo "Dependencies count: $(jq '.dependencies | length' package.json 2>/dev/null || echo '0')"
    echo "DevDependencies count: $(jq '.devDependencies | length' package.json 2>/dev/null || echo '0')"
else
    echo "❌ package.json not found"
fi

echo ""

# Test 3: Check node_modules
echo "Test 3: Checking node_modules..."
echo "----------------------------"
if [ -d node_modules ]; then
    MODULE_COUNT=$(ls -1 node_modules | wc -l)
    echo "✓ node_modules found with $MODULE_COUNT packages"
    
    # Generate SBOM specifically from package.json
    syft file:package.json -o json=sbom-output/test3-packagejson.json 2>/dev/null || echo "⚠️  Could not scan package.json directly"
    
    if [ -f sbom-output/test3-packagejson.json ]; then
        COUNT=$(jq '.artifacts | length' sbom-output/test3-packagejson.json)
        echo "✓ package.json scan: $COUNT packages found"
    fi
else
    echo "❌ node_modules not found"
    echo "Run 'npm install' first"
fi

echo ""

# Test 4: Generate SBOM from Docker image if it exists
echo "Test 4: Scanning Docker image (if exists)..."
echo "----------------------------"
if docker image inspect ${APP_NAME}:${VERSION} &> /dev/null; then
    echo "✓ Docker image ${APP_NAME}:${VERSION} found"
    
    syft ${APP_NAME}:${VERSION} -o json=sbom-output/test4-image.json
    
    if [ -f sbom-output/test4-image.json ]; then
        COUNT=$(jq '.artifacts | length' sbom-output/test4-image.json)
        echo "✓ Image scan: $COUNT packages found"
        if [ "$COUNT" -gt 0 ]; then
            echo "Sample packages from image:"
            jq -r '.artifacts[0:10] | .[] | "  - " + .name + " (" + .version + ") [" + .type + "]"' sbom-output/test4-image.json
        fi
    fi
else
    echo "⚠️  Docker image ${APP_NAME}:${VERSION} not found"
    echo "Build it with: docker build -t ${APP_NAME}:${VERSION} ."
fi

echo ""

# Test 5: Try different scan approaches
echo "Test 5: Alternative scanning methods..."
echo "----------------------------"

# Try scanning with package-lock.json
if [ -f package-lock.json ]; then
    echo "Scanning package-lock.json..."
    syft file:package-lock.json -o json=sbom-output/test5-packagelock.json 2>/dev/null || echo "⚠️  Could not scan package-lock.json"
    
    if [ -f sbom-output/test5-packagelock.json ]; then
        COUNT=$(jq '.artifacts | length' sbom-output/test5-packagelock.json)
        echo "✓ package-lock.json scan: $COUNT packages"
    fi
fi

# Try explicit npm cataloger
echo "Scanning with explicit npm cataloger..."
syft dir:. -o json=sbom-output/test5-explicit.json --catalogers npm 2>&1 | grep -i "cataloger" || echo "Using default catalogers"

if [ -f sbom-output/test5-explicit.json ]; then
    COUNT=$(jq '.artifacts | length' sbom-output/test5-explicit.json)
    echo "✓ Explicit npm scan: $COUNT packages"
fi

echo ""

# Summary
echo "=========================================="
echo "Summary of SBOM Generation Tests"
echo "=========================================="
echo ""

for file in sbom-output/*.json; do
    if [ -f "$file" ]; then
        COUNT=$(jq '.artifacts | length' "$file" 2>/dev/null || echo "0")
        SIZE=$(ls -lh "$file" | awk '{print $5}')
        echo "$(basename $file): $COUNT packages ($SIZE)"
    fi
done

echo ""
echo "All SBOM files saved to: sbom-output/"
echo ""

# Check if any scan found packages
MAX_COUNT=0
for file in sbom-output/*.json; do
    if [ -f "$file" ]; then
        COUNT=$(jq '.artifacts | length' "$file" 2>/dev/null || echo "0")
        if [ "$COUNT" -gt "$MAX_COUNT" ]; then
            MAX_COUNT=$COUNT
            BEST_FILE=$file
        fi
    fi
done

if [ "$MAX_COUNT" -gt 0 ]; then
    echo "✓ SUCCESS: Best SBOM has $MAX_COUNT packages"
    echo "✓ Best file: $(basename $BEST_FILE)"
    echo ""
    echo "Use this SBOM in your pipeline!"
else
    echo "❌ PROBLEM: All SBOMs have 0 packages"
    echo ""
    echo "Troubleshooting suggestions:"
    echo "1. Make sure you've run 'npm install' to create node_modules"
    echo "2. Check if package.json has dependencies listed"
    echo "3. Try running: syft dir:. -vv (very verbose) to see what's happening"
    echo "4. Ensure you're in the correct project directory"
fi

echo ""
echo "=========================================="
