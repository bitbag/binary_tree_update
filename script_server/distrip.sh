#!/bin/bash
#this shell is used to distrip work1_code to servers!

export WORKPATH=/opt/script_server

repo_path=/data/repo/work1
ip_list=$WORKPATH/iplist.txt
ser_ips=$WORKPATH/ser_ips.txt
version=abcdef

dest_path=/data/backup
agent_path=/opt/script_agent



function git_pull () {
	cd $code_path && git pull
	commit=`cd $code_path && git log -1 | grep commit`
	[ $? -eq 0 ] && echo -e "\033[0;32;1m $commit \033[0m"
}

function check_version () {
	cat $ip_list
	echo "==========================="
}

function start_agent () {
	cat  -n $ip_list > $ser_ips
	while read line
	do
		ser_num=`echo $line | awk '{print $1}'`
		ser_ip=`echo $line | awk '{print $2}'`
		c_num_1=`echo $ser_num*2|bc`
		c_ip_1=`sed -n ${c_num_1},${c_num_1}p $ser_ips | awk '{print $2}'`
		c_num_2=`echo $ser_num*2 + 1| bc`
		c_ip_2=`sed -n ${c_num_2},${c_num_2}p $ser_ips | awk '{print $2}'`
		if [ $ser_num -gt 1 ];then
			p_ip_num=`echo $ser_num/2|bc`
			p_ip=`sed -n ${p_ip_num},${p_ip_num}p $ser_ips | awk '{print $2}'`
			ssh $ser_ip "/bin/bash ${agent_path}/agent.sh ${p_ip},${c_ip_1},${c_ip_2} $version  > /dev/null 2>&1 &" < /dev/null
		fi
	done < $ser_ips 
}

function update () {
	for i in `cat $ip_list | grep -v '192.168.2.157' | head -2`
	do
		rsync -av --delete --password-file=/etc/rsync.pass --exclude-from=$WORKPATH/exclude.txt /data/backup/* nihao@$i::backup/ 
		if [ $? -eq 0 ];then
			rsync -av --password-file=/etc/rsync.pass $dest_path/version nihao@$i::agent
		else
			echo "\033[0;32;1m$i 更新失败 \033[0m"
			exit 1
		fi
	done

}

case $1 in 
git_pull)
	echo "git pull"
;;
check_version)
	echo "check_version"
;;
start_agent)
	start_agent
;;
update)
	update
;;
*)
	echo "usage: git_pull or check_version or start_agent or update"
;;
esac
