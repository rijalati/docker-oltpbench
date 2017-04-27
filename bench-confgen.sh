#!/usr/bin/env mksh
set -o pipefail

typeset -r WORKDIR="${ dirname "${0}"; }"
typeset -r WORKDIR_PATH="${ cd "${WORKDIR}" && pwd; }"
### DEBUGGING FLAGS
# set -n   # Uncomment to check script syntax, without execution.
#          # NB. Do not forget to put the above comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script
# set -v   # 'verbose', displays input lines as they are read

# DBGTRAP='print " file: ${.sh.file} cmd: "${.sh.command}" line: ${.sh.lineno} \n \
#    shlvl: ${.sh.level} subshlvl: ${.sh.subshlevel} func: ${.sh.fun} exit: $? "'

# uncomment the following line to print detailed info on every line as it is run
# trap "${DBGTRAP}" DEBUG

# Make sure all math stuff runs in the "C" locale to avoid problems
# with alternative # radix point representations (e.g. ',' instead of
# '.' in de_DE.*-locales). This needs to be set _before_ any
# floating-point constants are defined in this script).
if [[ "${LC_ALL-}" != '' ]] ; then
    export \
        LC_MONETARY="${LC_ALL}" \
        LC_MESSAGES="${LC_ALL}" \
        LC_COLLATE="${LC_ALL}" \
        LC_CTYPE="${LC_ALL}"
    unset LC_ALL
fi
export LC_NUMERIC='C'

### FILES AND VARIABLES
typeset -r progname="${ basename "${0}"; }"

function usage
{

    BOLD="\e[1m"
    NORM="\e[0m"

    cat <<EOF
${ print "${BOLD}NAME${NORM}"; }
  ${progname} - generates configuration files for use with oltpbench.

${ print "${BOLD}DESCRIPTION${NORM}"; }
  ${progname}is a small utility which creates a config
  file for use with oltpbench. It only creates them for one database at a
  time, adding the necessary info to run the user specified benchmarks.

${ print "${BOLD}OPTIONS${NORM}"; }
-f <fqdn> FQDN of the database host.

-u <user> Username to use for connecting to DB.

-p <pass> Password for the user.

-t <dbtype> Type of database being targeted (those indicated with a '*' need
            config templates to be added):
             mysql
             postgres
             db2
             oracle
             sqlserver
             sqlite*
             hstore*
             hsqldb*
             h2*
             monetdb
             nuodb*
             timesten*
             amazonrds*
             sqlazure*

-b <bench> Type of benchmark to configure. Can be a comma separated list, with no spaces:
           tpcc
           tpch
           chbenchmark
           auctionmark
           epinions
           jpab
           resourcestresser
           seats
           tatp
           twitter
           wiki
           ycsb
           voter
           linkbench
           sibench

-d <database> Name of DB.

-n <port> Port DB is listening on.

${ print "${BOLD}IMPLEMENTATION${NORM}"; }
  version         ${progname} (Blue Medora Inc.) v1.0
  author          Ritchie J Latimore <ritchie.latimore@bluemedora.com>
  copyright       Copyright (c) 2016 Blue Medora Inc.

EOF

    exit 2
}

### TRAPS

trap 'print "\n${progname} has finished\n"' EXIT

### FUNCTIONS

function fatal_error
{
    print -u2 -n "${progname}: "
    print -u2 -f %q "$@"
    exit 1
}

# Generate a config file with the user specified values
function genconf
{
    typeset f=${fqdn}
    typeset pn=${port}
    typeset d=${database}
    typeset u=${user}
    typeset p=${pass}
    typeset ty=${dbtype}
    typeset tf=${tmpfile}
    typeset t=$(mktemp)
    typeset od=${outdir}

    if [[ -z ${od} ]]; then
        eval typeset o="my-templates/${f}.xml"
    else
        eval typeset o="${od}/${f}.xml"
    fi

    cat "config-templates/dbs/${ty}.xml" | sed "s/|FQDN|/${f}/; s/|PORT|/${pn}/; s/|DB|/${d}/" > ${t}
    cat "config-templates/opts.xml" | sed "s/|USER|/${u}/; s/|PASS|/${p}/" >> ${t}

    for b in ${bench[@]}; do
        print "\n<!-- partition -->\n" >> ${t}
        cat "config-templates/benchmarks/${b}.xml" >> ${t}
    done

    printf "\n</parameters>\n" >> ${t}

    cp "${t}" "${o}" && rm "${t}"

    return 0
}

function main
{

    set -a
    typeset -a all_benches
    all_benches+=(
        tpcc
        tpch
        chbenchmark
        auctionmark
        epinions
        jpab
        resourcestresser
        seats
        tatp
        twitter
        wiki
        ycsb
        voter
        linkbench
        sibench
    )
    typeset -a bench
    bench=( ${bench:=${all_benches[@]}} )

    (( $# == 0 )) && usage

    while getopts f:u:p:t:d:n:b:o: OPT; do
        case "${OPT}" in
            f )
                fqdn="${OPTARG}"
                ;;
            u )
                user="${OPTARG}"
                ;;
            p )
                pass="${OPTARG}"
                ;;
            t )
                dbtype="${OPTARG}"
		typeset -u typechk
		typechk="${dbtype}"
                if [[ ${typechk} == "ORACLE" ]]; then
                    ./ojdbc-get.sh
                else
                    :
                fi

                ;;
            d )
                database="${OPTARG}"
                ;;
            n )
                port="${OPTARG}"
                ;;
            b )
                if [[ -z ${OPTARG} ]]; then
                    eval :
                else
                    unset bench
                    IFS=,
                    bench=( ${OPTARG} )
                    unset IFS
                fi
                ;;
            o )
                outdir="${OPTARG}"
                ;;
            * )
                usage
                ;;
        esac
    done

    genconf

    return 0

}

### PROGRAM START

main "$@"
exit $?

# EOF.
