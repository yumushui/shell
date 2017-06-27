#!/bin/sh
#create by zhaofx on 20170305
#this scripts is used to  load the files created by CTR kfk program per 10 minutes into mysql inforbright instance. 

filepath=$(cd "$(dirname "$0")"; pwd)

source /etc/profile
source ${filepath}/load_kfk.conf
echo "config file is : ${filepath}/load_kfk.conf"


# 查找并移动超时文件函数
function  find_mv_file(){
    ## 执行for循环，遍历处理每个类型的表
    for (( i=1; i<=${Load_Tab_Num}; i++ ));do
        File_Name=`grep "Load_Tab_$i" ${filepath}/load_kfk.conf | awk -F "=" '{print $2}'`
        Tab_Name=`grep "MySQL_Tab_$i" ${filepath}/load_kfk.conf | awk -F "=" '{print $2}'`        
        echo "移动前,文件数为："
        find /data/ActionData/TKData -type f -name "${File_Name}" -mmin +20 | wc -l

        echo "将 ${Dir_Begin} 中，类型为file，文件名为 ${File_Name} ,有 ${Modify_Mmin_Limit} 分钟没有修改过的文件，进行移动操作 "
        find ${Dir_Begin} -type f -name "${File_Name}" -mmin +${Modify_Mmin_Limit} -exec mv {} ${Dir_Gpfdist}  \;
        echo "find ${Dir_Begin} -type f -name ${File_Name} -mmin +${Modify_Mmin_Limit} -exec mv {} ${Dir_Gpfdist}  \;"

        echo "移动后,文件数为："
        find /data/ActionData/TKData -type f -name "${File_Name}" -mmin +20 | wc -l
        echo ""
    done
    
    echo "将 ${Modify_Mmin_Limit} 分钟无修改文件移动到 ${Dir_Gpfdist} 完毕。 "
    echo ""
}


# 加载并归档函数
function  load_arch_file(){
    ## 执行for循环，遍历处理每个类型的表
    for (( i=1; i<=${Load_Tab_Num}; i++ ));do
        File_Name=`grep "Load_Tab_$i" ${filepath}/load_kfk.conf | awk -F "=" '{print $2}'`
        Tab_Name=`grep "MySQL_Tab_$i" ${filepath}/load_kfk.conf | awk -F "=" '{print $2}'`     
        
        # 判断归档目录中是否存在要加载的文件
        if [ ! -f ${Dir_Gpfdist}/${File_Name} ];then
            #ls ${Dir_Gpfdist}/${File_Name} #echo "加载目录 ${Dir_Gpfdist} 中，没有 ${File_Name} 类文件，不用执行加载操作"
            echo "加载目录 ${Dir_Gpfdist} 中，没有 ${File_Name} 类文件，不用执行加载操作"
        else
            echo "加载目录 ${Dir_Gpfdist} 中，存在 ${File_Name} 类文件 执行加载过程"
            > /tmp/tmp_file.txt
            ls ${Dir_Gpfdist}/${File_Name} >> /tmp/tmp_file.txt
            cat /tmp/tmp_file.txt | while read myline
            do
                echo "加载文件 ${myline} 到 ${MySQL_DB} 库下的表 ${Tab_Name} 中"
                
                ${MySQL_Cmd} <<EOF
                load data local infile "${myline}" into table ${MySQL_DB}.${Tab_Name}  fields terminated by '|';
EOF
                
                if [ $? -eq 0 ];then
                    mv "${myline}" ${Dir_Arch}
                    echo "文件 ${myline} 加载完毕，归档到目录 ${Dir_Arch} 中"
                else
                    echo "文件 ${myline} 没有加载完毕，暂时保留在加载目录，不归档"
                fi
            done
            
        fi
        
        echo " ${File_Name} 类文件加载流程完毕，执行下一类文件"
        echo ""
        
    done
    
    echo "将所有文件加载到MySQL，并归档文件到 ${Dir_Arch} 完毕。"
    echo ""
    
}

# 定义主函数
function  main(){
    echo "################ Start ################"
    date "+%Y_%m_%d %H:%M:%S"    
    echo ""
    
    echo "***执行数据移动函数***"
    find_mv_file
    
    echo "***执行数据加载和归档函数***"
    load_arch_file
    
    echo "***执行数据文件归档***"
    mv /data/ActionData/Fish_Arch/Csv_bill_2001_*.txt /data/ActionData/Fish_Arch/2001/
    mv /data/ActionData/Fish_Arch/Csv_bill_3001_*.txt /data/ActionData/Fish_Arch/3001/
    echo "mv /data/ActionData/Fish_Arch/Csv_bill_2001_*.txt /data/ActionData/Fish_Arch/2001/"
    echo "mv /data/ActionData/Fish_Arch/Csv_bill_3001_*.txt /data/ActionData/Fish_Arch/3001/"
    
    
    date "+%Y_%m_%d %H:%M:%S"    
    echo "################ End ################"
    echo ""
}

# 执行主函数
main
