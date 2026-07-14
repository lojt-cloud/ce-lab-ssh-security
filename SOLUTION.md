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
permitrootlogin without-password
pubkeyauthentication yes
passwordauthentication no

'''

| Setting | Expected | Actual |
|---------|----------|--------|
| PasswordAuthentication | no | [ no] |
| PermitRootLogin | without-password | [ Without-password] |
| PubkeyAuthentication | yes | [ yes] |

> Only verified them but not modified. 

---

## Step 7: Create Connection Aliases with Scripts

**My `connect-bootcamp.sh`:**
```bash

#!/bin/bash
   # Quick connection script for bootcamp instance
   
   # Colors for output
   GREEN='\033[0;32m'
   BLUE='\033[0;34m'
   NC='\033[0m' # No Color
   
   echo -e "${BLUE}Connecting to bootcamp instance...${NC}"
   ssh bootcamp-web


- [X] Made it executable and tested it

---

## Step 8: Security Group Audit

![Security Group Audit](Screenshots/security-group-audit.png)

**Inbound rules:**

| Port | Source | Purpose |
|------|--------|---------|
| 22 | XXX.XXX.XXX.XXX/32 (redacted) | SSH access |
| 80 | 0.0.0.0/0 | Web traffic |


**Is this configuration secure? What would you improve?**

Yes, this is a reasonably secure baseline configuration
-  SSH restricted to specific IP
-  No unnecessary ports open
-  HTTP enabled for web server purpose
-  Consider: Restrict outbound traffic (currently unrestricted)

improves:
- Adding monitoring alerts for SSH attempts

- Using Session Manager instead of SSH - this would remove the need for
  port 22 to be open at all, since it connects through AWS's own backend
  rather than a traditional network port. Haven't set this up yet, but read about it. It's a stronger security posture than exposing SSH, even restricted to one IP.

- Enabling VPC Flow Logs - would let me see connection attempts (including
  blocked ones) that the security group currently just silently drops,
  useful for spotting attack patterns I'd otherwise never know about.

---

## Step 9: Troubleshooting

Created a separate ssh-troubleshooting-guide.md  for evrything that I encountered. 





## Step 10: Security Best Practices

**Which advanced practices did you try or read about (custom SSH port, MFA, session logging)?**

I read about all three rather than implementing them, given the risk of
locking myself out (as the lab itself warns) or the added complexity for
a short lab:

- **Custom SSH port (changing from 22 to something like 2222):** reduces
  automated bot scans, since most brute-force attempts specifically target
  the well-known default port 22. It's a minor obstacle though, not real
  security - a scan across all ports would still find it. It's sometimes
  called "security through obscurity" for that reason - helpful as one
  layer, not a real defense on its own.

- **MFA for SSH (via google-authenticator or Microsoft-Authenticator):** adds a second factor beyond
  just the key file - even if a private key were somehow compromised, an
  attacker would still need the second factor to get in. More setup
  complexity, but genuinely stronger than a key alone.

- **Session logging:** captures every command a user runs during an SSH
  session, useful for auditing after the fact (who did what, when).
   This connects to something I already learned matters: without any Flow
  Logs or session logging, security events currently happen silently with
  no record at all.

## Bonus Challenges (Optional)

- [ ] **Challenge 1:** Restrict outbound traffic — what broke? [Your answer]
- [ ] **Challenge 2:** Multiple security groups — how do they combine? [Your answer]
- [ ] **Challenge 3:** Connection multiplexing — was it faster? [Your answer]
- [ ] **Challenge 4:** Port forwarding with `ssh -L` — what is it useful for? [Your answer]

---

## Reflection Questions

### 1. Why use an SSH config file instead of typing the full command every time?

Convenience is the main benefit. Typing `ssh bootcamp-web` instead of the
full command with the key path and IP saves time and reduces typos. It also
keeps sensitive details out of places they'd otherwise end up, like shell
history or screen shares. if I type the short alias, my real IP and key
filename never appear in what I type day to day, even though they're still
stored in the config file itself (which I keep secured with 600 permissions
and never commit to git).

### 2. Why restrict SSH to your IP instead of 0.0.0.0/0?

If SSH (port 22) were open to 0.0.0.0/0, anyone on the entire internet could attempt to connect and try to brute-force their way in - repeatedly guessing usernames/passwords or looking for weak configurations. Restricting the source to just my own IP (/32) means only connections originating from my specific address are even allowed to reach port 22 at all. 
Everyone else's attempts are blocked at the network level before they can even try to authenticate.  This drastically shrinks who could possibly attack the SSH port, from "anyone on Earth" down to just me.

### 3. What did the blocked ping and port 3306 tests teach you about security groups?

### 3. What did the blocked ping and port 3306 tests teach you about security groups?

These tests confirmed that security groups work on a "default deny" model -
nothing is reachable unless it's explicitly listed as an allowed inbound
rule. Even though I never blocked ping or port 3306 myself, they were still
inaccessible simply because I never opened them in the first place. This
matters a lot for security, since automated bots constantly scan the
internet looking for open ports (especially common database ports like
3306) - a properly configured security group means those scans find
nothing to exploit, because only the ports I actually need (22 and 80)
are reachable at all.

### 4. Why disable password authentication for SSH?

Passwords can be guessed or brute-forced, especially if there's no limit on
failed login attempts. Bots constantly scan the internet trying common
passwords against exposed SSH ports. SSH keys, on the other hand, are long
cryptographic files that can't realistically be guessed or brute-forced,
even by bots or powerful computers - there's no "common key" to try, unlike
common passwords. Disabling password authentication removes the weakest,
most attackable method entirely, meaning the only way in is having the
actual private key file, which is far more secure than anything you type
from memory.

---

## Key Learnings

**What was most challenging about this lab?**

working through all the steps to build a genuinely secure setup end-to-end,
not any single step individually, but keeping track of how they all connect
(SSH config, security group rules, key permissions, verifying each layer
actually works as intended). 
It reminded me of the 5-W troubleshooting method from yesterday's cost anomaly lab. There's a similar systematic approach needed here too. 
I understand the core concepts, but building real fluency
with the full sequence will take continued practice.

**What security practice will you always follow from now on?**

Always verify security rules actually work as intended, rather than
assuming they're correct just because I configured them a certain way.
Today's tests (confirming ping and port 3306 were genuinely blocked, not
just assumed blocked) showed me that testing is what actually proves
security, not just the configuration itself. I'll carry that "verify, don't
assume" habit forward to any security setup I build in the future.

---

## Checklist

- [x] SSH config file working with alias
- [x] Security group tests done and documented
- [x] Security group rule added and removed
- [x] SCP tested both directions
- [x] SSH daemon settings verified
- [x] Connection script created
- [x] Security group audited
- [x] All screenshots captured
- [x] Reflection questions answered
- [x] Work committed to Git
- [x] Pull request created

---

**Completed By:** Balint Lojt
**Date:** 14/07/2026
