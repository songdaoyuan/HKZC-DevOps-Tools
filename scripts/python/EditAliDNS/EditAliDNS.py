from aliyunsdkcore.client import AcsClient
from aliyunsdkalidns.request.v20150109.DescribeDomainRecordsRequest import (
    DescribeDomainRecordsRequest,
)
from aliyunsdkalidns.request.v20150109.UpdateDomainRecordRequest import (
    UpdateDomainRecordRequest,
)
from aliyunsdkalidns.request.v20150109.AddDomainRecordRequest import (
    AddDomainRecordRequest,
)

import pandas as pd

import json
import os
import time

from datetime import datetime, timedelta

"""
code by songdaoyuan@2024.12.11

通过读取阿里云格式的excel解析表格来批量修改域名的DNS解析
pd.read_excel("dev_dns_records.xlsx")

在开始之前, 需要安装依赖
aliyun-python-sdk-core-v3, aliyun-python-sdk-alidns, pandas, openpyxl

然后在.env文件中配置ACCESS_KEY_ID、ACCESS_KEY_SECRET、DOMAIN_NAME
"""

from dotenv import load_dotenv, find_dotenv

_ = load_dotenv(find_dotenv(".env"))


class AliyunDNS:
    def __init__(
        self, access_key_id, access_key_secret, domain_name, cache_file="log.json"
    ):
        self.client = AcsClient(access_key_id, access_key_secret, "cn-hangzhou")
        self.domain_name = domain_name
        self.cache_file = cache_file

    def _is_cache_valid(self):
        """检查本地缓存文件是否存在且在一天内更新"""
        if not os.path.exists(self.cache_file):
            return False

        try:
            # 检查缓存文件的修改时间
            file_mod_time = datetime.fromtimestamp(os.path.getmtime(self.cache_file))
            if datetime.now() - file_mod_time > timedelta(days=1):  # 超过一天则无效
                return False

            # 检查缓存内容是否非空且格式正确
            with open(self.cache_file, "r", encoding="UTF-8") as f:
                data = json.load(f)
                if data and isinstance(data, list):  # 确保内容是非空列表
                    return True
        except Exception as e:
            print(f"检查缓存文件失败：{str(e)}")
            return False

        return False

    def _load_cache(self):
        """从本地缓存文件中读取记录"""
        try:
            with open(self.cache_file, "r", encoding="UTF-8") as f:
                return json.load(f)
        except Exception as e:
            print(f"读取缓存文件失败：{str(e)}")
            return []

    def _save_cache(self, records):
        """将解析记录保存到本地缓存文件"""
        try:
            with open(self.cache_file, "w", encoding="UTF-8") as f:
                json.dump(records, f, ensure_ascii=False, indent=4)
        except Exception as e:
            print(f"保存缓存文件失败：{str(e)}")

    def get_domain_records(self):
        """获取域名解析记录(支持分页获取所有记录, 支持读取缓存)"""
        # 检查缓存是否有效
        if self._is_cache_valid():
            print("使用本地缓存的解析记录")
            return self._load_cache()

        print("缓存无效, 调用阿里云API获取解析记录")

        request = DescribeDomainRecordsRequest()
        request.set_accept_format("json")
        request.set_DomainName(self.domain_name)

        all_records = []  # 用于存储所有解析记录
        page_number = 1
        page_size = 200  # 每页返回的最大记录数, 可选100-500

        while True:
            request.set_PageNumber(page_number)
            request.set_PageSize(page_size)

            # 降速
            time.sleep(1)

            try:
                response = self.client.do_action_with_exception(request)
                data = json.loads(response)

                # 获取当前页的记录
                records = data["DomainRecords"]["Record"]
                all_records.extend(records)

                # 检查是否还有下一页
                total_count = data["TotalCount"]
                if page_number * page_size >= total_count:
                    break

                page_number += 1  # 获取下一页
            except Exception as e:
                print(f"获取解析记录失败：{str(e)}")
                return []

        print(f"共获取到 {len(all_records)} 条解析记录")

        # 保存到本地缓存
        self._save_cache(all_records)

        return all_records

    def update_domain_record(self, record_id, rr, record_type, value):
        """更新域名解析记录"""
        request = UpdateDomainRecordRequest()
        request.set_accept_format("json")

        request.set_RecordId(record_id)
        request.set_RR(rr)  # 主机记录
        request.set_Type(record_type)  # 记录类型
        request.set_Value(value)  # 记录值

        try:
            response = self.client.do_action_with_exception(request)
            print(f"更新解析记录成功：{rr}.{self.domain_name}")
            return True
        except Exception as e:
            print(f"更新解析记录失败：{str(e)}")
            return False

    def add_domain_record(self, rr, record_type, value):
        """添加域名解析记录"""
        request = AddDomainRecordRequest()
        request.set_accept_format("json")

        request.set_DomainName(self.domain_name)
        request.set_RR(rr)
        request.set_Type(record_type)
        request.set_Value(value)

        try:
            response = self.client.do_action_with_exception(request)
            print(f"添加解析记录成功：{rr}.{self.domain_name}")
            return True
        except Exception as e:
            print(f"添加解析记录失败：{str(e)}")
            return False


def main():
    # 配置阿里云访问密钥和域名
    ACCESS_KEY_ID = os.environ["ACCESS_KEY_ID"]
    ACCESS_KEY_SECRET = os.environ["ACCESS_KEY_SECRET"]
    DOMAIN_NAME = os.environ["DOMAIN_NAME"]

    # 创建DNS操作实例
    dns = AliyunDNS(ACCESS_KEY_ID, ACCESS_KEY_SECRET, DOMAIN_NAME)

    # 读取Excel文件
    try:
        """
        # 假设Excel文件名为dev_dns_records.xlsx, 根据实际情况修改, 表格格式如下:

        记录类型	主机记录	解析线路	记录值	MX优先级	TTL值	状态(暂停/启用)	备注
        A	dev-chengdu-game	默认	123.123.123.123		600	启用	公网
        """
        df = pd.read_excel("dev_dns_records.xlsx")

        # 构建需要更新的记录列表
        records_to_update = []
        for _, row in df.iterrows():
            # 只处理状态为"启用"的记录
            if row["状态(暂停/启用)"] == "启用":
                record = {
                    "rr": row["主机记录"],
                    "type": row["记录类型"],
                    "value": "192.168.6.216",  # 统一修改为新IP
                }
                records_to_update.append(record)

        # 获取现有解析记录
        existing_records = dns.get_domain_records()

        # 遍历要更新的记录
        for new_record in records_to_update:
            record_found = False
            print(f"正在处理记录: {new_record['rr']}")

            # 检查是否存在相同主机记录
            for existing_record in existing_records:
                if existing_record["RR"] == new_record["rr"]:
                    record_found = True
                    print(f"找到现有记录, 准备更新: {new_record['rr']}")
                    # 如果记录已存在,则更新
                    dns.update_domain_record(
                        existing_record["RecordId"],
                        new_record["rr"],
                        new_record["type"],
                        new_record["value"],
                    )
                    break

            # 如果记录不存在,则添加新记录
            if not record_found:
                print(f"未找到现有记录, 准备添加: {new_record['rr']}")
                dns.add_domain_record(
                    new_record["rr"], new_record["type"], new_record["value"]
                )

    except Exception as e:
        print(f"处理Excel文件时出错: {str(e)}")


if __name__ == "__main__":
    main()
