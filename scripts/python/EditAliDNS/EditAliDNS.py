from aliyunsdkcore.client import AcsClient
from aliyunsdkalidns.request.v20150109.DescribeDomainRecordsRequest import DescribeDomainRecordsRequest
from aliyunsdkalidns.request.v20150109.UpdateDomainRecordRequest import UpdateDomainRecordRequest
from aliyunsdkalidns.request.v20150109.AddDomainRecordRequest import AddDomainRecordRequest
import json

'''
在开始之前, 需要安装依赖
aliyun-python-sdk-core-v3 aliyun-python-sdk-alidns
'''

class AliyunDNS:
    def __init__(self, access_key_id, access_key_secret, domain_name):
        self.client = AcsClient(access_key_id, access_key_secret, 'cn-hangzhou')
        self.domain_name = domain_name

    def get_domain_records(self):
        """获取域名解析记录"""
        request = DescribeDomainRecordsRequest()
        request.set_accept_format('json')
        request.set_DomainName(self.domain_name)
        
        try:
            response = self.client.do_action_with_exception(request)
            records = json.loads(response)
            return records['DomainRecords']['Record']
        except Exception as e:
            print(f"获取解析记录失败：{str(e)}")
            return []

    def update_domain_record(self, record_id, rr, record_type, value):
        """更新域名解析记录"""
        request = UpdateDomainRecordRequest()
        request.set_accept_format('json')
        
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
        request.set_accept_format('json')
        
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
    ACCESS_KEY_ID = "your_access_key_id"
    ACCESS_KEY_SECRET = "your_access_key_secret"
    DOMAIN_NAME = "example.com"

    # 创建DNS操作实例
    dns = AliyunDNS(ACCESS_KEY_ID, ACCESS_KEY_SECRET, DOMAIN_NAME)

    # 要批量修改的记录列表
    records_to_update = [
        {
            "rr": "www",
            "type": "A",
            "value": "192.168.1.1"
        },
        {
            "rr": "mail",
            "type": "A",
            "value": "192.168.1.2"
        }
    ]

    # 获取现有解析记录
    existing_records = dns.get_domain_records()
    
    # 遍历要更新的记录
    for new_record in records_to_update:
        record_found = False
        
        # 检查是否存在相同主机记录
        for existing_record in existing_records:
            if existing_record['RR'] == new_record['rr']:
                record_found = True
                # 如果记录已存在,则更新
                dns.update_domain_record(
                    existing_record['RecordId'],
                    new_record['rr'],
                    new_record['type'],
                    new_record['value']
                )
                break
        
        # 如果记录不存在,则添加新记录        
        if not record_found:
            dns.add_domain_record(
                new_record['rr'],
                new_record['type'], 
                new_record['value']
            )

if __name__ == '__main__':
    main()