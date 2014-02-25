#!/bin/sh
ssh -o StrictHostKeyChecking=no -o LogLevel=quiet root@vmhost1 'bash -s' < check_top_ps.sh
scp -o StrictHostKeyChecking=no -o LogLevel=quiet root@vmhost1:/tmp/statistic.log.$(date +"%F") /tmp/temp_statistic.log
cat /tmp/temp_statistic.log >> /tmp/statistic.log.$(date +"%F")
perl load_db_statistic.pl "/tmp/temp_statistic.log"
rm -f /tmp/temp_statistic.log
ssh -o StrictHostKeyChecking=no -o LogLevel=quiet root@vmhost1 "find /tmp/statistic.log.* -type f -exec rm -f {} \;"
