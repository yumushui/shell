#!/bin/sh
#该脚本用于自动创建MySQL slave从库#
#每次执行脚本的先决条件有：准备好slave服务器上的 my.cnf文件,对应参数已经修改;master主库创建好slave用户,确定主库备份文件;
#每次执行该脚本，主库、从库相关的几个变量，都要进行对应修改和确认
#created by zhaofx on 20170817


source /etc/profile

#设置主库和从库相关信息
#这些配置参数影响整个过程，在每次执行脚本时，都需要进行确认和修改
master_host="xx.xx.xx.xx"       #主库mysql的IP
master_port="3306"               #主库mysql的端口
MySQL_Conf="/etc/my.cnf"        #配置文件
MySQL_Tmp_Dir="/data/mysql_tmp_backup"     #临时恢复目录
Bak_File="/tmp/mysqlfull_xtrabackup_2017-04-18.tar.gz"     #备份文件

#执行的命令
innobackupex=`which innobackupex`
unpigz=`which unpigz`
mysql=`which mysql`
mysqld_safe=`which mysqld_safe`

#在主库进行备份
function Master_DB_Backup(){
    echo "`date +'%Y-%m-%d %H:%M:%S'` backup mysql database  ${master_host}:${master_port} "
}


#在从库上准备目录与配置文件
function Slave_Dir_File(){
    #确认slave实例相关目录
    if [ ! -d "/data/mysql_${master_port}" ];then
        mkdir -p /data/mysql_${master_port}/{data,innodblog,log,tmp}
        chown -R mysql:mysql /data/mysql_{master_port}
    else
        service mysqld stop
        mv /data/mysql_${master_port} /data/mysql_${master_port}_old
        mkdir -p /data/mysql_${master_port}/{data,innodblog,log,tmp}
        chown -R mysql:mysql /data/mysql_{master_port}
    fi
    
    #确认slave临时恢复目录
    if [ ! -d "${MySQL_Tmp_Dir}" ];then
        mkdir -p ${MySQL_Tmp_Dir}
    else
        echo "`date +'%Y-%m-%d %H:%M:%S'` the dir exist : ${MySQL_Tmp_Dir} "
    fi
    
    #确认slave库上配置文件内容
    if [ ! -f "${MySQL_Conf}" ];then
        echo "`date +'%Y-%m-%d %H:%M:%S'` the mysql config file not exist . "
        echo "`date +'%Y-%m-%d %H:%M:%S'` Please Check and reexcute the script."
        exit 1
    else
        echo "`date +'%Y-%m-%d %H:%M:%S'` the mysql config file exist : ${MySQL_Conf}"
        grep "event-schedule" ${MySQL_Conf}
        grep "dir" ${MySQL_Conf}
    fi
    
    echo
}

#指定备份目录进行slave实例恢复
function Recover_Start_Instance(){
    #备份文件解压缩
    echo "`date +'%Y-%m-%d %H:%M:%S'` ${unpigz} -c ${Bak_File} | tar -ixC ${MySQL_Tmp_Dir}"
    du -sh ${Bak_File}
    echo "`date +'%Y-%m-%d %H:%M:%S'` unpigz execting ... ..."
    ${unpigz} -c ${Bak_File} | tar -ixC ${MySQL_Tmp_Dir}
    echo "`date +'%Y-%m-%d %H:%M:%S'` unpigz complete"
    echo 
    
    #执行恢复程序
    echo "`date +'%Y-%m-%d %H:%M:%S'` 第一次 apply log"
    echo "`date +'%Y-%m-%d %H:%M:%S'` ${innobackupex} --defaults-file=${MySQL_Conf} --apply-log ${MySQL_Tmp_Dir}"
    ${innobackupex} --defaults-file=${MySQL_Conf} --apply-log ${MySQL_Tmp_Dir}
    echo "`date +'%Y-%m-%d %H:%M:%S'` 第二次 apply log"
    echo "`date +'%Y-%m-%d %H:%M:%S'` ${innobackupex} --defaults-file=${MySQL_Conf} --apply-log ${MySQL_Tmp_Dir}"
    ${innobackupex} --defaults-file=${MySQL_Conf} --apply-log ${MySQL_Tmp_Dir}
    date +"%Y%m%d %H:%M:%S"
    echo
    
    echo "`date +'%Y-%m-%d %H:%M:%S'` 拷贝备份文件到数据目录"
    echo "`date +'%Y-%m-%d %H:%M:%S'` ${innobackupex} --defaults-file=${MySQL_Conf} --copy-back ${MySQL_Tmp_Dir}"
    ${innobackupex} --defaults-file=${MySQL_Conf} --copy-back ${MySQL_Tmp_Dir}
    echo "`date +'%Y-%m-%d %H:%M:%S'` copy bakcup complete"
    echo
    
    #启动slave上的MySQL服务
    echo "`date +'%Y-%m-%d %H:%M:%S'` start the slave mysql instance "
    chown -R mysql:mysql /data/mysql_${master_port}
    service mysqld start
    ps -ef|grep mysql
    echo "`date +'%Y-%m-%d %H:%M:%S'` the salve mysql start complete"
    echo
}

function Get_Config_Slave(){
    #在slave测试主库连接
    # master库授权命令为: grant replication slave on *.* to 'repl'@'xxxx' identified by 'replsafe'; 
    echo "`date +'%Y-%m-%d %H:%M:%S'` test the slave mysql instance connect to the master instance"
    ${mysql} -h ${master_host} -P ${master_port} -urepl -p'replsafe' -e "show databases;"
    echo "slave connect master nomal"
    
    #获取slave恢复所需的日志点：
    echo "`date +'%Y-%m-%d %H:%M:%S'` cat ${MySQL_Tmp_Dir}/xtrabackup_binlog_info"
    cat ${MySQL_Tmp_Dir}/xtrabackup_binlog_info
    master_log_file=`cat ${MySQL_Tmp_Dir}/xtrabackup_binlog_info | awk '{print $1}'`
    master_log_pos=`cat ${MySQL_Tmp_Dir}/xtrabackup_binlog_info | awk '{print $2}'`
    echo "`date +'%Y-%m-%d %H:%M:%S'` the master_log_file is ${master_log_file} , and the master_log_pos is ${master_log_pos} ."
    echo
    
    
    #生成salve创建命令：
    cat > /tmp/slave_start.txt <<EOF
change master to 
master_host="${master_host}", 
master_port=${master_port}, 
master_user='repl', 
master_password='replsafe', 
master_log_file="${master_log_file}", 
master_log_pos=${master_log_pos}; 

start slave; 
show slave status\G 

EOF
    
    echo "`date +'%Y-%m-%d %H:%M:%S'` the change master command is :"
    cat /tmp/slave_start.txt
    
    echo "`date +'%Y-%m-%d %H:%M:%S'` exectue change master command "
    ${mysql} -e "source /tmp/slave_start.txt"
    echo "`date +'%Y-%m-%d %H:%M:%S'` the change master command complete "
}

#定义主函数
function main(){
    echo "########## Start `date +'%Y-%m-%d %H:%M:%S'` ##########"
    echo "`date +'%Y-%m-%d %H:%M:%S'` make a mysql slave, master is ${master_host}:${master_port} "
    echo
    
    #执行主库备份
    #Master_DB_Backup
    #创建slave恢复相关目录
    Slave_Dir_File
    #执行slave恢复,并启动slave实例
    Recover_Start_Instance
    #配置slave库,如果只是恢复实例，不建slave库，这一部分可以不执行
    Get_Config_Slave
    
    echo
    echo "########## End `date +'%Y-%m-%d %H:%M:%S'` ##########"
    echo
}

#执行主函数
main
