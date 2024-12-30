#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# 调用阿里云的API实现 OSS CDN 的强制缓存刷新
# 文档 https://api.aliyun.com/api/Cdn/2018-05-10/RefreshObjectCaches?RegionId=cn-hangzhou&tab=DEMO&lang=PYTHON&useCommon=true

import os
import sys

from typing import List

from alibabacloud_cdn20180510.client import Client as Cdn20180510Client
from alibabacloud_tea_openapi import models as open_api_models
from alibabacloud_cdn20180510 import models as cdn_20180510_models
from alibabacloud_tea_util import models as util_models
from alibabacloud_tea_util.client import Client as UtilClient

from dotenv import load_dotenv, find_dotenv

_ = load_dotenv(find_dotenv(".env"))  # 使用.env管理token


class Sample:
    def __init__(self):
        pass

    @staticmethod
    def create_client() -> Cdn20180510Client:
        """
        使用AK&SK初始化账号Client
        @return: Client
        @throws Exception
        """
        config = open_api_models.Config(
            access_key_id=os.environ["AccessKeyID"],
            access_key_secret=os.environ["AccessKeySecret"],
        )
        # Endpoint 请参考 https://api.aliyun.com/product/Cdn
        config.endpoint = f"cdn.aliyuncs.com"
        return Cdn20180510Client(config)

    @staticmethod
    def main(
        args: List[str],
    ) -> None:
        if len(args) < 2 or args[1] == "":
            print("域名不能为空")
            return

        print(args)
        domain = args[1]  # 获取传入的第一个域名
        client = Sample.create_client()
        refresh_object_caches_request = cdn_20180510_models.RefreshObjectCachesRequest(
            object_path=f"https://{domain}/"  # 动态使用传入的参数
        )
        runtime = util_models.RuntimeOptions()
        try:
            # 复制代码运行请自行打印 API 的返回值
            response = client.refresh_object_caches_with_options(
                refresh_object_caches_request, runtime
            )
            print("Refresh request submitted successfully:", response)
        except Exception as error:
            # 此处仅做打印展示，请谨慎对待异常处理，在工程项目中切勿直接忽略异常。
            # 错误 message
            print(error.message)
            # 诊断地址
            print(error.data.get("Recommend"))
            UtilClient.assert_as_string(error.message)


if __name__ == "__main__":
    # 刷新根目录下所有文件, 格式形如 http://www.example.com/ 完整说明参考示例文档
    # 默认Jenkins中域名形式为 www.example.com, 修改调用只刷新传入的第一条域名

    Sample.main(sys.argv)
