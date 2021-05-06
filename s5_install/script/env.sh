#!/bin/bash
#


SERVER_INFO_FILE=$1
SERVER_INFO_FILE=${SERVER_INFO_FILE:-info.txt}
help_msg(){
    cat <<EOF
bash env.sh info.txt
EOF
}

if [ -z "$SERVER_INFO_FILE" ];then
    echo "缺少参数"
    help_msg
    exit 1
fi

if [ ! -f "$SERVER_INFO_FILE" ];then
    echo "文件 $SERVER_INFO_FILE 不存在"
    help_msg
    exit 1
fi


#######################
cd $(dirname $0)
yum install wget vim dos2unix epel-release expect -y
yum install ansible -y

echo 'deprecation_warnings=False' >> /etc/ansible/ansible.cfg

grep 'deprecation_warnings=False' /etc/ansible/ansible.cfg &> /dev/null || sed -i '/^\[defaults\]$/ a deprecation_warnings=False' /etc/ansible/ansible.cfg
grep 'command_warnings=False' /etc/ansible/ansible.cfg &> /dev/null || sed -i '/^\[defaults\]$/ a command_warnings=False' /etc/ansible/ansible.cfg

dos2unix -q $SERVER_INFO_FILE
echo >> $SERVER_INFO_FILE
echo '[s5hosts]' > /etc/ansible/hosts
awk '{print $1}' $SERVER_INFO_FILE >>  /etc/ansible/hosts

chmod +x auto_ssh.exp
[[ -f /root/.ssh/id_rsa ]] || ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa
err_hosts=()
while read line;do
    ip=$(echo $line | awk '{print $1}')
    psw=$(echo $line | awk '{print $2}')
    [[ -z "$ip" ]] && continue
    ./auto_ssh.exp $ip $psw 
    if [[ "$?" != 0 ]];then
        err_hosts[${#err_hosts[@]}]="$ip"
    fi
done < $SERVER_INFO_FILE

if [[ ${#err_hosts[@]} != 0 ]];then
    echo '以下服务器连接失败，请检查ip和密码：'
    for ip in ${err_hosts[@]};do
        echo $ip
    done
fi
