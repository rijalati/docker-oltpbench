#!/usr/bin/env mksh
set -vex

print 'By downloading the Oracle Database JDBC Driver you are
accepting the OTN License Agreement.

This is a link to a copy of the OTN License Agreement:
<http://www.oracle.com/technetwork/licenses/distribution-license-152002.html>'

function mksettings_xml
{

    if [[ ! -d /root/.m2 ]]; then
        mkdir /root/.m2
    fi

    cat > /root/.m2/settings-security.xml <<-EOF
<settingsSecurity>
<master>${MVN_EPASS}</master>
</settingsSecurity>

EOF

    eval typeset -r MVN_EPASS="${ mvn -emp ${MVN_PASS}; }"
    eval typeset -r ORACLEMVN_EPASS="${ mvn -ep ${ORACLEMVN_PASS}; }"

    cat > /root/.m2/settings.xml <<-EOF
<settings>
<servers>
  <server>
    <id>maven.oracle.com </id>
    <username>${ORACLEMVN_USER}</username>
    <password>${ORACLEMVN_EPASS}</password>
  <configuration>
    <basicAuthScope>
      <host>ANY </host>
      <port>ANY </port>
      <realm>OAM 11g </realm>
    </basicAuthScope>
    <httpConfiguration>
      <all>
      <params>
        <property>
          <name>http.protocol.allow-circular-redirects </name>
          <value>%b,true </value>
        </property>
      </params>
      </all>
    </httpConfiguration>
  </configuration>
  </server>
  </servers>
</settings>

EOF
}

function updatepom_xml
{
    ORACLE_CFG1="$(cat <<-EOF
  <repositories>
    <repository>
      <id>maven.oracle.com</id>
      <name>oracle-maven-repo</name>
      <url>https://maven.oracle.com</url>
      <layout>default</layout>
      <releases>
        <enabled>true</enabled>
        <updatePolicy>always</updatePolicy>
      </releases>
    </repository>
  </repositories>

  <pluginRepositories>
    <pluginRepository>
      <id>maven.oracle.com</id>
      <name>oracle-maven-repo</name>
      <url>https://maven.oracle.com</url>
      <layout>default</layout>
      <releases>
        <enabled>true</enabled>
        <updatePolicy>always</updatePolicy>
      </releases>
    </pluginRepository>
  </pluginRepositories>
EOF
)"

    ORACLE_CFG2="$(cat <<-EOF
    <dependency>
      <groupId>com.oracle.jdbc</groupId>
      <artifactId>ojdbc8</artifactId>
      <version>12.2.0.1</version>
    </dependency>
    <dependency>
      <groupId>com.oracle.jdbc</groupId>
      <artifactId>orai18n</artifactId>
      <version>12.2.0.1</version>
    </dependency>
    <dependency>
      <groupId>com.oracle.jdbc</groupId>
      <artifactId>ucp</artifactId>
      <version>12.2.0.1</version>
    </dependency>
EOF
)"

    ORACLE_CFG3="$(cat <<-EOF
    <classpathentry kind="lib" path="lib/ojdbc8-12.2.0.1.jar"/>
EOF
)"
    ORACLE_CFG4="$(cat <<-EOF
    <dialect>config/dialects/tpcc_dialects.xml</dialect>
EOF
)"
    awk -v cfg="${ORACLE_CFG1}" "{ gsub(/<!--ORACLE_CFG1-->/,cfg); print}" /oltpbench/pom.xml > /tmp/mod.pom.xml
    awk -v cfg="${ORACLE_CFG2}" "{ gsub(/<!--ORACLE_CFG2-->/,cfg); print}" /tmp/mod.pom.xml > /oltpbench/pom.xml
    awk -v cfg="${ORACLE_CFG3}" "{ gsub(/<!--ORACLE_CFG3-->/,cfg); print}" /oltpbench/.classpath > /oltpbench/mod.classpath
    awk -v cfg="${ORACLE_CFG4}" "{ gsub(/<!--ORACLE_CFG4-->/,cfg); print}" /oltpbench/config-templates/benchmarks/tpcc.xml > /tmp/mod.tpcc.xml
    mv /oltpbench/mod.classpath /oltpbench/.classpath
    mv /tmp/mod.tpcc.xml /oltpbench/config-templates/benchmarks/tpcc.xml
    cat /oltpbench/pom.xml
    cat /root/.m2/*
}

function main
{
    mksettings_xml
    updatepom_xml

    return $?
}

main
exit "$?"
