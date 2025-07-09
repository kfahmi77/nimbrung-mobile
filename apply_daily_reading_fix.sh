#!/bin/bash

# ============================================================================
# DAILY READING FIX APPLICATION SCRIPT
# This script applies the complete fix for the daily reading generation issue
# ============================================================================

echo "=== APPLYING DAILY READING FIX FOR JULY 9, 2025 ==="
echo ""

# Check if psql is available
if ! command -v psql &> /dev/null; then
    echo "❌ ERROR: psql command not found."
    echo "Please install PostgreSQL client tools first:"
    echo "  brew install postgresql"
    echo ""
    exit 1
fi

# Check if Supabase connection details are set
if [ -z "$SUPABASE_DB_URL" ]; then
    echo "⚠️  WARNING: SUPABASE_DB_URL environment variable not set."
    echo "Please set your Supabase database connection URL:"
    echo "  export SUPABASE_DB_URL='postgresql://postgres:[password]@[host]:5432/postgres'"
    echo ""
    echo "Or run the script manually with:"
    echo "  psql 'your_connection_string_here' -f sql/complete_fix_july_9.sql"
    echo ""
    exit 1
fi

echo "🔧 Applying complete fix script..."
echo ""

# Apply the complete fix
if psql "$SUPABASE_DB_URL" -f sql/complete_fix_july_9.sql; then
    echo ""
    echo "✅ Complete fix applied successfully!"
    echo ""
    
    echo "🔍 Running verification script..."
    echo ""
    
    # Run verification
    if psql "$SUPABASE_DB_URL" -f sql/verify_deployment_status.sql; then
        echo ""
        echo "📊 Running debug script to check daily readings..."
        echo ""
        
        # Run debug script
        psql "$SUPABASE_DB_URL" -f sql/debug_july_9_readings.sql
        
        echo ""
        echo "🎉 DAILY READING FIX DEPLOYMENT COMPLETE!"
        echo ""
        echo "Next steps:"
        echo "1. Check the output above to verify daily readings were generated"
        echo "2. Monitor the cron job logs for consistent execution"
        echo "3. Verify users are receiving daily readings in the app"
        echo ""
    else
        echo "❌ Verification script failed. Please check the output above."
        exit 1
    fi
else
    echo "❌ Fix script failed. Please check the output above and resolve any errors."
    exit 1
fi
