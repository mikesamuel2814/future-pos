#!/bin/bash
# BFC POS System - Startup Wrapper Script
# This script loads environment variables from .env.production before starting the app
set -e

# Load environment variables
set -a
source /var/www/bfcpos/.env.production
set +a

# Change to application directory
cd /var/www/bfcpos

# Start the application directly with node
exec node dist/index.js

