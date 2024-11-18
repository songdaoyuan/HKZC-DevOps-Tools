#!/bin/bash

# 用于连接到镜像代理服务器然后远程拉取镜像
# code by songdaoyuan@20240801
# 使用方式
# rpull $IMAGE_NAME_VERSION

# ToDo 增加镜像存在性校验

set -exu

# 定义基本信息(代理服务器)
MIRROR_SERVER=172.28.12.252
IMAGE_NAME_VERSION=$1 # 获取传入的镜像名和版本

echo "第一次使用时, 确保你已经配置了${MIRROR_SERVER}的SSH免密登录"
ssh root@$MIRROR_SERVER "docker pull $IMAGE_NAME_VERSION" && echo "remote docker pull successfully" || echo "remote docker pull failed"
ssh root@$MIRROR_SERVER "docker tag $IMAGE_NAME_VERSION dev-harbor.hysz.co/swap/$IMAGE_NAME_VERSION"
ssh root@$MIRROR_SERVER "docker push dev-harbor.hysz.co/swap/$IMAGE_NAME_VERSION"
ssh root@$MIRROR_SERVER "docker rmi dev-harbor.hysz.co/swap/$IMAGE_NAME_VERSION"

docker pull dev-harbor.hysz.co/swap/$IMAGE_NAME_VERSION && echo "local docker pull successfully" || echo "local docker pull failed"
