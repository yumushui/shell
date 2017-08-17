#!/bin/bash
#this scripts is used to backup config files in OS for mysql.
#at first, you should make sure the $list and $backupdir value.
#created by zhaofx on 20170817

#定义变量
DATE=`date +%Y-%m-%d`
#host=`hostname | awk -F. '{print $1}'`
datadir=/data/mysql
OLDDATE=`date +%Y-%m-%d --date='30 days ago'`
conf=/etc/my.cnf
list="/etc/my.cnf  /var/spool/cron /etc/sysconfig/iptables"

#定义备份目录
backupdir=/data/backup/mysql

echo "############## Start `date +'%Y-%m-%d %H:%M:%S'` ##############"
echo "`date +'%Y-%m-%d %H:%M:%S'` start backup config files"
#创建备份目录
server=`cat $conf | grep ^log_error | awk -F/ '{print $NF}' | awk -F. '{print $1}'`
databackupdir=$backupdir/$server/config/$DATE
[ ! -d $databackupdir ] && mkdir -p $databackupdir

#定义邮件正文文件
emailfile=$databackupdir/config_backup_$DATE.log

#备份配置数据
cp -ar $list $databackupdir

#删除过期数据
olddir=$backupdir/$server/config/$OLDDATE
if [ -d $olddir ]
then
 rm -rf $olddir
 if [[ $? == 0 ]];then
   echo "`date +%Y-%m-%d' '%H:%M:%S` $olddir,this old dir delete success." >> $emailfile
 else
   echo "`date +%Y-%m-%d' '%H:%M:%S` $olddir,this old dir delete fail." >> $emailfile
 fi
else
 echo "$olddir,dot not have this old dir,no dir delete." >> $emailfile
fi

echo "`date +'%Y-%m-%d %H:%M:%S'` backup config files complete."
echo "############### End `date +'%Y-%m-%d %H:%M:%S'` ###############"
echo 
