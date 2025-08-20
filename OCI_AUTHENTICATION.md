# OCI Authentication Setup for Terraform Cloud

## Required Variables in Terraform Cloud

You need to set these variables in Terraform Cloud as **Environment Variables** (not Terraform Variables):

### 1. Generate OCI API Key
First, generate an API key in OCI Console:
1. Go to OCI Console → User Settings → API Keys
2. Click "Add API Key"
3. Generate a new key pair or upload your own
4. Download the private key
5. Copy the fingerprint shown

### 2. Set Variables in Terraform Cloud

In your Terraform Cloud workspace, go to Variables and add these as **Terraform Variables**:

| Variable Name | Type | Sensitive | Description | Example |
|--------------|------|-----------|-------------|---------|
| `tenancy_ocid` | Terraform Variable | Yes | Your tenancy OCID | `ocid1.tenancy.oc1..aaaaaaaaxxx` |
| `user_ocid` | Terraform Variable | Yes | Your user OCID | `ocid1.user.oc1..aaaaaaaaxxx` |
| `fingerprint` | Terraform Variable | Yes | API key fingerprint | `aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99` |
| `private_key` | Terraform Variable | Yes | Full private key content | See below |
| `compartment_id` | Terraform Variable | Yes | Compartment OCID | `ocid1.compartment.oc1..aaaaaaaaxxx` |
| `region` | Terraform Variable | No | OCI Region | `ap-singapore-1` |

### 3. Private Key Format

The `private_key` variable must include the ENTIRE private key content including headers:

```
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA... [multiple lines of base64 encoded key]
...
-----END RSA PRIVATE KEY-----
```

**Important**: Copy the entire content including the BEGIN and END lines.

## How to Find Your OCIDs

### Tenancy OCID
1. OCI Console → Administration → Tenancy Details
2. Copy the OCID shown

### User OCID  
1. OCI Console → Identity & Security → Users
2. Click on your username
3. Copy the OCID shown

### Compartment OCID
1. OCI Console → Identity & Security → Compartments
2. Click on your compartment
3. Copy the OCID shown

## Verify Authentication

After setting all variables, you can verify authentication by:
1. Triggering a new plan in Terraform Cloud
2. Check the plan output for any authentication errors

## Common Issues

### Issue: 401-NotAuthenticated
**Causes:**
- Missing or incorrect OCIDs
- Private key not copied completely
- Fingerprint doesn't match the uploaded key
- User doesn't have permissions in the compartment

**Solutions:**
1. Verify all OCIDs are correct
2. Regenerate the API key and update both fingerprint and private_key
3. Ensure the user has required policies:
   ```
   Allow group <your-group> to manage all-resources in compartment <compartment-name>
   ```

### Issue: Private Key Format Error
**Solution:**
Ensure the private key is entered exactly as downloaded, with Unix line endings (LF, not CRLF).

### Issue: Region Mismatch
**Solution:**
Ensure the `region` variable matches where your resources are located (e.g., `ap-singapore-1`, `us-ashburn-1`).

## Testing Locally (Optional)

To test authentication locally before using Terraform Cloud:

1. Create a local `terraform.tfvars` file:
```hcl
tenancy_ocid = "ocid1.tenancy.oc1..xxx"
user_ocid    = "ocid1.user.oc1..xxx"
fingerprint  = "aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99"
private_key  = <<EOF
-----BEGIN RSA PRIVATE KEY-----
...
-----END RSA PRIVATE KEY-----
EOF
compartment_id = "ocid1.compartment.oc1..xxx"
```

2. Run:
```bash
terraform init -backend=false
terraform plan
```

## Security Best Practices

1. Always mark authentication variables as "Sensitive" in Terraform Cloud
2. Rotate API keys regularly
3. Use separate API keys for different environments
4. Limit user permissions to only required compartments
5. Never commit credentials to version control