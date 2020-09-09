#!/bin/bash

MHA_GLOBAL_CONF_FILE=
MHA_CONF_FILE=/etc/masterha/app1.conf
MHA_LOG_FILE=/var/log/mha.log 

echo "================================================================="
echo "== Masterha Global Config File : "${MHA_GLOBAL_CONF_FILE}
echo "== Masterha Config Fileh : "${MHA_CONF_FILE}
echo "== Masterha Log File : "${MHA_LOG_FILE}
echo "================================================================="

#nohup masterha_manager --global_conf=${ } --conf=${} --ignore_fail_on_start --ignore_last_failover < /dev/null > ${MHA_LOG_FILE} 2 > &1 & 
nohup masterha_manager --conf=${MHA_CONF_FILE} --ignore_fail_on_start --ignore_last_failover < /dev/null > ${MHA_LOG_FILE} 2>&1 & 
[root@DEV-LCPT-MHA01 ~]# cat mha_check_repl.sh
#!/bin/bash

MHA_GLOBAL_CONF_FILE=
MHA_CONF_FILE=/etc/masterha/app1.conf
MHA_LOG_FILE=/var/log/mha.log 

#echo "================================================================="
#echo "== Masterha Global Config File : "${MHA_GLOBAL_CONF_FILE}
#echo "== Masterha Config File : "${MHA_CONF_FILE}
#echo "== Masterha Log File : "${MHA_LOG_FILE}
#echo "================================================================="

masterha_check_repl --conf=${MHA_CONF_FILE} 
