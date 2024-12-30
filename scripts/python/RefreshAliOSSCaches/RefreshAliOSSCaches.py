# -*- coding: utf-8 -*-
# 调用阿里云的API实现 OSS CDN 的强制缓存刷新
import os
import sys

from typing import List

from alibabacloud_cdn20180510.client import Client as Cdn20180510Client
from alibabacloud_tea_openapi import models as open_api_models
from alibabacloud_cdn20180510 import models as cdn_20180510_models
from alibabacloud_tea_util import models as util_models
from alibabacloud_tea_util.client import Client as UtilClient

from dotenv import load_dotenv, find_dotenv
_ = load_dotenv(find_dotenv(".env"))        # 使用.env管理token

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
        # 工程代码泄露可能会导致 AccessKey 泄露，并威胁账号下所有资源的安全性。以下代码示例仅供参考。
        # 建议使用更安全的 STS 方式，更多鉴权访问方式请参见：https://help.aliyun.com/document_detail/378659.html。
        config = open_api_models.Config(
            access_key_id=os.environ['AccessKeyID'],
            access_key_secret=os.environ['AccessKeySecret']
        )
        # Endpoint 请参考 https://api.aliyun.com/product/Cdn
        config.endpoint = f'cdn.aliyuncs.com'
        return Cdn20180510Client(config)

    @staticmethod
    def main(
        args: List[str],
    ) -> None:
        client = Sample.create_client()
        refresh_object_caches_request = cdn_20180510_models.RefreshObjectCachesRequest(
            object_path='https://dgp-h5.hysz.co/'
        )
        runtime = util_models.RuntimeOptions()
        try:
            # 复制代码运行请自行打印 API 的返回值
            client.refresh_object_caches_with_options(refresh_object_caches_request, runtime)
        except Exception as error:
            # 此处仅做打印展示，请谨慎对待异常处理，在工程项目中切勿直接忽略异常。
            # 错误 message
            print(error.message)
            # 诊断地址
            print(error.data.get("Recommend"))
            UtilClient.assert_as_string(error.message)

    @staticmethod
    async def main_async(
        args: List[str],
    ) -> None:
        client = Sample.create_client()
        refresh_object_caches_request = cdn_20180510_models.RefreshObjectCachesRequest(
            object_path='http://foo.bar/'      # 示例的域名格式, 由于域名不存在会触发API的异常
        )
        runtime = util_models.RuntimeOptions()
        try:
            # 复制代码运行请自行打印 API 的返回值
            await client.refresh_object_caches_with_options_async(refresh_object_caches_request, runtime)
        except Exception as error:
            # 此处仅做打印展示，请谨慎对待异常处理，在工程项目中切勿直接忽略异常。
            # 错误 message
            print(error.message)
            # 诊断地址
            print(error.data.get("Recommend"))
            UtilClient.assert_as_string(error.message)


if __name__ == '__main__':
    # 刷新根目录下所有文件：http://example.com/
    # 默认Jenkins中域名形式为 a.hysz.co
    # 一次只刷新一条 URL 的缓存
    Sample.main([f"https://{sys.argv[1]}/"])