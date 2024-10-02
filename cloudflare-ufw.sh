#!/bin/sh

#Note to developer: This sort of firewall modification is best done when the IPs are as a 'set' (see nft 'sets') (man nft).
#It results in less modifications to the ruleset, and less checks when a packet goes through the firewall.
#
# The code is untested. try the 'dry-run' flag first.

CF_IPLIST_V4_URL="https://www.cloudflare.com/ips-v4";
CF_IPLIST_V6_URL="https://www.cloudflare.com/ips-v6";

#If the first parameter is empty, or is '-h' or '--help'
if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  printf "\nUsage: $0 <arguments>\n">&2;
  printf " Description:\n">&2;
  printf "  The program adds rules to ufw that permit inbound traffic from Cloudflare IPs; source and destination ports are configurable.\n">&2;
  printf "  The IP Lists are downloaded from:\n">&2;
  printf "   IPV4: $CF_IPLIST_V4_URL\n">&2;
  printf "   IPV6: $CF_IPLIST_V6_URL\n">&2;
  printf "\n">&2;
  printf " Arguments:\n">&2;
  printf "  \"-pl\" or \"--port-local\" or \"-pll\" or \"--port-list-local\"\n">&2;
  printf "   Note: this is a port, or a list of ports that are permitted as a destination.">&2;
  printf "\n">&2;
  printf "  \"-pr\" or \"--port-remote\" or \"-plr\" or \"--port-list-remote\"\n">&2;
  printf "   Note: this is a port, or a list of ports that are permitted as a source.">&2;
  printf "\n">&2;
  exit 2;
fi

PORTS_ALLOWED_LOCAL="";
PORTS_ALLOWED_REMOTE="";

while true; do
  case $1 in
    #accept a port, or a list of ports for the local (destination) side.
    -pl|--port-local|-pll|--port-list-local)
      #not enough arguments
      if [ $# -lt 2 ]; then
        printf "\n$0:\nNot enough arguments. ">&2;
        exit 2;
      #the value for the port or port list is empty
      elif [ -z "$2" ]; then
        printf "\n$0:\nValue for $1 was empty. ">&2;
        exit 2;
      else
        PORTS_ALLOWED_LOCAL=$2;
        shift 2;
      fi
    ;;
    
    #accept a port, or a list of ports for the remote (source) side.
    -pr|--port-remote|-plr|--port-list-remote)
      #not enough arguments
      if [ $# -lt 2 ]; then
        printf "\n$0:\nNot enough arguments. ">&2;
        exit 2;
      #the value for the port or port list is empty
      elif [ -z "$2" ]; then
        printf "\n$0:\nValue for $1 was empty. ">&2;
        exit 2;
      else
        PORTS_ALLOWED_REMOTE=$2;
        shift 2;
      fi
    ;;

    #When all arguments are shifted.
    "") break; ;;

    #When encountering an 'unrecognised' or 'unknown' argument.
    *) printf "\nUnrecognised argument \"$1\". ">&2; exit 2; ;;
  esac
done

if [ -z "$PORTS_ALLOWED_LOCAL" ]; then
  printf "\n$0: Defaulting to destination/local ports (49152-65535).\n">&1;
  #Default to 'ephemeral' or 'dynamic' ports as assigned by IANA.
  #Your system likely defaults to the range 32786-65535 instead.
  #Adjust as neccessary.
  PORTS_ALLOWED_LOCAL="49152-65535";
fi

if [ -z "$PORTS_ALLOWED_REMOTE" ]; then
  printf "\n$0: Defaulting to source/remote ports (any).\n">&1;
  PORTS_ALLOWED_REMOTE="";
fi

IP_LIST_V4=$(curl -sw '\n' $CF_IPLIST_V4_URL);
#check the exit code from curl
case $? in
  #success (continue)
  0) ;;
  #handle other exit codes here
  #any other exit code:
  *) printf "\n$0: curl failed with an exit code of: \"$?\".\n">&2; ;;
esac

i=1;
IP_LIST_V4_LENGTH=$(echo $IP_LIST_V4 | wc -l);
while true; do
  #get a chunk up to the position in the list, then take the last element in the list (newline delimited)
  CF_IP4_ELEMENT=$(echo $IP_LIST_V4 | head -n $i | tail -n 1);

  #inbound rule.
  if [ -z "$PORTS_ALLOWED_REMOTE" ]; then
    ufw allow in proto tcp from $CF_IP4_ELEMENT to any port $PORTS_ALLOWED_LOCAL comment "Cloudflare Inbound from port/s $PORTS_ALLOWED_REMOTE to local port/s $PORTS_ALLOWED_LOCAL";
  else
    ufw allow in proto tcp from $CF_IP4_ELEMENT port $PORTS_ALLOWED_REMOTE to any port $PORTS_ALLOWED_LOCAL comment "Cloudflare Inbound from port/s $PORTS_ALLOWED_REMOTE to local port/s $PORTS_ALLOWED_LOCAL";
  fi
  
  #outbound rule.
  if [ -z "$PORTS_ALLOWED_REMOTE" ]; then
   ufw allow out proto tcp from any port $PORTS_ALLOWED_LOCAL to $CF_IP4_ELEMENT comment "Cloudflare Outbound from port/s $PORTS_ALLOWED_LOCAL to remote port/s $PORTS_ALLOWED_REMOTE";   
  else
    ufw allow out proto tcp from any port $PORTS_ALLOWED_LOCAL to $CF_IP4_ELEMENT port $PORTS_ALLOWED_REMOTE comment "Cloudflare Outbound from port/s $PORTS_ALLOWED_LOCAL to remote port/s $PORTS_ALLOWED_REMOTE";    
  fi

  #move next, and if outside list bounds, exit.
  i=$(($i+1));
  if [ $i -gt $IP_LIST_V4_LENGTH ]; then break; fi
done

IP_LIST_V6=$(curl -sw '\n' $CF_IPLIST_V6_URL);
#Check the exit code from curl
case $? in
  #success (continue)
  0) ;;
  #handle other exit codes here
  #any other exit code:
  *) printf "\n$0: curl failed with an exit code of: \"$?\".\n">&2; ;;
esac

j=1;
IP_LIST_V6_LENGTH=$(echo $IP_LIST_V6 | wc -l);
while true; do
  #get a chunk up to the position in the list, then take the last element in the list (newline delimited)
  CF_IP6_ELEMENT=$(echo $IP_LIST_V6 | head -n $j | tail -n 1);

  #inbound rule.
  if [ -z "$PORTS_ALLOWED_REMOTE" ]; then
    ufw allow in proto tcp from $CF_IP6_ELEMENT to any port $PORTS_ALLOWED_LOCAL comment "Cloudflare Inbound from port/s $PORTS_ALLOWED_REMOTE to local port/s $PORTS_ALLOWED_LOCAL";      
  else
    ufw allow in proto tcp from $CF_IP6_ELEMENT port $PORTS_ALLOWED_REMOTE to any port $PORTS_ALLOWED_LOCAL comment "Cloudflare Inbound from port/s $PORTS_ALLOWED_REMOTE to local port/s $PORTS_ALLOWED_LOCAL";  
  fi
  
  #outbound rule.
  if [ -z "$PORTS_ALLOWED_REMOTE" ]; then
    ufw allow out proto tcp from any port $PORTS_ALLOWED_LOCAL to $CF_IP6_ELEMENT comment "Cloudflare Outbound from port/s $PORTS_ALLOWED_LOCAL to remote port/s $PORTS_ALLOWED_REMOTE";        
  else
    ufw allow out proto tcp from any port $PORTS_ALLOWED_LOCAL to $CF_IP6_ELEMENT port $PORTS_ALLOWED_REMOTE comment "Cloudflare Outbound from port/s $PORTS_ALLOWED_LOCAL to remote port/s $PORTS_ALLOWED_REMOTE";    
  fi

  #move next, and if outside list bounds, exit.
  j=$(($j+1));
  if [ $j -gt $IP_LIST_V6_LENGTH ]; then break; fi
done

#print total ips allowed traffic to and from to standard output.
printf "\nAllowed traffic to and from $i IPV4 Cloudflare IP's.\n">&1;
printf "\nAllowed traffic to and from $j IPV6 Cloudflare IP's.\n">&1;

#reload the filter to apply changes, redirect output to null (discard)
ufw reload > /dev/null
