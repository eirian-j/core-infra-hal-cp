# HAL Control Plane Infrastructure

Terraform configuration for deploying a lightweight control plane on OCI Free Tier AMD micro instance in Singapore region.

## Architecture

- **Instance**: AMD E2.1.Micro (1 OCPU, 1GB RAM)
- **Storage**: 30GB boot volume + 20GB data volume (50GB total)
  - Optimized to leave 50GB available for a second instance
- **Network**: VCN with public/private subnets and reserved public IP
- **Software**: Docker, Terraform, Ansible, OCI CLI, Vault CLI
- **Services**: Ofelia scheduler, Technitium DNS server

## Prerequisites

1. OCI account with free tier available
2. OCI CLI configured with credentials
3. Terraform installed locally
4. SSH key pair generated

## Setup Instructions

### 1. Configure OCI CLI

```bash
oci setup config
```

### 2. Get Required OCI Information

```bash
# Get compartment ID
oci iam compartment list

# Get availability domains
oci iam availability-domain list --compartment-id <compartment-id>

# Generate SSH key if needed
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
```

### 3. Configure Terraform Variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:
- `compartment_id`: Your OCI compartment OCID
- `availability_domain`: Choose an AD (e.g., "Xhqa:AP-SINGAPORE-1-AD-1")
- `ssh_public_key`: Content of your public SSH key
- `technitium_admin_password`: Strong password for DNS admin
- `cloudflare_api_token`: (Optional) For DNS record management
- `cloudflare_zone_id`: (Optional) Your Cloudflare zone ID

### 4. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review plan
terraform plan

# Apply configuration
terraform apply
```

### 5. Access Services

After deployment completes (5-10 minutes):

```bash
# SSH to instance
ssh -i ~/.ssh/id_rsa ubuntu@<public-ip>

# Or use the generated SSH config
ssh -F ssh_config hal-control

# Check cloud-init status
ssh ubuntu@<public-ip> "cloud-init status --wait"

# View Terraform outputs
terraform output
```

## Services

### Technitium DNS Server
- Web UI: `http://<public-ip>:5380`
- DNS: Port 53 (TCP/UDP)
- Default upstream: 1.1.1.1, 8.8.8.8

### Ofelia Scheduler
- Configuration: `/data/ofelia/config/config.ini`
- Logs: `/data/ofelia/logs/`
- Scheduled jobs:
  - Weekly system updates
  - Daily Docker cleanup
  - Daily configuration backups

## File Structure

```
/data/                      # Persistent data volume (20GB)
├── technitium/
│   ├── config/            # DNS configuration (~500MB)
│   └── logs/              # DNS logs (rotated)
├── ofelia/
│   ├── config/            # Scheduler configuration (~10MB)
│   └── logs/              # Scheduler logs (rotated)
└── backups/               # Daily backups (1-2GB rotating)
```

**Storage Optimization:**
- Boot volume (30GB): OS, Docker, tools, container images, working space
- Data volume (20GB): Persistent configs, logs, and backups
- Total: 50GB (leaving 50GB for redundancy instance)

## Management

### Using Ansible

```bash
# Test connectivity
ansible -i ansible/inventory.yml all -m ping

# Run playbook
ansible-playbook -i ansible/inventory.yml playbook.yml
```

### Docker Commands

```bash
# View running containers
docker ps

# View logs
docker logs technitium
docker logs ofelia

# Restart services
docker compose restart

# Update services
docker compose pull
docker compose up -d
```

### Backup and Restore

Backups are automatically created daily to `/data/backups/`.

To restore:
```bash
# Stop services
docker compose down

# Restore from backup
tar -xzf /data/backups/config-YYYYMMDD.tar.gz -C /

# Start services
docker compose up -d
```

## Monitoring

Check instance metrics in OCI Console:
1. Navigate to Compute > Instances
2. Select your instance
3. View Metrics tab

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Security Considerations

1. Change default passwords immediately
2. Configure firewall rules as needed
3. Enable OCI Cloud Guard for monitoring
4. Regularly update software packages
5. Monitor logs for suspicious activity

## Cost

This infrastructure uses OCI Free Tier resources:
- 1 AMD micro instance (always free)
- 50GB block storage (of 200GB free tier total)
  - 30GB boot + 20GB data volume
  - 50GB reserved for second instance
  - 100GB used by ARM server
- Reserved public IP (always free)
- No additional charges expected

## Troubleshooting

### Instance not accessible
- Check security list rules in OCI Console
- Verify SSH key is correct
- Check instance status in OCI Console

### Services not running
```bash
# Check cloud-init logs
sudo cat /var/log/cloud-init-output.log

# Check Docker status
sudo systemctl status docker

# Check container logs
docker logs technitium
docker logs ofelia
```

### DNS not resolving
- Verify port 53 is open in security list
- Check Technitium logs
- Test with: `dig @<public-ip> example.com`

## Support

For issues or questions:
1. Check OCI documentation
2. Review Terraform logs: `terraform plan -debug`
3. Check instance logs via OCI Console