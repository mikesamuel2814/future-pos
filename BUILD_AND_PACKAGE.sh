#!/bin/bash
# Build and package both POS instances for deployment
# This script builds the application locally and creates deployment packages with dist included

set -e

echo "===== Building and Packaging POS Instances ====="

# Step 1: Build the application
echo "Step 1: Building application..."
npm ci
npm run build

# Verify build output
if [ ! -d "dist/public" ] || [ ! -f "dist/index.js" ]; then
    echo "ERROR: Build failed! dist/public or dist/index.js not found."
    exit 1
fi

echo "✓ Build completed successfully!"

# Step 2: Create deployment packages with dist included
echo "Step 2: Creating deployment packages..."

# Package for BFC POS
echo "Creating bfcpos-deploy.tar.gz..."
tar -czf bfcpos-deploy.tar.gz \
  --exclude='node_modules' \
  --exclude='.git' \
  --exclude='.env*' \
  --exclude='*.log' \
  --exclude='.DS_Store' \
  client server shared migrations scripts dist \
  package.json package-lock.json \
  tsconfig.json vite.config.ts tailwind.config.ts \
  postcss.config.js drizzle.config.ts components.json \
  deploy-bfc.sh start-bfc.sh ecosystem-bfc.config.cjs bfcpos.service nginx-bfc.conf

# Package for Bond Coffee POS
echo "Creating bondcoffeepos-deploy.tar.gz..."
tar -czf bondcoffeepos-deploy.tar.gz \
  --exclude='node_modules' \
  --exclude='.git' \
  --exclude='.env*' \
  --exclude='*.log' \
  --exclude='.DS_Store' \
  client server shared migrations scripts dist \
  package.json package-lock.json \
  tsconfig.json vite.config.ts tailwind.config.ts \
  postcss.config.js drizzle.config.ts components.json \
  deploy-bondcoffee.sh start-bondcoffee.sh ecosystem-bondcoffee.config.cjs bondcoffeepos.service nginx-bondcoffee.conf

# Common files for all POS apps (server overwrites start.sh; use start-bfc.sh so tar has a start script)
POS_FILES="client server shared migrations scripts dist package.json package-lock.json tsconfig.json vite.config.ts tailwind.config.ts postcss.config.js drizzle.config.ts components.json start-bfc.sh"

# Adora POS
echo "Creating adorapos-deploy.tar.gz..."
tar -czf adorapos-deploy.tar.gz \
  --exclude='node_modules' --exclude='.git' --exclude='.env*' --exclude='*.log' --exclude='.DS_Store' \
  $POS_FILES adorapos.service

# Sea POS
echo "Creating seapos-deploy.tar.gz..."
tar -czf seapos-deploy.tar.gz \
  --exclude='node_modules' --exclude='.git' --exclude='.env*' --exclude='*.log' --exclude='.DS_Store' \
  $POS_FILES seapos.service

# Coffeehouse POS
echo "Creating coffeehouse-deploy.tar.gz..."
tar -czf coffeehouse-deploy.tar.gz \
  --exclude='node_modules' --exclude='.git' --exclude='.env*' --exclude='*.log' --exclude='.DS_Store' \
  $POS_FILES coffeehouse.service

# Bar POS (uses barpos.service - systemd unit name is barpos)
echo "Creating bar-deploy.tar.gz..."
tar -czf bar-deploy.tar.gz \
  --exclude='node_modules' --exclude='.git' --exclude='.env*' --exclude='*.log' --exclude='.DS_Store' \
  $POS_FILES barpos.service

echo "✓ Deployment packages created!"
echo ""
echo "Packages ready:"
echo "  - bfcpos-deploy.tar.gz"
echo "  - bondcoffeepos-deploy.tar.gz"
echo "  - adorapos-deploy.tar.gz"
echo "  - seapos-deploy.tar.gz"
echo "  - coffeehouse-deploy.tar.gz"
echo "  - bar-deploy.tar.gz"
echo ""
echo "Next step: Run ./deploy-to-vps.sh to upload and deploy via Cloudflare Access SSH"

