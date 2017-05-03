#!/usr/bin/env mksh
set -vex

print 'By downloading the Oracle Database JDBC Driver you are
accepting the OTN License Agreement.

This is a link to a copy of the OTN License Agreement:
<http://www.oracle.com/technetwork/licenses/distribution-license-152002.html>'

function mksettings_xml
{

    eval typeset -r MVN_EPASS="${ mvn -emp ${MVN_PASS}; }"
    eval typeset -r ORACLEMVN_EPASS="${ mvn -ep ${ORACLEMVN_PASS}; }"

    cat > /tmp/settings-security.xml <<-EOF
<settingssecurity>
<master>${MVN_EPASS}</master>
</settingssecurity>

EOF


    cat > /tmp/settings.xml <<-EOF
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
EOF
)"

    sed -i.bak1 "s/<!--ORACLE_CFG1-->/${ORACLE_CFG1}/g" /oltpbench/pom.xml
    sed -i.bak2 "s/<!--ORACLE_CFG2-->/${ORACLE_CFG2}/g" /oltpbench/pom.xml
}

function main
{
    mksettings_xml
    updatepom_xml

    return $?
}

main
exit "$?"
