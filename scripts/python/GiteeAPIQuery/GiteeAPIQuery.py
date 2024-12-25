'''
code by songdaoyuan@202412.25

查询Gitee企业版仓库列表, 获取每个仓库的成员统计信息
'''

import os
from dotenv import load_dotenv, find_dotenv

# 使用.env文件管理token信息
_ = load_dotenv(find_dotenv(".env"))

access_token = os.environ["access_token"]       # 管理员账号的用户授权码
enterprise_id = os.environ["enterprise_id"]     # 企业ID

import requests

project_id = r"focusin_team%2Fcityprofession-admin-bd"     # 查询参数为path, 这里就是使用的仓库名, 仓库名中的 / 需要转义为 %2F

# 获取仓库成员和仓库团队成员
url = f"https://api.gitee.com/enterprises/{enterprise_id}/projects/{project_id}/members/with_team_members"

print(url)

# 请求参数
params = {
    "access_token": access_token,
    "qt": "path",       # 查询参数为path, 空则表示查询参数为id
}

# 发送请求
response = requests.get(url, params=params)

# 检查响应状态
if response.status_code == 200:
    repos = response.json()
    print(repos)
else:
    print(f"请求失败: {response.status_code}, {response.text}")
