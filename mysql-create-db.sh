#!/bin/bash
## Author: Dung Pham
## Use: ./mysql-create-db $1 $2 $3
## With:
##      $1: database name
##      $2: database user
##      $3: database pass

EXPECTED_ARGS=3
E_BADARGS=65
MYSQL=`which mysql`

Q1="CREATE DATABASE IF NOT EXISTS $1;"
Q2="CREATE USER $2@localhost;"
Q3="SET PASSWORD FOR $2@localhost= PASSWORD("$3");"
Q4="GRANT ALL PRIVILEGES ON $1. * TO $2@localhost IDENTIFIED BY "$3";"
Q5="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}${Q3}${Q4}${Q5}"

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: $0 dbname dbuser dbpass"
  exit $E_BADARGS
fi

$MYSQL -uroot -p -e "$SQL"