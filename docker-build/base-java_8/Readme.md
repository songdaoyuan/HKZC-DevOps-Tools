# 说明

用于构建生产环境中需要调试和性能追踪的java8镜像

## 基础镜像选择

openJDK官方镜像已于2022年停止维护, 各个版本的JDK镜像不再推送质量更新, 迁移到现有的活跃项目[eclipse-temurin](https://hub.docker.com/_/eclipse-temurin/)

### 版本选择

Eclipse Temurin 是一个由 Eclipse 基金会支持的高性能、可扩展的 Java 虚拟机（JVM）实现

* 拥有改进的即时编译器 JIT 和垃圾收集器 GC , 提供高性能的 Java 执行环境
* Eclipse Temurin 提供长期支持版本, 适合需要长期稳定运行的企业应用
* 定期发布安全更新, 帮助保护企业应用免受安全威胁
* 与 Java SE 标准保持高度兼容

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

dgb镜像在精简jre镜像中添加了便于调试的工具包 (netcat、btop、vim、tcpdump、unzip) 、性能追踪工具 skywalking 和运维脚本库 scripts (tcping.sh \ aliyun-arthas.sh)

同步更新glibc版本以适配openCV的需求

启用中文语言包

同步构建amd64和arm64/v8双版本镜像

## 镜像分析工具

可使用官方自带的docker-inspect分析, 或者使用第三方工具`dive`

## 更新历史

20241001 初版镜像制作完成
20250306 移除skywalking、配置了完整中文语言支持和中国时区、修复了GLIBC链接、新增了阿里云arthas分析工具
20250312 在构建过程中新镇了额外的字体文件
Next 计划新增[posting](https://github.com/darrenburns/posting)工具...
