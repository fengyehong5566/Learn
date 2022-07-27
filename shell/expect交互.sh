#!/usr/bin/expect -f     
set day 'date +%Y%m%d -d "-1 days"'
set timeout -1    #注意，此处为设置永不超时
spawn lftp XXXX@10.151.XXX.XXX:8021
expect "Password:"
send "XXXXX\r"
send "cd /bofangurl/\r"
send "ls\r"
send "get XXXXX.csv\r" 
interact


解释：
spawn    #启动新的进程
expect    #从进程接收字符串，信息匹配成功则执行expect后面的程序动作
send    #用于向进程发送字符串
set    #定义变量
set timeout    #设置超时时间
exp_continue    #相当于其他语言的continue，此处用于判断语句，在此处重新进行判断
expect eof    #表示结束交互，但会原终端所在位置。
interact    #与expect eof作用类似，但结束交互后，所处位置为脚本内最后所在位置
exit    #退出expect脚本




#!/bin/bash
ip=$1
password=$2
autologin(){
expect -c "
set timeout 5
spawn ssh root@$1 -p22
expect {
“yes/no” {send “yes”\r;exp_continue}
“password” {send $2\r}
}
interact"
}
