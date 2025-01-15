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

1. Shell脚本

    * DiskIOBench.sh | Linux磁盘性能测试
    * GetAvailableK8sNodePorts.sh | 获取K8s节点的所有可用NodePorts
    * InstallDocker.sh | Linux安装Docker
    * LemonBench.sh | Linux跑分脚本
    * LinuxVMDataDiskAutoInitialize.sh | 初始化Linux磁盘
    * LinuxVMDiskAutoInitialize2.sh | 初始化Linux磁盘
    * LogCleanner.sh | 清理Linux服务器的日志文件
    * mysql_backup.sh | 结合Crontab计划任务使用MysqlDump进行数据库备份
    * OSInit.sh | 初始化多种发行版的Shell脚本
    * ppull.sh | proxy-pull, 连接到代理服务器并拉取Docker镜像
    * tcping.sh | 使用Bash内建的功能实现tcp连接性测试
    * rsync_nginx_config.sh | 用于监视和自动同步NGINX的配置文件到从节点

2. Python脚本

    * CoreFWRouteRulesOutput.ipynb | 读取华为USG6610E防火墙的的payload并导出为xlsx表格
    * EditAliDNS.py | 批量修改阿里云DNS解析记录
    * GiteeAPIQuery.py | 调用GiteeAPI查询企业仓库和仓库所属成员并导出为xlsx表格
    * RefreshAliOSSCaches.py | 调用阿里云API刷新域名所对应的OSS桶的CDN缓存
    * restart_nginx.py | 连接并重启NGINX服务器
