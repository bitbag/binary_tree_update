#!/bin/bash
export WORKPATH=`pwd`
iplist=/opt/script_server/testips.txt
ex_file=/opt/script_server/exclude.txt

function rsync_daemon () {
	for i in `cat $iplist`
	do
		rsync -av /etc/rsync* $i:/etc/
		[ $? -eq 0 ] && echo -e  "\033[0;32;1mrsync successfully\033[0m" || echo -e "\033[0;31;1mrsync failed\033[0m"
		ssh $i "rsync --daemon"
		[ $? -eq 0 ] && echo -e "\033[0;32;1mdaemon is up\033[0m" || echo -e "\033[0;31;1mdaemon is down\033[0m"
	done
}

function rsync_anyfile () {
	file_name=$1
	echo ${file_name}
	for i in `cat $iplist`
        do
                rsync -av  --password-file=/etc/rsync.pass ${WORKPATH}/${file_name}  nihao@$i::agent
                [ $? -eq 0 ] && echo -e "\033[0;32;1m $2 rsync ok!\033[0m" || echo -e "\033[0;31;1m $2 file failed\033[0m"
        done
}

function iptables_873 () {
	for i in `cat $iplist`
	do
		ssh $i "sed -i '/-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT/a\-A INPUT -m state --state NEW -m tcp -p tcp --dport 873 -j ACCEPT' /etc/sysconfig/iptables" 
		[ $? -eq 0 ] && echo -e "\033[0;32;1m873端口开放\033[0m" || echo -e "\033[0;31;1m修改防火墙失败\033[0m"
		ssh $i "/etc/init.d/iptables restart"
	done
}

case $1 in
rsync_daemon)
	rsync_daemon
	echo -e "\033[0;33;1m复制配置文件到远程主机\033[0m"
;;
iptables_873)
	iptables_873
	echo -e "\033[0;33;1m修改防火墙添加873端口\033[0m"
;;
rsync_anyfile)
	shift
	rsync_anyfile $1
;;
*)
	echo -e "\033[0;33;1musage: rsync_daemon or rsync_anyfile or iptables_873\033[0m"
;;
esac
