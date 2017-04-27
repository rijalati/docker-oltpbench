#!/usr/bin/env mksh

URL="http://download.oracle.com/otn/utilities_drivers/jdbc/122010/ojdbc8.jar"

cd /oltpbench/libs || exit 2

print 'By downloading the Oracle Database 12.2.0.1 JDBC Driver you are
accepting the OTN License Agreement.

This is a link to a copy of the OTN License Agreement:
<http://www.oracle.com/technetwork/licenses/distribution-license-152002.html>'

curl --location --remote-name \
     --header "Cookie: oraclelicense=accept-securebackup-cookie" \
     --insecure "${URL}"

cd ..
