# Terraform Cloud Variables Configuration

## Required Variables for Terraform Cloud

### OCI Authentication Variables (mark as Sensitive)

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `tenancy_ocid` | string | OCI Tenancy OCID | `ocid1.tenancy.oc1..aaaaaaaaxxx` |
| `user_ocid` | string | OCI User OCID | `ocid1.user.oc1..aaaaaaaaxxx` |
| `fingerprint` | string | API Key Fingerprint | `aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99` |
| `private_key` | string | OCI API Private Key | See below |
| `compartment_id` | string | Compartment OCID | `ocid1.compartment.oc1..aaaaaaaaxxx` |

### SSH Access Variable (mark as Sensitive)

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `ssh_public_key` | string | SSH PUBLIC Key | `ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ...` |

⚠️ **IMPORTANT**: The `ssh_public_key` must be an SSH PUBLIC key, NOT a private key!

### Infrastructure Variables

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `availability_domain_number` | number | AD index (0=AD-1, 1=AD-2, 2=AD-3) | 0 |
| `technitium_admin_password` | string | Technitium DNS admin password | (set your own) |
| `data_volume_size_gb` | number | Data volume size (min 50 GB) | 50 |

### Optional Variables

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `cloudflare_api_token` | string | CloudFlare API token | "" |
| `cloudflare_zone_id` | string | CloudFlare Zone ID | "" |
| `region` | string | OCI Region | "ap-singapore-1" |

### Grafana Cloud Variables (Optional - for log shipping)

| Variable | Type | Description | How to Get |
|----------|------|-------------|------------|
| `grafana_loki_url` | string | Loki Push URL | From Grafana Cloud → Loki Details |
| `grafana_loki_username` | string | Loki User ID (numeric) | From Grafana Cloud → Loki Details |
| `grafana_loki_password` | string | API Key (mark as Sensitive) | Create in Grafana Cloud → Security → API Keys |

#### Setting up Grafana Cloud Free:
1. Sign up at https://grafana.com/products/cloud/ (free tier)
2. Go to your stack → Loki → Details
3. Copy the Push URL (e.g., `https://logs-prod-us-central1.grafana.net/loki/api/v1/push`)
4. Copy the User ID (numeric, e.g., `123456`)
5. Create an API Key with "MetricsPublisher" role
6. Add these values to Terraform Cloud variables

## Common Issues and Solutions

### Issue: Invalid ssh public key type "-----BEGIN"
**Problem**: You're providing a PRIVATE key instead of a PUBLIC key.

**Solution**: 
- Use your SSH PUBLIC key (usually found in `~/.ssh/id_rsa.pub`)
- Format: `ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ...`
- NOT the private key that starts with `-----BEGIN RSA PRIVATE KEY-----`

### Issue: The requested volumeSize X GB is not supported
**Problem**: OCI requires minimum 50 GB for block volumes.

**Solution**: 
- Set `data_volume_size_gb = 50` or higher

### Issue: 401-NotAuthenticated
**Problem**: OCI authentication credentials are incorrect.

**Solution**: 
- Verify all OCIDs are correct
- Ensure the `private_key` includes full content with headers:
```
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA...
...
-----END RSA PRIVATE KEY-----
```

### Issue: Invalid availability domain
**Problem**: Using string like "AD-1" instead of full AD name.

**Solution**: 
- Use `availability_domain_number` (0, 1, or 2) instead of string

## Private Key Format

The `private_key` variable must include the ENTIRE OCI API private key:

```
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA...
[multiple lines of base64 encoded key]
...
-----END RSA PRIVATE KEY-----
```

## SSH Key Formats

### Correct SSH PUBLIC Key Format:
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDfRN... user@hostname
```

### Incorrect (this is PRIVATE key):
```
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA...
-----END RSA PRIVATE KEY-----
```

## How to Generate SSH Keys

If you need to generate new SSH keys:

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 2048 -f ~/.ssh/oci_key

# View your PUBLIC key (use this for ssh_public_key variable)
cat ~/.ssh/oci_key.pub

# Keep the private key (~/.ssh/oci_key) secure for SSH access
```