#!/bin/sh

# wrapper script for cloud_sql_proxy program

# This script is written with the following assumptions:
#
#   - ONLY connecting to a single Google CloudSQL instance.
#   - ONLY utilizing service account authentication

MISSING=""
version=0
help=0
CLOUDSQL_PROXY_CMD="/cloud_sql_proxy"

# default to unlimited conns
CLOUDSQL_MAXCONNS=${CLOUDSQL_MAXCONNS-0}

# default to specified path
CLOUDSQL_CREDENTIAL_FILE=${CLOUDSQL_CREDENTIAL_FILE-"/etc/sqlproxy-service-account.json"}

# default to verbose logging
CLOUDSQL_LOGGING=${CLOUDSQL_LOGGING-"-verbose"}

# check if command line flag were passed
if [ $# -gt 0 ]
then
   for arg in $@
   do
      # only support these flags
      case $arg in
        "-version") version=1
            ;;
        "-h") help=1
            ;;
      esac
   done
fi

if [ $version -eq 1 ]
then
   # output cloudsql proxy version
   ${CLOUDSQL_PROXY_CMD} -version
   echo
fi

if [ $help -eq 1 ]
then
   echo "Usage statement"

   exit 1
fi
   

# validate required vars are set

if [ -z "${GOOGLE_PROJECT}" ]
then
   MISSING="GOOGLE_PROJECT ${MISSING}"
fi

if [ -z "${CLOUDSQL_ZONE}" ]
then
   MISSING="CLOUDSQL_ZONE ${MISSING}"
fi

if [ -z "${CLOUDSQL_INSTANCE}" ]
then
   MISSING="CLOUDSQL_INSTANCE ${MISSING}"
fi

if [ ! -z "${MISSING}" ]
then
   echo "The following REQUIRED environment variables were NOT set:"
   echo
   for miss in ${MISSING}
   do
      case $miss in 
        "GOOGLE_PROJECT") echo "  GOOGLE_PROJECT: Google project name that CloudSQL instance resides"
          ;;
        "CLOUDSQL_ZONE") echo "  CLOUDSQL_ZONE: Google zone that instance resides in (us-central1-a, us-east1-b,..."
          ;;
        "CLOUDSQL_INSTANCE") echo "  CLOUDSQL_INSTANCE: Specific name of the CLoudSQL instance"
          ;;
      esac 
   done
   echo ; echo "Exitting!"
   exit 1
fi

exec ${CLOUDSQL_PROXY_CMD}  -instances=${GOOGLE_PROJECT}:${CLOUDSQL_ZONE}:${CLOUDSQL_INSTANCE}=tcp:0.0.0.0:3306 -max_connections=${CLOUDSQL_MAXCONNS} -credential_file=${CLOUDSQL_CREDENTIAL_FILE} ${CLOUDSQL_LOGGING}