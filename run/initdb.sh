#/bin/bash

if [ -n "$dbname" ]; then
  dbname=$1
  shift
else
  dbname=tpcc
fi
echo creating database $dbname
mysql -uroot $@ -e "create database if not exists $dbname"
mysql -uroot $@ -e "create user if not exists test identified with 'mysql_native_password' by 'test1234'"
mysql -uroot $@ -e "grant all privileges on $dbname.* to 'test'@'%'"
