#!/usr/bin/bash
#ip addr add 10.238.191.214/24 dev ens192 label ens192:1;arping -c3 -D -I ens192 -s 10.238.191.214 10.238.191.21

vip_start='ip addr add 10.238.191.238/24 dev ens192 label ens192:1;arping -c3 -D -I ens192 -s 10.238.191.238 10.238.191.238'

ping_result=`ping 10.238.191.238 -c 3`
#ping_result=`ping 10.238.191.231 -c 3`

status=$?

check_interface=`ifconfig -a | grep ens192:1 | wc -l`

check_mysql=`ps -ef | grep mysqld | grep -v grep | wc -l`

check_slave=`mysql -uroot -p'ldccm2020!@#' -e "show slave status;" | wc -l`


echo $check_slave
if [ $check_mysql -ne 1 ] ; then
        echo -e "Mysql Not Running."
        exit
fi

if [ $check_slave -ne 0 ] ; then
        echo -e "MySQL runnig slave host. "
        exit
fi

if [ $status -eq 0 ]  ||  [ $check_interface -eq 1 ] ; then 
        echo "vip already up"
else
        echo "vip not set"
        ip addr add 10.238.191.238/24 dev ens192 label ens192:1;arping -c3 -D -I ens192 -s 10.238.191.238 10.238.191.238
fi