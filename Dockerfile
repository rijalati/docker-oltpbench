FROM rijalati/alpine-zulu-jdk8:latest
MAINTAINER rijalati@gmail.com

RUN apk update --no-cache \
    && apk add git tar mksh && git clone https://github.com/rijalati/oltpbench.git
WORKDIR /oltpbench

RUN cd /oltpbench && git checkout errorprone && ant clean && ant
RUN mkdir /oltpbench/templates /config-templates
COPY my-templates/ /oltpbench/templates
COPY config-templates/ /oltpbench/config-templates/
COPY start.sh /start.sh
COPY bench-confgen.sh bench-confgen.sh
COPY ojdbc-get.sh ojdbc-get.sh
COPY ntlmauth.dll /oltpbench/lib/

RUN chmod +x oltpbenchmark \
    && chmod +x /start.sh

ENV DBFQDN='' DBUSER='' DBPASS='' DBTYPE='' DBNAME='' DBPORT='' BENCH=''
ENV CLEARBOOL='' CREATEBOOL='' EXECBOOL='' LOADBOOL=''

ENTRYPOINT ["/start.sh"]
