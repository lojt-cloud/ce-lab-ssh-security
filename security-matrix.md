# Security Configuration Matrix

## Instance Details
- Instance ID: i-0f1913ce72c45fb6b
- Instance Type: t3.micro
- Public IP: XX.XX.XX.XX (redacted - public repo)
- Private IP: 172.31.18.190

## Security Group: week2-web-server-sg (sg-07d5a0e5e49cfdcde)

### Inbound Rules
| Protocol | Port | Source | Purpose | Risk Level |
|----------|------|--------|---------|------------|
| TCP | 22 | XXX.XXX.XXX.XXX/32 (redacted) | SSH admin access | Low (restricted IP) |
| TCP | 80 | 0.0.0.0/0 | Public web traffic | Low (expected) |

### Outbound Rules
| Protocol | Port | Destination | Purpose |
|----------|------|-------------|---------|
| All | All | 0.0.0.0/0 | Unrestricted egress |
