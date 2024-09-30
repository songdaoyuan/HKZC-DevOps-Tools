#!/bin/bash

# < (输入重定向):
#     用途: 从文件读取输入
#     例子: command < input.txt
#     作用: 将 input.txt 的内容作为 command 的输入

# > (输出重定向):
#     用途: 将输出写入文件
#     例子: command > output.txt
#     作用: 将 command 的输出写入 output.txt (如果文件存在则覆盖)

# <> (双向重定向):
#     用途: 同时用于输入和输出
#     例子: exec 3<>/dev/tcp/google.com/80
#     作用: 打开一个文件描述符用于读写

# | (管道):
#     用途: 将一个命令的输出作为另一个命令的输入
#     例子: command1 | command2
#     作用: command1 的输出直接作为 command2 的输入
