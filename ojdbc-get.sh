#!/usr/bin/env mksh

#URL="http://download.oracle.com/otn/utilities_drivers/jdbc/122010/ojdbc8.jar"
#URL="http://download.oracle.com/otn/utilities_drivers/jdbc/121020/ojdbc7.jar"
URL="http://download.oracle.com/otn/utilities_drivers/jdbc/11204/ojdbc6.jar"
cd lib || exit 2

print 'By downloading the Oracle Database JDBC Driver you are
accepting the OTN License Agreement.

This is a link to a copy of the OTN License Agreement:
<http://www.oracle.com/technetwork/licenses/distribution-license-152002.html>'

curl --location --remote-name \
     --header "Cookie: oraclelicense=accept-securebackup-cookie" \
     --insecure "${URL}"

cd ..
