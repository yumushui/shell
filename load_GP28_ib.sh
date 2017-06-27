#!/bin/sh

#定义路径，加载相关文件
filepath=$(cd "$(dirname "$0")"; pwd)

#source /etc/profile
source /home/gpadmin/.bash_profile 

source ${filepath}/load_kfk.conf
#source ${filepath}/kfk_tab_list
source ${filepath}/gp_load_insert.sql

###根据脚本是否输入值来判断和确定需要循环的文件ID列表
if [ $# -eq 0 ] ;then
    echo " $0 has 0 parameter , use ${filepath}/kfk_tab_list to get KFK ID . "
    #KFK_ID_LIST=`cat ${filepath}/kfk_tab_list`
    #对于先加载到GP，后加载到Inforbright的CTR列表，单独用一个参数文件
    KFK_ID_LIST=`cat ${filepath}/CTR_GP28_IB.list`
    echo "the KFK_ID_LIST is : ${KFK_ID_LIST} "
elif [ $# -eq 1 ];then
    echo " $0 has 1 parameter , use $1 as the KFK ID . "    
    KFK_ID_LIST=$1
    echo "the KFK_ID_LIST is : ${KFK_ID_LIST} "
else
    echo " $0 has not 0 and 1 parameter , the sh can not execute . "
    echo " USAGE: $0 or $0 KFK_ID"
    echo " e.g.: $0 1001"
    exit 1;
fi


#定义加载函数，暂未使用
function GP_Insert_Load(){
    local GP_Tab_NO=$1
    GP_Cmd -e "${GP_Tab_NO}_SQL"
    
}

#定义处理函数，暂未使用
function mv_load_arch(){
    #对于存在需要处理的文件，进行移动和加载操作处理
    #获取需要处理的文件名的列表
    echo ""
}

# 定义判断函数，需要传入一个文件编号参数
function check_load(){
    #生成文件格式名
    kfk_tab_ID=$1
    echo "the kfk_tab_list no. is ${kfk_tab_ID}"
    File_Name_Format="Csv_bill_${kfk_tab_ID}*.txt"
    echo "the kfk file name formatis : ${File_Name_Format} "
    
    #获取符合条件的文件个数
    File_Num=`find ${Dir_Begin} -type f -name "${File_Name_Format}" -mmin +${Modify_Mmin_Limit} | wc -l`
    echo "find ${Dir_Begin} -type f -name ${File_Name_Format} -mmin +${Modify_Mmin_Limit} | wc -l"
    echo "the number of files that are needed to move is: ${File_Num} "
    
    #根据获取的文件个数进行判断处理
    if [ ${File_Num} -eq 0 ];then
        echo "初始目录 ${Dir_Begin} 中，没有 ${File_Name_Format} 类文件，不用执行移动、加载操作"
    else
        echo "初始目录 ${Dir_Begin} 中，存在 ${File_Num} 个 ${File_Name_Format} 类文件，需要执行移动、加载操作"
        
        #开始时间参数
        DAY_Date=`date +"%Y%m%d"`
        START_TIME=`date +"%Y-%m-%d %H:%M:%S"`
        
        #开始前，行数与记录数
        Tol_File_Rows=0
        
        GP_Select_SQL=`eval echo '$'"SQL_Select_${kfk_tab_ID}"`
        echo ${GP_Select_SQL}
        GP_Rows_Before=`${GP_Cmd} -c "${GP_Select_SQL}"  | awk 'NR==3{print}'`
        
        #获取需要处理的文件名的列表
        Files_List=`find ${Dir_Begin} -type f -name "${File_Name_Format}" -mmin +${Modify_Mmin_Limit} -exec ls {} \;`
        echo "需要循环处理的文件列表，获取方法为："
        echo "find ${Dir_Begin} -type f -name ${File_Name_Format} -mmin +${Modify_Mmin_Limit} -exec ls {} \;"
        echo 
        
        #循环逐个处理文件
        for file_a in ${Files_List}
        do
            echo "进行文件 ${file_a} 的移动、加载、归档的处理过程"
            #移动文件
            sudo chown gpadmin:gpadmin "${file_a}"
            wc -l "${file_a}"
            File_row_wc=`wc -l "${file_a}" | awk '{print $1}'`
            mv "${file_a}" ${Dir_Gpfdist}
            echo " move successful !"
            #加载文件
            GP_Insert_SQL=`eval echo '$'"SQL_Insert_${kfk_tab_ID}"`
            #echo ${GP_Insert_SQL}
            ${GP_Cmd} -c "${GP_Insert_SQL}"
            echo " load successful !"
            #归档文件,对于先加载到GP，然后加载到Inforbright的数据，归档只需归档到Inforbright初始加载表中即可
            #mv ${Dir_Gpfdist}/${File_Name_Format} ${Dir_Arch}/${kfk_tab_ID}
            mv ${Dir_Gpfdist}/${File_Name_Format} /data/ActionData/IB_load
            echo " arch successful !"
            
            #将处理完的文件名记录到归档文件中
            if [ ! -f "${Dir_Arch}/${kfk_tab_ID}_successful.txt" ];then
                touch "${Dir_Arch}/${kfk_tab_ID}_successful.txt"
            fi
            echo "${file_a}" >> ${Dir_Arch}/${kfk_tab_ID}_successful.txt
            
            #增加加载行数
            Tol_File_Rows=$(( $Tol_File_Rows + $File_row_wc ))
            echo ${Tol_File_Rows}
            echo 
        done
        
        #结束后，行数与记录参数
        GP_Rows_After=`${GP_Cmd} -c "${GP_Select_SQL}"  | awk 'NR==3{print}'`
        GP_Rows_Add=$(( $GP_Rows_After - $GP_Rows_Before ))
        
        #结束时间参数
        END_TIME=`date +"%Y-%m-%d %H:%M:%S"`
        
        START_TIME_LINUX=`date -d  "$START_TIME" +%s`
        END_TIME_LINUX=`date -d  "$END_TIME" +%s`
        TIME_interval=$(( $END_TIME_LINUX - $START_TIME_LINUX))
        TIME_interval_minute=`echo "scale=2; ${TIME_interval}/ 60"|bc`
        TIME_interval_hour=`echo "scale=2; ${TIME_interval}/3600"|bc`
        
        #将任务结果插入到日志表中
        ${MySQL_Cmd} <<EOF
        insert into olap.GP_kfk_load_log(BillType,DateNum,file_num,file_rows,gp_rows_before,gp_rows_after,gp_rows_add,start_time,end_time,runtime_s,runtime_m)
        values (${kfk_tab_ID},${DAY_Date},${File_Num},${Tol_File_Rows},${GP_Rows_Before},${GP_Rows_After},${GP_Rows_Add},"${START_TIME}","${END_TIME}",${TIME_interval},${TIME_interval_minute});
EOF
        echo "Use sql to insert the result into mysql table:"
        echo "insert into olap.GP_kfk_load_log(BillType,DateNum,file_num,file_rows,gp_rows_before,gp_rows_after,gp_rows_add,start_time,end_time,runtime_s,runtime_m)
        values (${kfk_tab_ID},${DAY_Date},${File_Num},${Tol_File_Rows},${GP_Rows_Before},${GP_Rows_After},${GP_Rows_Add},${START_TIME},${END_TIME},${TIME_interval},${TIME_interval_minute});"
        echo 
             
        #本类文件处理完毕，提示结束
        echo "All ${kfk_tab_ID} files number is ${File_Num} , had moved, loaded and arched Sucessful !"
        echo "${kfk_tab_ID} files all file rows is : ${Tol_File_Rows} ,start on ${START_TIME} , end on ${END_TIME} ."
        echo "${kfk_tab_ID} in greenplum tables before rows is : ${GP_Rows_Before} ; after rows is: ${GP_Rows_After} ; add rows is : ${GP_Rows_Add}."
        echo "The time of execting the job on ${DAY_Date} is : ${TIME_interval} seconeds ; ${TIME_interval_minute} minutes ; ${TIME_interval_hour} hours ."
        echo 
        
    fi
    
}

function Load_IB_after_GP(){
    echo "##### Begin : execute the shell script to load files into Inforbright:"
    date +"%Y-%m-%d %H:%M:%S"
    echo

    echo "/bin/sh /data/scripts/shell/fish_kfk/ctr_gp_inforbright.sh  &>> /data/load_logs/ctr_gp_inforbright.log"
    echo "excuting ... ..."
    /bin/sh /data/scripts/shell/fish_kfk/ctr_gp_inforbright.sh  >> /data/load_logs/ctr_gp_inforbright.log
    echo

    echo "### Complete : execute the shell script to load files into Inforbright !"
    date +"%Y-%m-%d %H:%M:%S"
    echo
}


#定义主函数
function main(){
    echo "########### Start ###########"
    date +"%Y-%m-%d %H:%M:%S"
    
    #读取文件，循环调用加载CTR文件到GP中
    for file_id in ${KFK_ID_LIST}
    do
        echo "Begin to check and load ${file_id} files"
        check_load ${file_id}
        echo "-----------------"
        echo
    done

    #CTR文件加载到GP后，调用脚本加载到Inforbright中
    Load_IB_after_GP
    
    date +"%Y-%m-%d %H:%M:%S"
    echo "########### End ###########"
    echo 
}

#执行主函数
main
