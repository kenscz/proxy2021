#!/bin/bash
#

RUN_OPTS=$*
if [[ -z "$RUN_OPTS" ]];then
    echo "安装失败，缺少必要的参数： --port=xxx --user=xxx --passwd=xxxx"
    exit 1
fi
ansible s5hosts -m shell -a "wget --no-check-certificate https://raw.github.com/Lozy/danted/master/install.sh -O install.sh && bash install.sh $RUN_OPTS"
