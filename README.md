# cloudflare-ufw
Script to update UFW with Cloudflare IPs

This script was kindly [written by Leow Kah Man](https://www.leowkahman.com/2016/05/02/automate-raspberry-pi-ufw-allow-cloudflare-inbound/) and I've added a few tweaks!

### Setup
Assuming that you already have ufw installed (now a pre-installed package in most linux distros), firstly ensure that ufw is not enabled;

```sudo ufw status verbose```

If it's not enabled, the response should be ```Status: inactive``` but if not, let's disable it;

```sudo ufw disable```

Clear out any existing rules;

```sudo ufw reset```

and set the default rules to deny incoming and allow outgoing connections;

```sudo ufw default deny incoming```  
```sudo ufw default allow outgoing```

It's important at this stage to prevent being accidently being locked out of your system by adding 2 rules, before going further.  
Add a localhost rule;

```sudo ufw allow from 192.168.1.0/24```

and also allow SSH access;

```sudo ufw allow ssh```

Provided those rules were succesfully added, time to enable your firewall;

```sudo ufw enable```

You will receive a warning that says the "command may disrupt existing ssh connections." We have already set up a firewall rule that allows SSH connections so it should be fine to continue. Respond to the prompt with y.  
You can run the ```sudo ufw status verbose``` command to see the rules that are set.

### Install the script

Git clone this repo to your system, and run the bash script in the normal manner;

```sudo /your/path/cloudflare-ufw/./cloudflare-ufw.sh```

The script will then download Cloudflare's current v4 & v6 IP's, and install them into ufw's configuration. Check that the rules have been successfuly added; ```sudo ufw status verbose```

### Scheduling

Everytime the script is run, it will add any new Cloudflare IP addresses, so consider running the script weekly to ensure that it's kept up to date.  
The script can run automatically by using cron;

```sudo crontab -e```

and add the event;

```0 0 * * 1 /your/path/cloudflare-ufw/cloudflare-ufw.sh > /dev/null 2>&1```

**OR**

If using node-red, simply add ```sudo /your/path/cloudflare-ufw/./cloudflare-ufw.sh``` to an 'exec node' and inject it every week.

### Other UFW commands

#### Delete a single rule
Firstly get a numbered list of all rules  
```sudo ufw status numbered```

and then delete the rule by number  
```sudo ufw delete 34```
