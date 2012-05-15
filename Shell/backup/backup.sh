#!/bin/sh

#脚本工作目录
if [ -L $0 ]; then
    SCRIPTPATH=$(dirname $(ls -l $0 | awk '{print $11}')) #由链接文件访问    
else
    SCRIPTPATH=$(cd $(dirname $0); pwd) #由直接访问
fi

#备份服务器SSH
BHOST=backup@10.0.0.1
#备份路径 远程服务器上的
BDST=/volume1/Backup

#SSH密钥 密钥的导入通过 ssh-add 
SSHKEY=/Users/JinnLynn/.ssh/keys/jnas-key

#忽略的文件列表文件
EXCLUDE=./excludes

#日志
LOGFILE=./log/backup-$(date +%Y%m%d).log

#SSH密钥代理SOCKET 在cron中必须设置，否则无法成功备份
if [ -z $SSH_AUTH_SOCK ]; then
	export SSH_AUTH_SOCK=$( ls /tmp/launch-*/Listeners )
fi

#进入工作目录
cd $SCRIPTPATH

#建立日志目录
[ -d $(dirname $LOGFILE) ] || mkdir $(dirname $LOGFILE)

#创建空目录 用于清空旧的日增量变化备份
[ -d .emptydir ] || mkdir .emptydir

echo "$(date +"%H:%M:%S") backup start\n" >> $LOGFILE

#处理备份的函数 
#参数1: 要备份的文件夹路径 注意：最好以“/”结尾
#参数2: 备份的名称，用于在服务端建立文件夹
#参数3: 备份NAS上的文件
function backup() {
	echo "------------------------------------------------" >> $LOGFILE
	#检查目录是否已存在，如果没有建立目录
	ssh $BHOST "if [ ! -d $BDST/$2 ]; then mkdir $BDST/$2 ; chown -R backup:users $BDST/$2 ; chmod -R 744 $BDST/$2 ; fi"
	#被修改回删除的文件保存处理 每天生成一个目录
	BDIR="$BDST/$2/$(date +0%u)"
	OPTS="-av --force --ignore-errors --delete --backup --backup-dir=$BDIR"
	SSH_OPT="ssh -i ${SSHKEY}"
	EXCULDE_OPT="--exclude-from=$EXCLUDE"
	#清除旧的增量备份数据
	rsync --delete -a $SCRIPTPATH/.emptydir/ $BHOST:$BDIR
	#同步文件
	if [ $3 = nas ]; then
		#同步NAS上文件
		echo $3
		ssh -i $SSHKEY $BHOST "rsync $OPTS $1 $BDST/$2/current" >> $LOGFILE
	else
		#同步本地文件
		rsync $OPTS $EXCULDE_OPT -e "${SSH_OPT}" $1 $BHOST:$BDST/$2/current >> $LOGFILE
	fi
	
	echo "------------------------------------------------" >> $LOGFILE
	echo "$(date +"%H:%M:%S") $2 ok\n\n" >> $LOGFILE
}

#以下为备份列表 格式：backup 备份文件夹绝对路径 备份名
#注意：备份文件夹路径最好以'/'结束
#------------------------------------------------------------------------#


#JMBP
#备份iTunes
backup /Users/JinnLynn/Music/iTunes/ JMBP.iTunes this

#备份Developer
backup /Users/JinnLynn/Developer/ JMBP.Developer this

#备份Documents
backup /Users/JinnLynn/Documents/ JMBP.Documents this

#备份Applications
backup /Applications/ JMBP.Applications this

#备份Pictures
backup /Users/JinnLynn/Pictures/ JMBP.Pictures this

#JMBPWin
backup /Volumes/BOOTCAMP/Users/JinnLynn/Developer/ JMBPWin.Developer this

#JNAS SCMs
backup /volume1/DevCenter/SCMs/ JNAS.SCMs nas


#------------------------------------------------------------------------#

#删除空目录
rmdir $SCRIPTPATH/.emptydir

echo "$(date +"%H:%M:%S") backup finish\n\n" >> $LOGFILE