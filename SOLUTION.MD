# SSH Connection and Security Best Practices Lab - Solution

**Student Name:** Balint Lojt
**Date Completed:** 14/07/2026

---

## Instance Details

- **Instance ID:** i-0f1913ce72c45fb6b
- **Public IP:** **.**.**.189
- **Security Group:** week2-web-server-sg
- **Key Pair:** bootcamp-week2-key.pem

---

## Step 1: Create SSH Config File

![SSH Config Working](Screenshots/ssh-config-working.png)

**My `~/.ssh/config`:**
```
Host bootcamp-web
    HostName XX.XX.XX.XX
    User ec2-user
    IdentityFile ~/.ssh/bootcamp-week2-key.pem
    ServerAliveInterval 60
    ServerAliveCountMax 3

- [ ] Connected using the alias: `ssh bootcamp-web`

---

## Step 2: Test Security Group Restrictions

![Security Tests](Screenshots/security-tests.png)

| Test | Expected | Result |
|------|----------|--------|
| `ssh bootcamp-web` |  Connects | [ yes] |
| `curl -I http://YOUR_PUBLIC_IP` |  HTTP 200 | [ yes] |
| `ping YOUR_PUBLIC_IP` |  Timeout | [no]  |
| `nc -zv YOUR_PUBLIC_IP 3306` |  Blocked | [no ] |

**Why did ping and port 3306 fail?**

Both failed for the same underlying reason: security groups work on a
"default deny" model. Nothing is allowed through unless it's explicitly
listed as an inbound rule. Ping uses ICMP, which was never added to the
security group, so it's blocked. Port 3306 (MySQL) also has no rule for it,
since I never intended to run a database on this instance - only SSH (22)
and HTTP (80) were ever explicitly opened. This confirms the security group
isn't accidentally more permissive than intended - only the ports I actually
configured are reachable.

## Step 3: Modify Security Group Rules

![Security Group Edit](Screenshots/security-group-edit.png)

- [X] Added HTTPS rule (port 443, source 0.0.0.0/0)
- [X] Tested it — what happened? [Failed to connect to the given IP because I haven't created any HTTPS service]
- [X] Removed the HTTPS rule again

---

## Step 4: Configure SSH Connection Timeouts

**What these settings do:**

- `ServerAliveInterval 60` — [Every 60 sec if I dont do anything in the ssh terminal it auto sends  a signal, it prevents that the session would close before I finish working in it.]
- `ServerAliveCountMax 3` — [If the auto sending signal fails 3 times in a row, the terminal will be considered unresponsive and after that it just disconnects]
- `TCPKeepAlive yes` — [Checks if the network is still up or disconnected, more of an extra step of protection]
- `Compression yes` — [compresses the data that I send through SSH connection, it improves the response time on a slow connection or higher latency one]

**Idle for 2 minutes — did the connection stay alive?** [Yes / No]

Yes, Since I just setup the keep alive command that does it every 60 sec and only if it fails 3 times (180sec) in a row disconnects 


## Step 5: Practice SCP (Secure Copy)

![SCP File Transfer](Screenshots/scp-file-transfer.png)

- [X] Copied a file TO the instance
- [X] Copied a file FROM the instance
- [X] Copied a whole directory

**Commands I used:**
```bash
scp test-file.txt bootcamp-web:~/
scp bootcamp-web:~/instance-info.txt ./downloaded-info.txt
scp -r my-website bootcamp-web:~/


## Step 6: Harden SSH Configuration (On Instance)

![SSH Hardening](Screenshots/ssh-hardening.png)

**Output of `sudo sshd -T | grep -i "passwordauthentication\|permitrootlogin\|pubkeyauthentication"`:**
```
[Paste output here]
```

| Setting | Expected | Actual |
|---------|----------|--------|
| PasswordAuthentication | no | [ ] |
| PermitRootLogin | without-password | [ ] |
| PubkeyAuthentication | yes | [ ] |

> Only verify these settings — do not modify `sshd_config`.

---

## Step 7: Create Connection Aliases with Scripts

**My `connect-bootcamp.sh`:**
```bash
[Paste your script here]
```

- [ ] Made it executable and tested it

---

## Step 8: Security Group Audit

![Security Group Audit](Screenshots/security-group-audit.png)

**Inbound rules:**

| Port | Source | Purpose |
|------|--------|---------|
| [22] | [YOUR_IP/32] | [SSH access] |
| [80] | [0.0.0.0/0] | [Web traffic] |

**Is this configuration secure? What would you improve?**

[Your answer]

---

## Step 9: Troubleshooting

**Problems I ran into and how I fixed them:**

[List them here, or write "None encountered"]

---

## Step 10: Security Best Practices

**Which advanced practices did you try or read about (custom SSH port, MFA, session logging)?**

[Your answer]

---

## Bonus Challenges (Optional)

- [ ] **Challenge 1:** Restrict outbound traffic — what broke? [Your answer]
- [ ] **Challenge 2:** Multiple security groups — how do they combine? [Your answer]
- [ ] **Challenge 3:** Connection multiplexing — was it faster? [Your answer]
- [ ] **Challenge 4:** Port forwarding with `ssh -L` — what is it useful for? [Your answer]

---

## Reflection Questions

### 1. Why use an SSH config file instead of typing the full command every time?

[Your answer]

### 2. Why restrict SSH to your IP instead of 0.0.0.0/0?

[Your answer]

### 3. What did the blocked ping and port 3306 tests teach you about security groups?

[Your answer]

### 4. Why disable password authentication for SSH?

[Your answer]

---

## Key Learnings

**What was most challenging about this lab?**

[Your reflection]

**What security practice will you always follow from now on?**

[Your reflection]

---

## Checklist

- [ ] SSH config file working with alias
- [ ] Security group tests done and documented
- [ ] Security group rule added and removed
- [ ] SCP tested both directions
- [ ] SSH daemon settings verified
- [ ] Connection script created
- [ ] Security group audited
- [ ] All screenshots captured
- [ ] Reflection questions answered
- [ ] Work committed to Git
- [ ] Pull request created

---

**Completed By:** [Your Name]  
**Date:** [Date]
