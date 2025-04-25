import requests
import re
from datetime import datetime

def daily_hitokoto():
    """每日一言主函数，读取content.payload文件并发送当日内容"""
    try:
        with open('content.payload', 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except FileNotFoundError:
        print("Error: content.payload文件未找到")
        return

    today = datetime.now()
    current_month, current_day = today.month, today.day

    content_lines = []
    found_date = False

    # 遍历每一行寻找匹配当前日期的部分
    for i, line in enumerate(lines):
        stripped_line = line.strip()
        # 匹配日期行，如"4月21日"
        date_match = re.match(r'(\d+)月(\d+)日', stripped_line)
        if date_match:
            month, day = map(int, date_match.groups())
            if month == current_month and day == current_day:
                # 收集从下一行开始直到OVER行的内容
                j = i + 1
                while j < len(lines):
                    current_line = lines[j].strip()
                    if current_line == 'OVER':
                        found_date = True
                        break
                    content_lines.append(current_line)
                    j += 1
                if found_date:
                    break

    if not found_date:
        print("今日无对应的文案内容")
        return

    if not content_lines:
        print("今日的文案内容为空")
        return

    # 构造消息内容并发送
    message_content = '\n'.join(content_lines)
    post_wecom_rp(message_content)

def post_wecom_rp(content):
    """发送消息到企业微信接口"""
    headers = {
        'X-Secure-Auth': '0d00-0721'
    }
    payload = {
        "msgtype": "text",
        "text": {
            "content": content
        }
    }
    response = requests.post(
        url="https://wecom-rp.hysz.co/",
        headers=headers,
        json=payload
    )
    if response.status_code == 200:
        print("消息发送成功")
    else:
        print(f"消息发送失败，状态码：{response.status_code}")

if __name__ == '__main__':
    daily_hitokoto()