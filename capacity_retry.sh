#!/bin/bash
# Retry script for OCI E2.1.Micro capacity issues
# Run this locally or in CI/CD to keep retrying until capacity is available

set -e

echo "OCI E2.1.Micro Capacity Retry Script"
echo "====================================="
echo "This will retry every 5 minutes until an instance can be created"
echo ""

# Configuration
MAX_ATTEMPTS=100  # About 8 hours of retrying
SLEEP_TIME=300    # 5 minutes between attempts
ATTEMPT=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    ATTEMPT=$((ATTEMPT + 1))
    echo -e "${YELLOW}Attempt $ATTEMPT of $MAX_ATTEMPTS at $(date)${NC}"
    
    # Try terraform apply
    if terraform apply -auto-approve 2>&1 | tee /tmp/terraform_output.log; then
        echo -e "${GREEN}SUCCESS! Instance created successfully!${NC}"
        
        # Send success notification (optional - add your notification method)
        # curl -X POST your-webhook-url -d "Instance created successfully"
        
        exit 0
    else
        # Check if it's a capacity error
        if grep -q "Out of host capacity" /tmp/terraform_output.log; then
            echo -e "${RED}Capacity error - will retry in $SLEEP_TIME seconds...${NC}"
            
            # Try different availability domain on next attempt
            CURRENT_AD=$(terraform output -raw availability_domain_number 2>/dev/null || echo "0")
            NEXT_AD=$(( (CURRENT_AD + 1) % 3 ))
            echo "Switching from AD $CURRENT_AD to AD $NEXT_AD for next attempt"
            export TF_VAR_availability_domain_number=$NEXT_AD
            
            sleep $SLEEP_TIME
        else
            echo -e "${RED}Non-capacity error detected. Check the logs above.${NC}"
            exit 1
        fi
    fi
done

echo -e "${RED}Max attempts reached. Please try again later or consider a different region.${NC}"
exit 1