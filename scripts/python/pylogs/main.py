#!/usr/bin/python

'''
目标功能
1.文件获取指定尾部xxx行
2.清空文件内容
'''

import os
import uvicorn
from typing import Union
from fastapi import FastAPI

app = FastAPI()

# 从系统中获取环境变量
os.getenv("ENV_VAR")


@app.get("/")
async def read_root():
    return {"说明": "这里预计返回整个目标路径的树形目录"}


@app.get("/items/{item_id}")
async def read_item(item_id: int, q: Union[str, None] = None):
    return {"item_id": item_id, "q": q}


if __name__ == "__main__":
    uvicorn.run(app=app, host="127.0.0.1", port=80, reload=True)
