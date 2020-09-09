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
