#!/bin/bash
#this script is used to backup mysql database every day ,by crontab xtrabackup tools.
#before excute the script ,you should make sure the $conf,$mysql_extra_file,$backupdir value ,and the innobackupex,pgiz command ,at first.
#created by zhaofx on 20170817
#该脚本用于在CentOS 6.*系统上，用Xtrabackup工具对MySQL数据库进行备份，可以在crontab设置如下任务：
#  30 01 * * * /bin/sh /home/mysql/scripts/cron_xtrabackup_innodb_full.sh >> /tmp/cron_xtrabackup_innodb_full.log &

#定义变量
source /etc/profile
DATE=`date +%Y-%m-%d`
innobackupex=`which innobackupex`
#host=`hostname | awk -F. '{print $1}'`
mysql=/usr/local/mysql/bin/mysql
mysqldump=/usr/local/mysql/bin/mysqldump
OLDDATE=`date +%Y-%m-%d --date='7 days ago'`
conf=/etc/my.cnf
mysql_extra_file=/root/.my.cnf

#定义并行线程数
cpu=`grep -c processor /proc/cpuinfo`
parallel=$(($cpu-0))

#定义备份目录
backupdir=/data/backup/mysql

#MySQL选项和SQL语句
mysqlopt="--silent --skip-column-names"
sql="select schema_name from information_schema.schemata where schema_name not in('information_schema','test','performance_schema');"

#创建备份目录
server=`cat $conf | grep ^log_error | awk -F/ '{print $NF}' | awk -F. '{print $1}'`
databackupdir=$backupdir/$server/$DATE
[ ! -d $databackupdir ] && mkdir -p $databackupdir

#定义邮件正文文件
emailfile=$databackupdir/mysqlfull_xtrabackup_$DATE.log


#执行日志注释内容01
echo "############### START `date +'%Y-%m-%d %H:%M:%S'`#################"
echo "`date +'%Y-%m-%d %H:%M:%S'` 日期为 ${DATE} 的数据库备份开始"
start_time_main=`date +'%Y-%m-%d %H:%M:%S'`
echo "`date +'%Y-%m-%d %H:%M:%S'` 备份文件的目录为: ${databackupdir}"
echo ""
echo "`date +'%Y-%m-%d %H:%M:%S'` 开始用 innobackupex 进行物理备份MySQL库文件"
echo "`date +'%Y-%m-%d %H:%M:%S'` 物理备份进行中....."

#物理备份
$innobackupex --defaults-extra-file=${mysql_extra_file} --stream=tar ./ 2> $emailfile | pigz -p $parallel > $databackupdir/mysqlfull_xtrabackup_$DATE.tar.gz

#执行日志注释内容02
echo "`date +'%Y-%m-%d %H:%M:%S'` du -sh $databackupdir/mysqlfull_xtrabackup_$DATE.tar.gz"
sleep 10
du -sh "$databackupdir/mysqlfull_xtrabackup_$DATE.tar.gz"
echo "`date +'%Y-%m-%d %H:%M:%S'` 物理备份完成!"
echo

#循环DB,mysqldump备份表结构等
echo "`date +'%Y-%m-%d %H:%M:%S'` 开始 mysqldump 进行逻辑备份MySQL库表结构"
   for db in `$mysql $mysqlopt -e "$sql"`
   do
   $mysqldump --databases $db --no-data --triggers --routines --events > $databackupdir/$db.sql
   done

#打包schema文件
cd $databackupdir
tar -cf schema_$DATE.tar *.sql

#执行日志注释内容03
echo "`date +'%Y-%m-%d %H:%M:%S'` du -sh $databackupdir/schema_$DATE.tar"
sleep 10
du -sh "$databackupdir/schema_$DATE.tar"
echo "`date +'%Y-%m-%d %H:%M:%S'` 循环DB,mysqldump备份表结构等,并打包schema文件,逻辑备份完成"


#华丽的分割线
echo '**************************************************************************************************'>> $emailfile

#删除过期备份
olddir=$backupdir/$server/$OLDDATE
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

#执行日志注释内容04
echo ""
echo "`date +'%Y-%m-%d %H:%M:%S'` 删除过期备份目录 ： ${olddir}"
ls -l $backupdir/$server
echo
echo "`date +'%Y-%m-%d %H:%M:%S'` 备份过程日志文件为： ${emailfile}"
echo "`date +'%Y-%m-%d %H:%M:%S'` 备份脚本运行完毕，今天的定时任务完成。"
end_time_main=`date +'%Y-%m-%d %H:%M:%S'`
run_time_s=$(( `date -d "${end_time_main}" +%s` - `date -d "${start_time_main}" +%s` ))
rut_time_m=`echo "scale=2; ${run_time_s}/60" | bc`
echo "`date +'%Y-%m-%d %H:%M:%S'` the job start on ${start_time_main} , end on ${end_time_main} , the run_time_s is ${run_time_s} , the minutes is  ${rut_time_m} . "
echo "################ END `date +'%Y-%m-%d %H:%M:%S'` ##################"
echo ""
