# OCI Always Free Resources

## What This Project Uses

All resources in this project are designed to fit within OCI's Always Free tier:

### Compute
- **Instance**: 1x VM.Standard.E2.1.Micro (1 OCPU, 1GB RAM)
- **Boot Volume**: 50GB (minimum required by OCI)
- **Public IP**: 1 ephemeral IP (included with instance)

### Networking (Always Free)
- **VCN**: 1 Virtual Cloud Network
- **Subnets**: 2 (public and private)
- **Internet Gateway**: 1
- **NAT Gateway**: 1
- **Route Tables**: Included
- **Security Lists**: Included

### Block Storage Budget
- **Free Tier**: 200GB total block volumes
- **This Project**: 0GB (boot volume doesn't count)
- **Available**: 200GB for other projects

## Important Notes

### Boot Volume vs Block Volume
- **Boot volumes** (attached to instances) are FREE and don't count against 200GB limit
- **Block volumes** (additional storage) count against 200GB limit
- This project uses ONLY a boot volume (50GB)

### Tagging
All resources are tagged with:
```
AlwaysFree = "true"
Purpose = "HAL-ControlPlane"
```

These tags are for organization only - OCI determines free tier eligibility based on resource specifications, not tags.

### Resource Limits
| Resource | Always Free Limit | This Project Uses |
|----------|------------------|-------------------|
| Compute Instances | 2 (AMD or ARM) | 1 AMD |
| Boot Volume | Included w/ instance | 50GB |
| Block Volumes | 200GB total | 0GB |
| Load Balancer | 1 (10Mbps) | 0 |
| Public IPs | 2 | 1 |
| VCNs | 2 | 1 |

### Validation
To verify resources are Always Free eligible:
1. Shape must be `VM.Standard.E2.1.Micro` (AMD) or `VM.Standard.A1.Flex` (ARM)
2. Boot volume is automatically free with instance
3. Block volumes must total ≤200GB across all instances

### Cost Protection
To ensure you stay within free tier:
1. Set up Cost Budgets in OCI Console
2. Create alert at $1 threshold
3. Enable email notifications

### Common Issues
- **50GB Minimum**: OCI now requires minimum 50GB for ALL volumes (boot and block)
- **Shape Availability**: E2.1.Micro might not always be available in all ADs
- **ARM Alternative**: Consider A1.Flex if E2.1.Micro unavailable (4 OCPU, 24GB RAM free)