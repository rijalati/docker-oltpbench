#!/usr/bin/env mksh

set -vx

function download_driver
{
    #mkdir -p /oltpbench/lib/repo #/com/ibm/db2/jcc/db2jcc4/4.23.42

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
    # If the heredoc marker is only a set
    # of either single "''" or double '""' quotes with nothing in
    # between, the here document ends at the next empty line and
    # substitution will not be performed.

    IBM_CFG1="$(cat <<''
<dependency>
    <groupId>com.ibm.db2.jcc</groupId>
    <artifactId>db2jcc4</artifactId>
    <version>4.23.42</version>
    <!-- <scope>system</scope>
    <systemPath>${project.basedir}/lib/db2jcc4.jar</systemPath> -->
</dependency>

)"

    IBM_CFG2="$(cat <<-EOF
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-install-plugin</artifactId>
        <version>2.5.2</version>
        <configuration>
          <groupId>org.ibm.db2.jcc</groupId>
          <artifactId>db2jcc4</artifactId>
          <version>4.23.42</version>
          <packaging>jar</packaging>
          <file>${package.basedir}/lib/db2jcc4.jar</file>
          <generatePom>true</generatePom>
        </configuration>
        <executions>
          <execution>
            <id>install-jar-lib</id>
            <goals>
              <goal>install-file</goal>
            </goals>
            <phase>validate</phase>
          </execution>
        </executions>
      </plugin>
EOF
    )"

    awk -v cfg="${IBM_CFG1}" "{ gsub(/<!--IBM_CFG1-->/,cfg); print}" pom.xml > /tmp/mod.pom.xml
    #awk -v cfg="${IBM_CFG2}" "{ gsub(/<!--IBM_CFG2-->/,cfg); print}" /tmp/mod.pom.xml > /oltpbench/pom.xml
    mv /tmp/mod.pom.xml pom.xml

    return
}

function update_classpath
{
    IBM_CFG3="$(cat <<EOF
<classpathentry kind="lib" path="lib/db2jcc4.jar"/>
EOF
)"
    awk -v cfg="${IBM_CFG3}" "{ gsub(/<!--IBM_CFG3-->/,cfg); print}" .classpath > /oltpbench/mod.classpath
    mv /oltpbench/mod.classpath /oltpbench/.classpath

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
