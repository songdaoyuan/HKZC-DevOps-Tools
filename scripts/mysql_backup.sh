#!/bin/bash
time=`date +%Y_%m_%d`
mkdir -p /data/mysql_backup/
log_file=/home/shell/mysql_backup.log
echo $time >> $log_file
find /data/mysql_backup/ -name '*' -mtime +7 |xargs rm -rf
mysqldump -uroot -p PASSWORT -h mysql.domain.com  --all-databases -E -R --single-transaction|gzip > /data/mysql_backup/test_mysql_backup_$time.sql.gz
[ $? -gt 0 ] && echo "数据库备份失败" >>$log_file || echo "数据库备份成功" >>$log_file
sleep 60