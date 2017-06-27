#!/usr/bin/env bash

declare -r progname="$(basename "${0}")"

function usage
{
    cat <<EOF

$(printf "${BOLD}NAME${NORM}")
  ${progname} - starts oltpbench docker containers.

$(printf "${BOLD}DESCRIPTION${NORM}")
  Requires all the arguments necessary to create and run the oltpbench docker
  container. This will generate a config on the fly and start the container in
  restart unless stopped mode, with benchmark set to run for 24 hours at a time.

$(printf "${BOLD}SYNOPSIS${NORM}")
  ${progname} [ options ] ...

$(printf "${BOLD}OPTIONS${NORM}")
  -u <username>
    username of database user that will run the benchmark.
  -p <password>
    password of the database user.
  -t <type>
    type of database you are connecting to.
  -d <name>
    name of the database you connecting to.
  -n <port>
    port number the database is listening on.
  -r <rate>
    rate limit for benchmark, defaults to unlimited.
  -f <fqdn>
    FQDN of the database you are connecting to.
  -b <bench>
    type of benchmark you wish to run.

$(printf "${BOLD}IMPLEMENTATION${NORM}")
  version         ${progname} (2016-07-14)
  author          Ritchie J Latimore <rijalati@gmail.com>
  copyright       Copyright (c) 2016 Ritchie J Latimore

EOF

    exit 2
}

(( $# == 0 )) && usage

while getopts :u:p:t:d:n:r:f:b: OPT; do
    case $OPT in
        u)
            DBUSER="${OPTARG}"
            ;;
        p)
            DBPASS="${OPTARG}"
            ;;
        t)
            DBTYPE="${OPTARG}"
            ;;
        d)
            DBNAME="${OPTARG}"
            ;;
        n)
            DBPORT="${OPTARG}"
            ;;
        r)
            RATE="${OPTARG}"
            ;;
        f)
            DBFQDN="${OPTARG}"
            ;;
        b)
            BENCH="${OPTARG}"
            ;;
        * )
	        printf "\nOption -${BOLD}%s${NORM} not allowed.\n\n" "${OPTARG}"
	        usage
	        ;;
    esac
done

docker run -d --restart unless-stopped -e DBUSER="${DBUSER}" \
       -e DBPASS="${DBPASS}" -e DBTYPE="${DBTYPE}" -e DBNAME="${DBNAME}" \
       -e DBPORT="${DBPORT}" -e DBFQDN="${DBFQDN}" -e BENCH="${BENCH}" \
       -e CLEARBOOL="${CLEARBOOL}" -e CREATEBOOL="${CREATEBOOL}" \
       -e EXECBOOL="${EXECBOOL}" -e LOADBOOL="${LOADBOOL}" \
       -e RATE="${RATE:=unlimited}" \
       --entrypoint /start.sh --name ${DBFQDN} rijalati/oltpbench

