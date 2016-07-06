#!/usr/bin/env mksh

set -e

eval target="/oltpbench/templates"

if [[ -z ${DBUSER} || -z ${DBPASS} || -z ${DBTYPE} || -z ${DBNAME} || -z ${DBPORT} ]]; then
    echo "Skipping config generation...\n"
else
    /bench-confgen.sh -f "${DBFQDN}" -u "${DBUSER}" -p "${DBPASS}" -t "${DBTYPE}" -d "${DBNAME}" -n "${DBPORT}" -b "${BENCH}" -o "${target}"
fi

/oltpbench/oltpbenchmark -b ${BENCH} -c "${target}/${DBFQDN}.xml" \
                         --clear true --create true --execute true --load true

exit $?
