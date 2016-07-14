#!/usr/bin/env bash


while getopts :u:p:t:d:n:f:b: OPT; do
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
        f)
            DBFQDN="${OPTARG}"
            ;;
        b)
            BENCH="${OPTARG}"
            ;;
        *)
            printf "\nOption -${BOLD}%s${NORM} not allowed.\n\n" "${OPTARG}"
            ;;
    esac
done

docker run -ti --restart unless-stopped -e DBUSER="${DBUSER}" -e DBPASS="${DBPASS}" -e DBTYPE="${DBTYPE}" \
    -e DBNAME="${DBNAME}" -e DBPORT="${DBPORT}" -e DBFQDN="${DBFQDN}" -e BENCH="${BENCH}" \
    --entrypoint /start.sh --name ${DBFQDN} rijalati/oltpbench

