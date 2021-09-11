#!/bin/sh

curl -s https://www.cloudflare.com/ips-v4 -o /tmp/cf_ips
echo "" >> /tmp/cf_ips
curl -s https://www.cloudflare.com/ips-v6 >> /tmp/cf_ips

# Allow all traffic from Cloudflare IPs (no ports restriction)
for cfip in `cat /tmp/cf_ips`; do ufw allow proto tcp from $cfip comment 'Cloudflare IP'; done

ufw reload > /dev/null

# OTHER EXAMPLE RULES
# Retrict to port 80
#for cfip in `cat /tmp/cf_ips`; do ufw allow proto tcp from $cfip to any port 80 comment 'Cloudflare IP'; done

# Restrict to port 443
#for cfip in `cat /tmp/cf_ips`; do ufw allow proto tcp from $cfip to any port 443 comment 'Cloudflare IP'; done

# Restrict to ports 80 & 443
#for cfip in `cat /tmp/cf_ips`; do ufw allow proto tcp from $cfip to any port 80,443 comment 'Cloudflare IP'; done
