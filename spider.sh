#!/bin/bash

echo "Enter an IP address: "
read ip

# Ping the IP address to check if it is up
if ping -c 1 "$ip" &> /dev/null
then
    # Print "Target locked" in red
    printf "\033[0;31mTarget locked\033[0m\n"

    # Perform an nmap scan on the IP address to get service names and open ports
    nmap_output=$(nmap -sV "$ip")

    # Check if nmap reports that the host is blocking our ping probes
    if grep -q "All probes failed" <<< "$nmap_output"
    then
        # If the host is blocking our ping probes, try again with the -Pn flag
        nmap_output=$(nmap -sV -Pn "$ip")
    fi

    # Extract the service names and versions from the nmap output
    services=$(grep -Eo "([0-9]{1,3}/[a-zA-Z]+).*[a-zA-Z]+\s[a-zA-Z]+\s[0-9a-zA-Z\.-]+" <<< "$nmap_output")

    # Print the service names and versions in green
    printf "\033[0;32m$services\033[0m\n"

    # Search for exploits for the services in searchsploit
    exploits=$(searchsploit "$services")

    # Check if there are any results
    if [ -z "$exploits" ]
    then
        # If there are no results, print "System is Secured!" in green
        printf "\033[0;32mSystem is Secured!\033[0m\n"
    else
        # If there are results, print "System is Vulnerable!" in red
        printf "\033[0;31mSystem is Vulnerable!\033[0m\n"

        # Differentiate between metasploit exploits and other exploits
        metasploit_exploits=$(grep "Metasploit" <<< "$exploits")
        other_exploits=$(grep -v "Metasploit" <<< "$exploits")

        # Print the metasploit exploits
        printf "\033[0;31mMetasploit Exploits:\n$metasploit_exploits\033[0m\n"

        # Print the other exploits
        printf "\033[0;31mOther Exploits:\n$other_exploits\033[0m\n"
    fi
else
    # If the host is not up, print "Unable to reach target" in red
    printf "\033[0;31mUnable to reach target\033[0m\n"
fi
