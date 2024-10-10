# 说明

用于构建生产环境中需要调试和性能追踪的java8镜像

## 基础镜像选择

openJDK官方镜像已于2022年停止维护, 各个版本的JDK镜像不再推送质量更新, 迁移到现有的活跃项目[eclipse-temurin](https://hub.docker.com/_/eclipse-temurin/)

### 版本选择

Eclipse Temurin 是一个由 Eclipse 基金会支持的高性能、可扩展的 Java 虚拟机（JVM）实现

选择eclipse-temurin:8u422-b05-jre-jammy镜像, 镜像大小约80MB左右

```plaintext
8u422-b05是最新的jdk8实现
jre/jdk可选
jammy是ubuntu版本代号, 对应2204, 还有noble(2404), ubi9-minimal(RH9)...可选
```

### 工具和附加组件

默认的eclipse-temurin精简版本的镜像中已经包含了`curl wget tar`等工具组件

构建两种类型的镜像

* prod
* dbg

两种镜像均可于生产环境:
prod镜像为精简的jre镜像, 适用于对性能有需求的生产环境, 提供最精简的镜像打包
dgb镜像在精简jre镜像中添加了便于调试的工具包 (tcping.sh \ nc、btop、vim、tcpdump、unzip) 、性能追踪工具 skywalking 和运维脚本库 scripts

同步构建amd64和arm64/v8双版本镜像

## 镜像分析工具

可使用官方自带的docker-inspect分析, 或者使用第三方工具`dive`
