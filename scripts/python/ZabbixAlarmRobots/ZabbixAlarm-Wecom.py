#!/usr/bin/python3
# -*- coding: utf-8 -*-

import requests, sys
# import urllib3

# urllib3.disable_warnings()


def SendMessageURL(User, Subject, Messages):
    # WeCom机器人的Webhook地址
    URL = "https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=66ccff"
    HEADERS = {"Content-Type": "application/json"}
    Data = {
        "msgtype": "markdown",
        "markdown": {
            "content": '<font color="warning">%s</font> \n <font color="info">%s </font>\n  <@%s> '
            % (Subject, Messages, User),
            "mentioned_list": [User],
        },
    }
    r = requests.post(url=URL, headers=HEADERS, json=Data, verify=False)
    print(r.json())


if __name__ == "__main__":
    SENDTO = str(sys.argv[1])
    SUBJECT = str(sys.argv[2])
    MESSAGE = str(sys.argv[3])
    Status = str(SendMessageURL(SENDTO, SUBJECT, MESSAGE))
    print(Status)
