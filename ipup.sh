#!/bin/bash

loginPortal="";      #link to send the post req to
userName="";         #username for logging into the service
password="";         #password
dynDnsUpdateLink=""; #link to update the dynDNS service.
firstNumber01="";    #first number to precede the IP say 101.*.*.*
firstNumber02="";    #alternate

#get an ip beginning with $firstNumber01 or $firstNumber02 else reconnect
while true;
do
    #detect IP
    #myip="$(curl -s "myip.dnsdynamic.org")";
    myip="$(curl -s "icanhazip.com")";

    if [ $( echo "$myip" | grep -e "^$firstNumber01" -e "^$firstNumber02" ) ]; then
        #read oldip if exists
        [ -f "/tmp/myip" ] && oldip="$(cat "/tmp/myip")" || oldip="";
        #check if any change
        if [ "$oldip" = "$myip" ]; then
            #echo "No change in IP";
            :
        else
	    echo >> ~/web/ddns;
            echo "$myip" > "/tmp/myip";
	    response="$(curl -s $dynDnsUpdateLink)";

	    # if no error, log and exit
	    if [ $(echo "$response" | grep -q -e '^ERROR') ]; then 
                echo "$(date)" >> ~/web/ddns;
		echo "$response" >> ~/web/ddns;
		exit; 
	    else
		#log error and retry
                echo "$(date)" >> ~/web/ddns;
		echo "$response" >> ~/web/ddns;
	    fi;
        fi;
        exit;
    else 
        #logout
	echo >> ~/web/ddns;
        echo "$(date)" >> ~/web/ddns;
        echo "Got $myip. loggin out and back in." >> ~/web/ddns;
        curl -X POST -H "Content-Type: application/x-www-form-urlencoded" --data "logout=Click+here+to+logout" $loginPortal;
        sleep 5;
        #login
        curl -X POST -H "Content-Type: application/x-www-form-urlencoded" --data "user=$userName&pass=$password&login=Login" $loginPortal;
        sleep 5;
    fi;
done;
