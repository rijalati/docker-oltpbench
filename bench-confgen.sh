#!/usr/bin/env mksh
set -o pipefail

typeset -r WORKDIR="${ dirname "${0}"; }"
typeset -r WORKDIR_PATH="${ cd "${WORKDIR}" && pwd; }"
### DEBUGGING FLAGS
# set -n   # Uncomment to check script syntax, without execution.
#          # NB. Do not forget to put the above comment back in or
#          #       the shell script will not execute!
# Uncomment to debug this shell script
set -x
# 'verbose', displays input lines as they are read
set -v
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
             mariadb
             postgres
             db2
             oracle
             rac
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
-a <boolean> Accept Oracle OTN License (required for oracle & rac).

-d <database> Name of DB.

-n <port> Port DB is listening on.

-r <rate> Rate limit for workload.

-c <clients> number of clients that will be simulated connecting to the database.

-i <isolation> either: TRANSACTION_READ_COMMITED || TRANSACTION_SERIALIZABLE

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
    : typeset f="${fqdn}" \
    pn="${port}" \
    d="${database}" \
    u="${user}" \
    p="${pass}" \
    ty="${dbtype}" \
    tf="${tmpfile}" \
    t=$(mktemp) \
    od="${outdir}" \
    r="${rate:=unlimited}" \
    c="${clients:=10}" \
    i="${isolation:=TRANSACTION_READ_COMMITED}" \
    s="${scale:=100}"



    if [[ -z ${od} ]]; then
        : typeset o="my-templates/${f}.xml"
    else
        : typeset o="${od}/${f}.xml"
    fi

    cat "config-templates/dbs/${ty}.xml" | sed "s/|FQDN|/${f}/; s/|PORT|/${pn}/; s/|DB|/${d}/" > ${t}
    cat "config-templates/opts.xml" | sed "s/|USER|/${u}/; s/|PASS|/${p}/; s/|RATE|/${r}/; s/|CLIENTS|/${c}/" >> ${t}

    for b in ${bench[@]}; do
        print "\n<!-- partition -->\n" >> ${t}
        cat "config-templates/benchmarks/${b}.xml" \
            | sed "s/|SCALE|/${s}/; s/|ISOLATION|/${i}/" >> ${t}
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

    while getopts f:a:u:p:t:d:r:c:s:i:n:b:o: OPT; do
        case "${OPT}" in
        f )
            fqdn="${OPTARG}"
            ;;
        a )
            typeset -l ACCEPT_OTN_BOOL="${OPTARG}" # downcase this var
            export ACCEPT_OTN_BOOL
            ;;
        u )
            user="${OPTARG}"
            ;;
        p )
            pass="${OPTARG}"
            ;;
        t )
            typeset -u dbtype="${OPTARG}" # upcase whatever the user passes
            if [[ ${dbtype} == "ORACLE" || ${dbtype} == "RAC" ]]; then
                [[ ${ACCEPT_OTN_BOOL} == "true" ]] \
                    || { printf "You must set the 'ACCEPT_OTN_BOOL' variable to 'true'.\n" && exit 2; }
                ./ojdbc-get.sh
                mvn clean
                mvn package -P fixerrors
            elif [[ ${dbtype} == "DB2" ]]; then
                sed -i "s/|BASICAUTH|/${BASICAUTH}/" db2jcc4-get.sh
                cat db2jcc4-get.sh
                ./db2jcc4-get.sh
                ls -al lib
                mvn clean
                mvn -U org.apache.maven.plugins:maven-install-plugin:2.5.2:install-file \
                    -DlocalRepositoryPath=lib/repo \
                    -Dfile="${PWD}/lib/db2jcc4.jar" \
                    -DgroupId=com.ibm.db2.jcc \
                    -DartifactId=db2jcc4 \
                    -Dversion=4.23.42 \
                    -Dpackaging=jar \
                    -DgeneratePom=true | tee install.out
                mvn -U package -P fixerrors | tee package.out
            fi
            ;;
        d )
            database="${OPTARG}"
            ;;
        r )
            rate="${OPTARG}"
            ;;
        c )
            clients="${OPTARG}"
            ;;
        s )
            scale="${OPTARG}"
            ;;
        i )
            isolation="${OPTARG}"
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
