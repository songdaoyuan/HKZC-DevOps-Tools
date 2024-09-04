#!/bin/bash

# code by songdaoyuan@20240904
# 用于将Java后端程序打包成docker镜像并且构建compose文件
# 模板脚本, 按需修改变量

set -exu

# 配置镜像构建的信息
ENV=prod
TARGET=NAME.jar
JOB_NAME=NAME.jar
IMAGE_NAME=NAME
BUILD_NUMBER=1

# 基础镜像和harbor的分支
# 基础镜像-ARM架构的JDK8基础镜像
IMAGE_BRANCH=xm
BASE_IMAGE=harbor.hysz.co/xm/openjdk8-arm64:v1

# 定义服务器基本信息(主NG和应用服务器)
APP_SERVER=192.168.62.164

NGINX_MASTER=192.168.62.164
NGINX_WEB=10.193.200.136

# 创建Dockerfile
cat <<EOF >Dockerfile
FROM  $BASE_IMAGE

LABEL org.opencontainers.image.authors="songdaoyuan@focus-in.cn"

WORKDIR /project

COPY $TARGET $JOB_NAME.jar

CMD java -server -Xms1g -Xmx2g -Dserver.port=8080 -jar $JOB_NAME.jar --spring.profiles.active=$ENV

EXPOSE 8080

EOF

# 构建并推送镜像
docker build -t harbor.hysz.co/$IMAGE_BRANCH/$IMAGE_NAME:v$BUILD_NUMBER .
docker push harbor.hysz.co/$IMAGE_BRANCH/$IMAGE_NAME:v$BUILD_NUMBER
docker rmi harbor.hysz.co/$IMAGE_BRANCH/$IMAGE_NAME:v$BUILD_NUMBER

# 构建docker-compose.yaml
cat <<EOF >docker-compose.yaml
version: "2"
services:
  $IMAGE_NAME:
    image: harbor.hysz.co/$IMAGE_BRANCH/$IMAGE_NAME:v$BUILD_NUMBER
    container_name: $IMAGE_NAME
    network_mode: host
    restart: always
    ports:
      - "$SERVER_PORT:8080"
    volumes:
      - "/var/logs/focusin-log/$ENV:/var/logs/focusin/"
EOF

ssh root@$APP_SERVER \
    "cd /home/project/$ENV/$JOB_NAME/ && \
    docker-compose down && \
    docker-compose up -d"
