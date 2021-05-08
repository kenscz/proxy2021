#!/bin/bash
#

RUN_OPTS=$*
if [[ -z "$RUN_OPTS" ]];then
    echo "安装失败，缺少必要的参数： --port=xxx --user=xxx --passwd=xxxx"
    exit 1
fi

screen -d -m -S s1 ansible s5hosts -m shell -a "yum install wget -y && wget --no-check-certificate https://raw.github.com/Lozy/danted/master/install.sh -O install.sh && bash install.sh $RUN_OPTS" && screen -r s1