#!/usr/bin/env mksh
set -vex
URL="https://download.oracle.com/otn-pub/utilities_drivers/jdbc/122010/ojdbc8.jar"
#URL="http://download.oracle.com/otn/utilities_drivers/jdbc/121020/ojdbc7.jar"
#URL="http://download.oracle.com/otn/utilities_drivers/jdbc/11204/ojdbc6.jar"

print 'By downloading the Oracle Database JDBC Driver you are
accepting the OTN License Agreement.

This is a link to a copy of the OTN License Agreement:
<http://www.oracle.com/technetwork/licenses/distribution-license-152002.html>'

curl --location-trusted --remote-name -# \
     --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
     --insecure "${URL}"
wget -c -O ojdbc8.jar --no-check-certificate --no-cookies --header \
     "Cookie: oraclelicense=accept-securebackup-cookie" "${URL}"
#mv -v ojdbc[6-8].jar /oltpbench/lib/
