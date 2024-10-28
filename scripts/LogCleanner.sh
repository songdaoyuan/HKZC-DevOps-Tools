#!/bin/bash
set -exu

# code by songdaoyuan@20241028 
# 清理Linux的日志文件

# 1. 清理未使用的 Docker 镜像、容器、网络和数据卷
# docker system prune -a

# 2. 清理 HKZC Java APP 日志

cd /var/logs/focusin || exit

find . -type f ! -name "*.$(date +%Y)-$(date +%m)-$(date +%d).log" -delete

# 3. 清理 常规的 log 日志

cd /var/log || exit

rm -rf boot.log-* btmp-* cron-* maillog-* messages-* secure-* spooler-* yum.log-*

cd journal || exit

find . -type f ! -name "system.journal" -delete

## 3.1 清理阿里云的各种日志

find /var/log/alicloud -type f -name "cnfs.alibabacloud.com-*" -delete
find /var/log/alicloud -type f -name "csi_connector.log-*" -delete
find /var/log/alicloud -type f -name "monitoring.storage.alibabacloud.com.log-*" -delete
find /var/log/alicloud -type f -name "plugin.csi.alibabacloud.com.log-*" -delete
find /var/log/alicloud -type f -name "provisioner.csi.alibabacloud.com.log-*" -delete
find /var/log/alicloud -type f -name "storage.autoscaler.alibabacloud.com.log-*" -delete