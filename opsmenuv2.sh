#!/bin/bash

RESET='\033[0m'
BLACK='\033[01;30m' 
RED='\033[01;31m' 
REDBLK='\033[01;31;40m' 
GREEN='\033[01;32m' 
YELLOW='\033[01;33m'
BLUE='\033[01;34m' 
BLUEUND='\033[03;04;34m' 
WHITE='\033[01;37m'
remote_user='unixjp' # declare user to login remote to collect information

#show()
#{
#        local x=$1
#        local y=$2
#        local txt="$3"
#        # Set cursor position on screen
#        tput cup $x $y
#        echo "$txt"
#}

#clock()
#{
#  echo "$(date +"%c")"
#}

menu()
{
  echo -e ${BLUE}"=========================================================================="
  echo " _     _       _           _____                ______                    ";
  echo "| |   | |     (_)         / ___ \              |  ___ \                   ";
  echo "| |   | |____  _ _   _   | |   | |____   ___   | | _ | | ____ ____  _   _ ";
  echo "| |   | |  _ \| ( \ / )  | |   | |  _ \ /___)  | || || |/ _  )  _ \| | | |";
  echo "| |___| | | | | |) X (   | |___| | | | |___ |  | || || ( (/ /| | | | |_| |";
  echo " \______|_| |_|_(_/ \_)   \_____/| ||_/(___/   |_||_||_|\____)_| |_|\____|";
  echo "                                 |_|                                      ";
  echo "Powered by OST JPN UNIX                                            VER 2.0";
  echo "$(date)"
  echo "=========================================================================="
  echo  ""
  echo  -e ${GREEN}"Enter 1 to check Server Uptime : "
  echo  "Enter 2 to check Server Disk Usage : "
  echo  "Enter 3 to check Linux Server Memory Usage: "
  echo  "Enter 4 to check Solaris Server Memory Usage: "
  echo  -e ${YELLOW}"Enter c to Check CI Support Contact: "${RESET}
  echo  -e ${RED}"Enter q to exit the menu q: "${RESET}
  echo  -e "\n"
  echo  -e "Enter your Selection: \c"
}

# Check hostname & ssh connection
check_host()
{
  nc -zw5 $remote_hostname 22 &>/dev/null #stdout & Stderr to null
  check=`echo $?`
  return
}

# SSH to remote server
remote()
{
  printf "Please enter HOSTNAME: "
  read remote_hostname
  check_host $remote_hostname 
  #sudo su -c "Your command right here" -s /bin/sh otheruser
  if [ $check -eq 0 ]
  then
    ssh -l unixjp -t -o StrictHostKeyChecking=no -q ${remote_hostname} "${1}" 
  else
    echo -e ${RED}"Hostname invalid or port 22 is not open"${RESET}
  fi
}

# Check CI Support Contact
check_contact()
{
  printf "Enter the CI name: "
  read CI_name
  /root/donkong ${CI_name} | grep -i Support
  #sudo su -c "/root/donkong ${CI_name} | grep -i Support" -s /bin/sh $remote_user
}

# Function to check Server Uptime
check_uptime()
{
  remote " uptime"
}

# Function to check Disk Usage
check_df()
{
  remote " df -h"
}

# Function to check Memory Info for RedHat
check_rhmem()
{
  remote "free -m"
  echo ""
  echo "==================TOP_5_MEMORY_EATING_PROCESS==========================="
  echo "USER      PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND"
  ssh -l unixjp -t -o StrictHostKeyChecking=no -q ${remote_hostname} "ps auxf | sort -nr -k 4 | head -5"
}

# Function to check Memory Info for Solaris
check_solmem()
{
  remote " prstat -Z 1 1"
}
trap '' 2
while true
do
  clear
  menu # Display menu
  read answer
  case "$answer" in 
   1) check_uptime
      ;;
   2) check_df
      ;;
   3) check_rhmem
      ;;
   4) check_solmem
      ;;	 
   c) check_contact
      ;;
   q) exit ;;
   *) tput blink; echo -e ${REDBLK}"Invalid Option Selected!!"${RESET};;
  esac
  echo -e "Enter return to continue \c"
  read  input
done

