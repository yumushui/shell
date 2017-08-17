#!/bin/sh
#this script is used to : optimize tables in mysql database.
#before excute the script, you should make sure the two values : $mysql_cmd and $db_tab_list .
#created by zhaofx on 2017-06-15
#you can add the job into crontab like this : 30 3 * * 7 /bin/sh /home/mysql/mysql_optimize.sh &>> /tmp/mysql_optimize.log &

#定义公共变量
source /etc/profile
mysql_data_dir=`cat /etc/my.cnf | grep datadir | awk -F '=' '{print $2}'`
mysql_pwd=xxxx
mysql_cmd="/usr/local/mysql/bin/mysql -uroot -p${mysql_pwd} -S /data/mysql/tmp/mysql.sock"

#定义需要循环的表变量
db_tab_list="digital_lottery|comprehensive_orders"

#定义功能函数,执行优化表操作,并对比优化前后表状态
function optimize_tab(){
    db=`echo $1 | awk -F '|' '{print $1}'`
    tab=`echo $1 | awk -F '|' '{print $2}'`
    
    echo "`date +'%Y-%m-%d %H:%M:%S'` before optimieze ,the table file is :"
    echo "`date +'%Y-%m-%d %H:%M:%S'` du -sh ${mysql_data_dir}/${db}/${tab}*"
    du -sh ${mysql_data_dir}/${db}/${tab}*
    sql_01=` echo "select TABLE_NAME,CONCAT(ROUND(DATA_LENGTH/1024/1024),?MB?) as DATA_LENGTH,CONCAT(ROUND(INDEX_LENGTH/1024/1024),?MB?) as INDEX_LENGTH,CONCAT(ROUND(SUM(DATA_LENGTH+INDEX_LENGTH)/1024/1024),?MB?) as TOTDB_SIZE from information_schema.TABLES where TABLE_SCHEMA=?${db}? and TABLE_NAME=?${tab}?;" | sed "s/?/'/g"`
    echo "`date +'%Y-%m-%d %H:%M:%S'` ${sql_01} "
    ${mysql_cmd} -e "${sql_01}"
    echo "`date +'%Y-%m-%d %H:%M:%S'` select count(*) from ${tab} "
    ${mysql_cmd} -e "use ${db};select count(*) from ${tab};"
    echo
    
    sql_02="use ${db};OPTIMIZE table ${tab};"
    echo "`date +'%Y-%m-%d %H:%M:%S'` begine optimieze : ${sql_02} "
    ${mysql_cmd} -e "${sql_02}"
    echo "`date +'%Y-%m-%d %H:%M:%S'`  optimieze complete "
    echo
    
    echo "`date +'%Y-%m-%d %H:%M:%S'` after optimieze ,the table file is :"
    echo "`date +'%Y-%m-%d %H:%M:%S'` du -sh ${mysql_data_dir}/${db}/${tab}*"
    du -sh ${mysql_data_dir}/${db}/${tab}*
    echo "`date +'%Y-%m-%d %H:%M:%S'` ${sql_01} "
    ${mysql_cmd} -e "${sql_01}"
    echo "`date +'%Y-%m-%d %H:%M:%S'` select count(*) from ${tab} "
    ${mysql_cmd} -e "use ${db};select count(*) from ${tab};"
    echo
}

#定主函数,循环变量执行功能函数,并计数计时
function main(){
    echo "################ Start `date +'%Y-%m-%d %H:%M:%S'` ################"
    #定义起始时间变量和计数变量
    start_time_main=`date +'%Y-%m-%d %H:%M:%S'`
    var_01=0
    echo
    
    #循环执行功能函数, ${db_tab_list} 为一开始定义的循环变量范围
    for table_name in ${db_tab_list}
    do
        echo "`date +'%Y-%m-%d %H:%M:%S'` Begin excute the function optimize_tab for : ${table_name} . "
        optimize_tab ${table_name}
        
        var_01=$(( ${var_01} + 1 ))
        echo "`date +'%Y-%m-%d %H:%M:%S'` the table of sequence is ${var_01} and name is  ${table_name} ,has execute completed . "
        echo "--------------------------------"
        echo
    
    done
    
    #获取结束时间变量,计算总的时间和行数
    end_time_main=`date +'%Y-%m-%d %H:%M:%S'`
    run_time_s=$(( `date -d "${end_time_main}" +%s` - `date -d "${start_time_main}" +%s` ))
    rut_time_m=`echo "scale=2; ${run_time_s}/60" | bc`
    
    echo "`date +'%Y-%m-%d %H:%M:%S'` the job start on ${start_time_main} , end on ${end_time_main} , the run_time_s is ${run_time_s} . "
    echo "`date +'%Y-%m-%d %H:%M:%S'` All tables num is ${var_01} ,have run complete . All time is ${rut_time_m} minutes . "
    echo "################# End `date +'%Y-%m-%d %H:%M:%S'` #################"
    echo
}

#执行主函数
main
