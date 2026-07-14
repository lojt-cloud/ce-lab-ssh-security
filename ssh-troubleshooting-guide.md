# SSH Connection Troubleshooting Guide

## Decision Tree

1. **Can you ping the instance?**

   -  No → Check if instance is running, verify IP address
   -  Yes → Continue
   (Note: in my case, ping is intentionally blocked by the security group,
   so this step isn't actually useful for my setup - I'd use `nc -zv IP 22`
   instead to check reachability)

2. **Does `nc -zv IP 22` connect?**

   -  No → Check security group allows port 22 from your IP
   -  Yes → Continue

3. **What error do you get when SSH'ing?**

   - "Permission denied" → Check key file and username
   - "Connection refused" → Check SSH service is running on instance
   - "Connection timed out" → Check security group and network ACL
   - "Host key verification failed" → Remove old key from known_hosts

## Quick Checks

```bash
# 1. Verify key permissions
ls -l ~/.ssh/bootcamp-week2-key.pem
# Should show: -r--------

# 2. Verify correct key and user
ssh -i ~/.ssh/bootcamp-week2-key.pem ec2-user@IP

# 3. Check security group
aws ec2 describe-security-groups --group-names week2-web-server-sg --region us-east-1

# 4. Test port connectivity
nc -zv YOUR_PUBLIC_IP 22

# 5. SSH with verbose output
ssh -vvv bootcamp-web 2>&1 | tee ssh-debug.log
```

## Common Fixes

### Fix 1: Key Permissions
```bash
chmod 400 ~/.ssh/bootcamp-week2-key.pem
```

### Fix 2: Update Security Group
- Add rule: SSH (22) from YOUR_IP/32

### Fix 3: Verify Instance Running
- Check EC2 console - status should be "Running"
- Check Public IPv4 address hasn't changed (this happened to me after
  stopping/restarting my instance between labs - the IP changed and I
  had to update my SSH config)

### Fix 4: Remove Old Host Key
```bash
ssh-keygen -R YOUR_PUBLIC_IP
```