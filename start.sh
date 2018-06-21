#!/usr/bin/env mksh


set -vex

echo "${ENV}"

export target="/oltpbench/templates"

/oltpbench/bench-confgen.sh -f "${DBFQDN}" -u "${DBUSER}" \
    -p "${DBPASS}" -t "${DBTYPE}" -d "${DBNAME}" \
    -n "${DBPORT}" -b "${BENCH}" -o "${target}" \
    -r "${RATE}" -c "${CLIENTS}" -s "${SCALE}" -i "${ISOLATION}"


/oltpbench/oltpbenchmark -b "${BENCH}" -c "${target}/${DBFQDN}.xml" \
                         --clear "${CLEARBOOL:-true}" \
                         --create "${CREATEBOOL:-true}" \
                         --execute "${EXECBOOL:-true}" \
                         --load "${LOADBOOL:-true}" \
			 || sleep 300

exit $?
