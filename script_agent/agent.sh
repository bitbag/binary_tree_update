#!/bin/bash
#this shell is    used to check parent version status.
git_ip=192.168.2.157

ips=$1
update_ver=$2
repo_path=/data/repo/work1
code_path=/data/backup
agent_path=/opt/script_agent
p_ip=`echo $1 | cut -d',' -f1`
c_ip_1=`echo $1 | cut -d',' -f2`
c_ip_2=`echo $1 | cut -d',' -f3`
echo $p_ip,$c_ip_1,$c_ip_2,$update_ver > ${agent_path}/log

function check_p_ver () {
        while [ 1 ]
        do
                now_ver=`cat $agent_path/version`
                if [ x"$now_ver" = x"$update_ver" ];then
                        rsync -av  --password-file=/etc/rsync.pass --exclude-from=${agent_path}/exclude.txt --delete nihao@$p_ip::backup $code_path/ 
                        if [ $? -eq 0 ];then
				if [  x'$c_ip_1' != x'' ];then
					for i in $c_ip_1 $c_ip_2
					do
						rsync -av --password-file=/etc/rsync.pass ${agent_path}/version nihao@$i::agent
					done
					[ $? -eq 0 ] && exit 0 || continue 
				fi
			else
				rsync -av --delete --password-file=/etc/rsync.pass --exclude-from=${agent_path}/exclude.txt nihao@$git_ip::backup/* $code_path/
			fi
		else
			continue
		fi
		sleep 2
	done

}                                     

check_p_ver
