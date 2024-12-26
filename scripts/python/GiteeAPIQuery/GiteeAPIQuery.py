"""
code by songdaoyuan@202412.25
获取Gitee企业版仓库列表, 获取每个仓库的成员统计信息
"""

import os
import json
import requests
from dotenv import load_dotenv, find_dotenv


"""
Step 0
使用.env文件管理token信息
"""
_ = load_dotenv(find_dotenv(".env"))

access_token = os.environ["access_token"]  # 管理员账号的用户授权码
enterprise_id = os.environ["enterprise_id"]  # 企业ID

req_headers = {
    # 按需添加
}

"""
Step 1
获取所有的的仓库列表
API文档链接: https://gitee.com/api/v8/swagger#/getEnterpriseIdProjectsProjectIdMembersWithTeamMembers
"""


def getRepoList(access_token: str, enterprise_id: str) -> int:

    url = f"https://api.gitee.com/enterprises/{enterprise_id}/projects"  # 路径参数写在这里
    params: dict = {
        # 查询参数写在这里
        "access_token": access_token,
    }

    response = requests.get(url=url, params=params, headers=req_headers)

    if response.status_code == 200:
        repoJson = response.json()
        # 将 JSON 数据写入文件时，设置 ensure_ascii=False 避免中文被转义, indent=4 美化缩进
        with open("RepoList.payload", "w", encoding="UTF-8") as file:
            json.dump(repoJson, file, ensure_ascii=False, indent=4)
    else:
        print(f"请求失败，状态码：{response.status_code}, 错误信息：{response.text}")


getRepoList(access_token, enterprise_id)

# # https://api.gitee.com/enterprises/{enterprise_id}/projects

# project_id = r"focusin_team%2Fcityprofession-admin-bd"  # 查询参数为path, 这里就是使用的仓库名, 仓库名中的 / 需要转义为 %2F

# # 获取仓库成员和仓库团队成员
# url = f"https://api.gitee.com/enterprises/{enterprise_id}/projects/{project_id}/members/with_team_members"

# print(url)

# # 请求参数
# params = {
#     "access_token": access_token,
#     "qt": "path",  # 查询参数为path, 空则表示查询参数为id
# }

# # 发送请求
# response = requests.get(url, params=params)

# # 检查响应状态
# if response.status_code == 200:
#     repos = response.json()
#     print(repos)
# else:
#     print(f"请求失败: {response.status_code}, {response.text}")
