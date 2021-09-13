#!/bin/bash

set -e

[ -f /bin/ps ] && [ -f /bin/sed ] && [ -f /usr/bin/tee ] && [ -f /usr/bin/awk ] && [ -f /usr/bin/sort ] && [ -f /usr/bin/comm ]
[[ $? -ne 0 ]] && exit 1


old_pids_file="/home/sysadmin/pid_check/pids_old"
new_pids_file="/home/sysadmin/pid_check/pids_new"
temp_pids_file="/home/sysadmin/pid_check/pids_tmp"


old_pids_cmd_file="/home/sysadmin/pid_check/pids_cmd_old"
new_pids_cmd_file="/home/sysadmin/pid_check/pids_cmd_new"
temp_pids_cmd_file="/home/sysadmin/pid_check/pids_cmd_tmp"

log_file="/home/sysadmin/pid_check/pids_change.log"
trace_log_file="/home/sysadmin/pid_check/pids_change_trace.log"

#First time extracting pids
/bin/ps -o pid,cmd -e > ${new_pids_file}

#Removing the pid of script and ps command
/bin/sed "/ps/d" ${new_pids_file} | /usr/bin/tee ${old_pids_cmd_file} | /usr/bin/awk '{print $1}' > ${old_pids_file}

#Infinity loop with iteration of 1 second
#Comparing the old pids with new pids

while true
do
	echo "------$(date +%H-%M-%S)------" | /usr/bin/tee -a ${log_file} ${trace_log_file} > /dev/null
	/bin/ps -o pid,cmd -e > ${temp_pids_cmd_file}
	/bin/sed "/ps/d" ${temp_pids_cmd_file} | /usr/bin/tee ${new_pids_cmd_file} | /usr/bin/awk '{print $1}' > ${new_pids_file}
	echo -n "Changed pids:" >> ${log_file}
	/usr/bin/sort ${old_pids_file} -o ${old_pids_file}
	/usr/bin/sort ${new_pids_file} -o ${new_pids_file}
    /usr/bin/comm -3 --nocheck-order "${old_pids_file}" "${new_pids_file}" | /usr/bin/wc -l >> ${log_file}
	for i in $(/usr/bin/comm -13 --nocheck-order "${old_pids_file}" "${new_pids_file}") ; do echo -n "Spawned process -> " >> ${trace_log_file} ; grep "$i" ${new_pids_cmd_file} >> ${trace_log_file} ; done
	for i in $(/usr/bin/comm -23 --nocheck-order "${old_pids_file}" "${new_pids_file}") ; do echo -n "Dead process -> " >> ${trace_log_file} ; grep "$i" ${old_pids_cmd_file} >> ${trace_log_file} ; done
	/bin/mv "${new_pids_file}" "${old_pids_file}"
	/bin/mv "${new_pids_cmd_file}" "${old_pids_cmd_file}"
	/bin/sleep 1
done
