# 在MacBook上部署和运行基于离线LLM和Dify的个人知识库

## 安装git工具

按下`command键`+`空格`键，输入`teminal`呼出终端，在终端中输入`git`命令启用并下载开发者工具
![alt text](0x00.安装git.png)

## 为网络配置代理

在局域网内机器上部署了代理加速服务，将此台电脑的流量转发到局域网机器中

![alt text](0x01.为Mac配置代理.png)

## 安装Docker和docker-compose

[下载](https://www.docker.com)适用于`Apple Silicon`的`Docker Desktop`

![alt text](0x02.下载Docker环境.png)

安装完成后使用默认设置初始化配置Docker桌面APP

受限于现有Docker相关政策，**需要登录Docker账号**才能高速下载`docker hub`的镜像，使用`foo@focus-in.cn`邮箱登录

配置Docker APP的开机自启动

![alt text](0x03.校验Docker环境.png)

## 拉取最新的Dify源码并启动容器服务

```Bash
cd ~ && mkdir App && cd App
pwd
# /Users/jw/App

# 拉取最新的Dify源码，此时版本为1.3.0
git clone https://github.com/langgenius/dify.git
```