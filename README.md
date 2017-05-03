# oltpbench
Dockerfile and scripts to auto generate configs and run oltpbench against RDBMS and (a couple) NoSQL systems

## Getting Started

This image is designed to streamline the configuration and running of the oltpbench benchmarking tool. To this end it comes with a some convenience scripts: 

`bench-confgen.sh` -- generates configuration files for oltpbench using the templates under the `config-templates/` folder.

`loadstarter.sh` -- for (more) easily running the image on docker directly, i.e. without a container orchestration tool like Rancher or Kubernetes.

`ojdbc-get.sh` -- sets up Oracle's maven repository and downloads their jdbc drivers (Oracle Maven login required).


### Supported Environment Variables

`DBFQDN` -- fully qualified domain name of the database under test (DUT).

`DBUSER` -- username for DUT.

`DBPASS` -- password for above user.

`DBTYPE` -- type of database being tested (required for config generation), currently supported options are:

```
           mysql
           mariadb (uses the mariadb jdbc driver)
           postgres
           db2
           oracle
           sqlserver
```

`DBNAME` -- database to connect to.

`DBPORT` -- port the DUT is listening on.

`BENCH` -- which benchmark to run against the DUT, currently supported options:

```
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
```

**All `*BOOL` vars only accept true or false**

`CREATEBOOL` -- toggle database creation

`CLEARBOOL` -- toggle clearing the database

`EXECBOOL` -- toggle benchmark execution, in case you just want to populate the database and examine the dataset w/o running the benchmark.

`LOADBOOL` -- toggle database loading phase, can be useful if you want to reuse a previously populated database.

**The following vars are only used if `DBTYPE` is set to 'oracle', in which case they are required**

`MVN_PASS` -- used to generate encrypted maven master password.

`ORACLEMVN_USER` -- username used to login to oracle maven repo, you may have to register your Oracle login for this, [more info](http://www.oracle.com/webfolder/application/maven/index.html)

`ORACLEMVN_PASS` -- password for the above username, used to generate a maven encrypted password that is actually written to the settings.xml file. 


