#!/bin/sh
#该脚本与从Mysql数据库中获取指定列表的用户名和主机授权
#the $file_name file format is a list :  user host
#the input can use the sql : select user,host from mysql.user where $where_clause ;
#the ouput can into a file and use sed comand : sed -i 's/old_ip/new_ip/g' $outpu_file

source /etc/profile
file_name="/home/mysql/user_host.txt"

cat "${file_name}" | while read line
do
    #echo $line
    host=`echo $line | awk '{print $1}'`
    ip=`echo $line | awk '{print $2}'`
    #echo $host
    #echo $ip
    show_grant=`echo "show grants for ?${host}?@?${ip}?" | sed "s/?/'/g"`
    echo "-- ${show_grant}"
    mysql  -sN -e "${show_grant}" | awk '{print $0 ";"}'
    echo
    
done
