#!/usr/bin/env mksh

set -vx

function download_driver
{
    curl -H "Authorization: Basic |BASICAUTH|" \
         s3auth.bm-engops.com/oltpbench/db2jcc4.jar > lib/db2jcc4.jar \
        || printf "Downloading DB2 jdbc driver failed, please provide the basic
auth base64 encoded creds as the environment var BASICAUTH (the correct value
is in Keeper). If you do not work for Blue Medora consider building your own image
and manually embedding the driver in the image, or check out s3auth.com if you
would like to put it on s3 like we did.\n"

    return
}

function update_pom
{
    IBM_CFG1="$(cat <<EOF
<dependency>
    <groupId>com.ibm.db2.jcc</groupId>
    <artifactId>db2jcc4</artifactId>
    <version>4.23.42</version>
    <scope>system</scope>
    <systemPath>\${project.basedir}/lib/db2jcc4.jar</systemPath>
</dependency>
EOF
)"

    awk -v cfg="${IBM_CFG1}" "{ gsub(/<!--IBM_CFG1-->/,cfg); print}" /oltpbench/pom.xml > /tmp/mod.pom.xml
    mv /tmp/mod.pom.xml /oltpbench/pom.xml

    return
}

function update_classpath
{
    IBM_CFG2="$(cat <<EOF
<classpathentry kind="lib" path="lib/db2jcc4.jar"/>
EOF
)"
    awk -v cfg="${IBM_CFG2}" "{ gsub(/<!--IBM_CFG2-->/,cfg); print}" /oltpbench/.classpath > /oltpbench/mod.classpath
    mv /tmp/.classpath /oltpbench/.classpath

    return
}

function main
{
    download_driver
    update_pom
    update_classpath

    cat pom.xml .classpath
    return
}

main
exit $?
#EOF.
