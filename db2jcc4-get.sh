#!/bin/sh

set -vx

curl -H "Authorization: Basic |BASICAUTH|" \
     s3auth.bm-engops.com/oltpbench/db2jcc4.jar > lib/db2jcc4.jar \
    || printf "Downloading DB2 jdbc driver failed, please provide the basic
auth base64 encoded creds as the environment var BASICAUTH (the correct value
is in Keeper). If you are outside Blue Medora consider building your own image
and manually embedding the driver in the image, or check out s3auth.com if you
would like to put it on s3 like we did.\n"

#EOF.
