# HKZC-DevOps-Tools

## 介绍

用于存放公共的运维脚本或者依赖资源，解决通用的部署问题

## 文件夹说明

* Docker: 存放部署docker-ce相关的脚本和依赖文件
* docker-build: 存放自主构建的docker镜像模板
* docker-compose.yml: 存放一些中间件或者工具的docker-compose模板
* sql: 存放一些中间件或者工具的SQL初始化脚本
* LinuxBench: 存放一些Linux性能测试工具

## 脚本列表和说明

* DiskIOBench.sh
* GetAvailableK8sNodePorts.sh
* InstallDocker.sh
* LemonBench.sh
* LinuxVMDataDiskAutoInitialize.sh
* LinuxVMDiskAutoInitialize2.sh
* OSInit.sh
* rdocker.sh
* tcping.sh
* rpull.sh | 一个借助代理服务器拉取docker image的脚本
* mysql_backup.sh | 一个结合crontab计划任务使用mysqldump进行数据库备份的脚本
* EditAliDNS.py | 一个快速批量修改阿里云DNS解析记录的脚本
