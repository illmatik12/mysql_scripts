#!/bin/bash
#limit=80
limit=20

while true
do

mem_free=`free | grep Mem | awk '{print $4/$2 * 100}'`
st=`echo "$mem_free < $limit" | bc`

if [ $st -eq 1 ]; then
        date=`date +"%Y-%m-%d %H:%M:%S"`
        echo "Mem Free : $mem_free "
        status=`ps -eo user,pid,ppid,rsz,vsz,pmem,pcpu,time,cmd | grep mysqld | grep -v grep`
        echo "${date} ${status}"

        process=`mysql -uroot -ppassword-e "show processlist"`
        mem_status=`mysql -uroot -ppassword -e "show global status like 'mem%';"`


        echo "################  ${date} ####################"
        echo "${process}"
        echo "* memory usage "
        echo "${mem_status}  "
        echo "#################################################"

fi
sleep 5
done