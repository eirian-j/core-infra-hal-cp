# OCI E2.1.Micro Capacity Solutions

## The Problem
"Out of host capacity" errors are very common with OCI's free E2.1.Micro instances, especially in popular regions like Singapore.

## Immediate Solutions

### 1. Manual Rotation Through ADs
In Terraform Cloud, try each availability domain:
```
availability_domain_number = 0  # Try AD-1
availability_domain_number = 1  # Try AD-2  
availability_domain_number = 2  # Try AD-3
```

### 2. Best Times to Try
Based on community reports, best success rates:
- **Early morning** (2-7 AM local time)
- **Late night** (11 PM - 2 AM local time)
- **Weekends** generally better than weekdays
- **Avoid** business hours (9 AM - 6 PM)

### 3. Local Retry Script
Run the included script to automatically retry:
```bash
chmod +x capacity_retry.sh
./capacity_retry.sh
```

This will:
- Retry every 5 minutes
- Automatically rotate through ADs
- Stop when successful

### 4. GitHub Actions Automation
The included `.github/workflows/capacity_retry.yml` will:
- Run automatically during off-peak hours
- Try all 3 availability domains
- Stop retrying once successful

To enable:
1. Add `TF_API_TOKEN` secret in GitHub (your Terraform Cloud token)
2. Enable Actions in your repository
3. Wait for scheduled runs or trigger manually

### 5. Terraform Cloud Scheduled Runs
In Terraform Cloud workspace settings:
1. Go to Settings → Run Triggers
2. Add Schedule
3. Set to run every hour during off-peak times
4. It will eventually succeed when capacity is available

## Advanced Solutions

### 6. Multi-Region Strategy
If Singapore consistently fails, consider:
```hcl
# In variables.tf, make region configurable
variable "region" {
  default = "ap-singapore-1"  
  # Alternative: "ap-mumbai-1", "ap-sydney-1"
}
```

### 7. Webhook Notifications
Add to retry script for alerts:
```bash
# Success notification
curl -X POST https://hooks.slack.com/your-webhook \
  -d '{"text":"✅ OCI instance created successfully!"}'
```

### 8. API-Based Monitoring
Use OCI CLI to check capacity:
```bash
# Check capacity in all ADs
for i in 1 2 3; do
  echo "Checking AD-$i..."
  oci compute instance launch --dry-run \
    --availability-domain "AD-$i" \
    --shape "VM.Standard.E2.1.Micro" \
    --compartment-id "$COMPARTMENT_ID" \
    2>&1 | grep -E "capacity|success"
done
```

## Tips from the Community

1. **Don't give up**: Users report success after 20-50 attempts
2. **Region matters**: Mumbai and Sydney often have better availability
3. **Persistence wins**: Set up automation and let it run
4. **Monitor OCI Status**: Check https://ocistatus.oraclecloud.com/
5. **Try after maintenance**: Capacity often available after OCI maintenance windows

## Alternative Approaches

### If you absolutely can't get E2.1.Micro:
1. **Use spot/preemptible instances** in other clouds during initial setup
2. **Develop locally** with Vagrant/VirtualBox mimicking OCI
3. **Request quota increase** (sometimes OCI support helps)
4. **Consider paid tier temporarily** (can be ~$30/month)

## Patience is Key
The free tier is popular. With automation and patience, you WILL get an instance. Most users report success within 24-48 hours of automated retrying.