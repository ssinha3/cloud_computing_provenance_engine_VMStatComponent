#!/bin/sh

process="vmware-vmx"
get_vals() {
    process=`echo $1`
    tmp_output=`ps aux | grep "${process}" | grep -v grep`
    tmp_top_output=`top -b -n 1 -p $1`
    if [ -z "$tmp_output" ]
    then
        echo "CRITICAL - Process is not running!"
        exit $ST_CR
    fi
    ps_user=`echo ${tmp_output} | awk '{print $1}'`
    ps_pid=`echo ${tmp_output} | awk '{print $2}' `
    ps_cpu=`echo ${tmp_output} | awk '{print $3}'`
    ps_mem=`echo ${tmp_output} | awk '{print $4}' `
    ps_start=`echo ${tmp_output} | awk '{print $9}' `
    tmp_ps_cputime=`echo ${tmp_output} | awk '{print $10}'`
    tmp_ps_cpuhours=`echo ${tmp_ps_cputime} | awk -F \: '{print $1}'`
    tmp_ps_cpumin=`echo ${tmp_ps_cputime} | awk -F \: '{print $2}'`
    ps_cputime=`echo "scale=0; (${tmp_ps_cpuhours} * 60) + ${tmp_ps_cpumin}" | bc -l`
    #output="Process: ${process}, User: ${ps_user}, CPU: ${ps_cpu}%,RAM: ${ps_mem}%, Start: ${ps_start}, CPU Time: ${ps_cputime} min" perfdata="'cpu'=${ps_cpu} 'memory'=${ps_mem} 'cputime'=${ps_cputime}"
    top_1=`echo ${tmp_top_output} | awk '{print $40}'`
    top_2=`echo ${tmp_top_output} | awk '{print $38}'`
    top_3=`echo ${tmp_top_output} | awk '{print $36}'`

    snapshot_date_time=`echo -n "$(date +%Y%m%d-%T)"`
    #echo "${snapshot_date_time}: Statistic - ${output} | ${perfdata}"
    #echo "${snapshot_date_time}: Memory - Free: ${top_1}, Used: ${top_2}, Total: ${top_3}"
    ps_vmname=`echo ${tmp_output} | awk '{print $22 "\t" }' | sed -e 's/\///g' | sed -e 's/.*\(vm[0-9]\).*/\1/'`

        if [[ "$ps_vmname" =~ "managementnode" ]]; then
                ps_vmname=`echo "Managementnode"`
        fi

    #echo "---Summary for VM ${ps_vmname} at ${snapshot_date_time}---" >> /tmp/statistic.log.$(date +"%F")
    output_summary="${snapshot_date_time} VM Name: ${ps_vmname} CPU(%): ${ps_cpu}% Mem(%): ${ps_mem}% PID: ${process} VM Start Time: ${ps_start} CPU Time: ${ps_cputime} min"
    echo "${output_summary}" >> /tmp/statistic.log.$(date +"%F")

}
ps aux | grep "vmware-vmx" | grep -v grep | for i in `awk {'print$2'}`; do get_vals $i ;done;

exit 0;
