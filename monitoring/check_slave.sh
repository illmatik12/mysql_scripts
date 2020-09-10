#!/bin/bash
while true;
do
clear
mysql -e 'SHOW SLAVE STATUS\G' | egrep "Master_Log_Pos|Running|Last|Seconds"
sleep 3 
done