# oltpbench
Dockerfile and scripts to auto generate configs and run oltpbench against several types of RDBMS.

## Tools

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

`DBNAME` -- name of database to connect to.

`DBPORT` -- port the DUT is listening on.

`RATE` -- rate limit for the benchmark. (defaults to unlimited)

`CLIENTS` -- the number of clients you would like to simulate connecting to the DUT. (defaults to 10)

`SCALE` -- size of the dataset generated for the benchmark being run, what this means varies per benchmark (defaults to 100):

```
tpcc -- number of warehouses in TPCC
tpch
tatp -- number of subscribers
wikipedia -- the number of wikipages *1000
resourcestresser -- scales by *100 the number of employees
twitter -- scales by *500 the number of users
epinions -- scales by *2000 the number of users
ycsb --  *1000 the number of rows in the USERTABLE
jpab -- Number of Initial Objects
seats -- scales by *1000 the number of customers
auctionmark -- scales by *1000 the number of customers
chbenchmark
voter
linkbench -- scale is ignored in LinkBench for now, to be replaced by max_id
sibench
noop
smallbank
hyadapt
```


`ISOLATION` -- the transaction isolation level to be used for the benchmark, one of (defaults to TRANSACTION_READ_COMMITED):

```
TRANSACTION_REPEATABLE_READ
TRANSACTION_READ_COMMITTED
TRANSACTION_SERIALIZABLE
```


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


