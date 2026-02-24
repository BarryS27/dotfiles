#!/usr/bin/env bash

echo "🔍 Checking NPM authentication..."
if ! npm whoami > /dev/null 2>&1; then
    echo "❌ Error: You are not logged in to NPM."
    echo "Please run 'npm login' manually first, then try again."
    exit 1
fi
echo "✅ Authenticated as $(npm whoami)"

if [[ -n $(git status --porcelain) ]]; then
    echo "❌ Error: Working directory is dirty. Commit your changes first."
    exit 1
fi

echo "Enter version type (patch/minor/major):"
read -r VERSION_TYPE

echo "🚀 Updating version..."
npm version "$VERSION_TYPE"

echo "📥 Pushing to GitHub (with tags)..."
git push origin main --tags

echo "📦 Publishing to NPM..."
npm publish --access public

echo "✅ Done! Package published successfully."