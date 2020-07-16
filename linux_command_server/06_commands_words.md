

##############################
#  linux命令汇总表
##############################


命令总结
01. ip address show/ip a   检查网卡地址配置

02. ping                   测试网络连通性

03. nmtui                  图形界面修改网卡地址信息

04. exit                   注销

05. shutdown               关机命令
    shutdown -h 5          指定关机时间 （推荐）
	shutdown -r 5          重启主机时间 （推荐）
	shutdown -c            取消关机或重启计划
	shutdown -h now/0      立即关机
    shutdown -r now/0      立即重启	
	halt                   直接关机
	poweroff               直接关机 
	reboot                 直接重启

06. list=ls                查看文件或目录是否存在
	ls 文件或目录路径信息
	ls -d 目录信息
	ls -l 文件或目录信息  查看数据的属性信息
	ls -la 目录信息        查看目录中隐藏文件
	ls -lt 目录信息        将目录中的信息按照时间进行排序显示   
    ls -ltr 目录信息       按照时间信息,进行反向排序
    ls -lh	数据信息       显示的数据信息大小,以人类可读方式显示
	
07. make directory=mkdir   创建目录
    mkdir -p 多级目录       创建多级目录/忽略错误提示
	
	
	
08. manual=man             查看命令手册信息
    man 查看的命令
    NAME     命令作用说明
       mkdir - make directories
	SYNOPSIS 命令使用方法
       mkdir [OPTION]... DIRECTORY...
	DESCRIPTION 命令的参数解释
       -p, --parents
              no error if existing, make parent directories as needed
			  

09. change directory==cd   切换目录命令
    cd /xxx   绝对
	cd xxx    相对
	cd ..     上一级
	cd ../../ 上多级
	cd -      返回上一次所在路径
	cd/cd ~   返回到用户家目录
	
10. vi                   编辑文件内容
    vi 文件信息
	i   --- 进入编辑模式
	esc --- 退出编辑模式
	:wq --- 保存并退出
	:w
	:q
	:wq!--- 强制保存退出
	:q! --- 强制退出
	
	命令模式-->插入模式
	i   --- 表示从光标所在位置进入编辑状态    
	I   --- 表示将光标移动到一行的行首，再进入编辑状态
	o   --- 在光标所在行的下面，新起一行进行编辑
	O   --- 在光变所在行的上面，新起一行进行编辑
	a   --- 将光标移动到右边的下一个字符，进行编辑
	A   --- 将光标移动到一行的行尾，进入到编辑状态
	C   --- 将光标到行尾内容进行删除，并进入编辑状态
	cc  --- 将整行内容进行删除并进入编辑状态
	总结：移动光标位置，并进入编辑状态方法
	
	只移动光标，不进入编辑状态
	大写字母G   将光标快速切换尾部
	小写字母gg  将光标快速切换首部
	ngg         n表示移动到第几行
	$           将光标移动到一行的结尾
	0/^         将光标移动到一行的行首
	
	命令模式--底行模式
	:           输入一些命令
	/           进入搜索状态(向下搜索 n依次向下)
	?           进入搜索状态(向上搜索 n依次向上)
	
	
	特殊使用技巧:
	将一行内容进行删除(剪切)   	deletedelete=dd
	将多行内容进行删除(剪切)   	3dd
	将内容进行粘贴                 	p
    粘贴多次内容                   	3p
    复制一行内容                   yy
    复制多行内容                   3yy	
	操作错误如何还原     	       小写字母u  undo
	
		
11. echo                将信息输出到屏幕上
    echo "oldboy 深圳"
	
12. cat                 查看文件内容信息
    cat -n 文件信息     显示文件内容行号信息

13. cp                  复制文件或目录数据到其他目录中
    cp -r               递归复制目录数据
    \cp                 强行覆盖数据
	
14. rm                  删除数据命令
    rm -r               递归删除数据
	rm -f/\rm           强制删除数据,不需要进行确认

15. mv                  移动剪切数据信息

16. mount               对存储设备进行挂载
    mount 存储设备文件  挂载点
	umount              对存储设备进行卸载
	umount 挂载点

17. hostname            查看修改主机名称

18. hostnamectl         直接修改主机名称（centos7）
    hostnamectl set-hostname 主机名称
	
19. df                  查看磁盘挂载情况/查看磁盘使用情况
    df -h               以人类可读方式查看磁盘使用情况

20. source              立即加载文件配置信息 
                        /etc/profile
						/etc/bashrc
						~/.bashrc 
						~/.bash_profile
						/etc/sysconfig/i18n  --- centos6字符集配置文件
						/etc/locale.conf     --- centos7字符集配置文件
						
21. which               显示命令文件所在路径位置
    which 命令
     
22. export              定义环境变量
    export 环境变量=xxx
	
23. alias               设置系统别名命令
    alias 别名='命令信息'

24. unalias             取消系统别名命令
    unalias 别名 

25. head                查看文件前几行内容(默认前10行)
    head -5             查看前5行

26. tail                查看文件后几行内容(默认后10行)
    tail -5             查看后5行
	tail -f             一直追踪一个文件内容变化
	
27. yum                 下载并安装软件命令
    yum install -y 名称 			直接安装软件
	yum groupinstall -y 包组名称   	直接安装软件包组
	yum repolist        			查看yum源信息
	yum list            			查看哪些软件可以安装/查看所有系统已安装的软件
	yum grouplist       			查看哪些软件包组可以安装/查看所有系统已安装的软件包组
	yum --help                      help参数可以只显示命令的参数帮助信息
	yum provides locate             获取命令属于哪个软件大礼包

	
	
28. ps                  查看系统进程信息
    ps -ef              查看所有详细的进程信息
	
29. kill                删除指定进程
    kill pid            删除指定pid号码的进程
	kill -9 pid         强制删除指定pid号码的进程
	
30. free                查看内存命令
    free -h             人类可读方式查看

31. lscpu               查看CPU信息

32. w                   查看负载信息/查看系统用户登录信息	

33. useradd             创建用户(用户管理)
    useradd 用户名	
	
34. passwd             	设置用户密码命令
    passwd 用户名      	指定修改哪个用户的密码
	passwd             	修改当前用户密码
	
35. su                  切换用户命令
    su - 用户名称 
	
36. id                  检查创建的用户是否存在
    id  用户名
	
37. whoami              确认用户身份

38. rpm                 管理软件程序包的
    rpm -qa 软件名称   	查看软件大礼包是否安装成功
	rpm -ql 软件名称   	查看软件大礼包中都有什么
    rpm -qf 文件名称(绝对路径)   查看文件属于哪个软件大礼包

39. systemctl           管理服务程序的运行状态
    systemctl start 	服务名称  	--- 启动服务
	systemctl stop 		服务名称  	--- 停止服务
	systemctl restart 	服务名称 	--- 重启服务
	systemctl status 	服务名称  	--- 查看服务详细的运行状态
	systemctl disable   服务名称  	--- 让服务开机不要运行
	systemctl enable   	服务名称  	--- 让服务开机运行
	systemctl is-active   服务名称 	--- 检查确认服务是否运行
	systemctl is-enabled  服务名称 	--- 检查确认服务是否开机运行
	
40. localectl set-locale LANG=zh_CN.UTF-8   --- centos7修改字符集信息

41. less/more           逐行或逐页查看文件信息内容

42. whereis             查看命令所在路径以及命令相关手册文件所在路径

43. locate              查看文件所在路径信息
    updatedb            更新文件所在路径的索引数据库表
	
44. file                查看文件的类型
    file 文件信息
	
45. stat                查看数据详细属性信息
    stat file.txt       看到文件的三个时间信息
	
46. tar                 压缩数据命令
    -z           压缩类型
	-c           创建压缩包
	-v           显示过程
	-f           指定压缩文件路径
	-x           解压文件
	-t           查看压缩文件内容
	--exclude        排除指定文件不被压缩处理
	--exclude-from
	
47. xargs               分组命令 按照分组显示
    xargs -n1 <文件 

    总结: <
    tr xxx <
    xargs <	
	
48. tree                显示目录结构树
    tree -L 1           查看下几级目录机构
    tree -d             目录结构中目录信息
	
49. date                查看时间信息和修改时间信息
    date "+%F_%T"
	date -s             设置系统时间 
	date -d             显示未来或过去的时间信息

50. ln                  创建链接文件
    ln 源文件 链接文件 创建硬链接
	ln -s               创建软链接
	
51. wc                  统计命令
    wc -l               统计有多少行
	
52. chmod               修改文件目录数据权限信息
    chmod u/g/o 
	chmod a 
	
53. useradd             创建用户命令
    -s /sbin/nologin    指定用户shell登录方式
	-M                  不创建家目录
	-u                  指定用户uid信息
	-g                  指定用户所属主要组信息
	-G                  指定用户所属附属组信息
	-c                  指定用户注释信息

54. usermod             修改用户信息
    -s /sbin/nologin    指定用户shell登录方式
	-u                  指定用户uid信息
	-g                  指定用户所属主要组信息
	-G                  指定用户所属附属组信息
	-c                  指定用户注释信息   
	
55. userdel             删除用户信息
    userdel -r          彻底删除用户和家目录信息
	
56. groupadd            创建用户组 
    groupmod            修改用户组
	groupdel            删除用户组
	
57. chown               修改用户属主和属组的信息
    chown -R            递归修改用户属主和属组信息
	
58. sort                排序命令
    sort -n             按照数值进行排序
	sort -k1            按照指定列进行排序
	
59. dd                  模拟创建出指定大小的文件
    dd if=/dev/zero of=/tmp/oldboy.txt  bs=10M                    count=100
	    从哪取出数据  放到哪          占用1个block多少空间     总共使用多少个block
	
60. du                  查看目录的大小
    du -sh              汇总查看目录大小,以人类可读方式

	
高级命令：4剑客
00. 老四 find       查询文件所在路径
    find /oldboy -type 文件类型 -name "文件名称"
	find /oldboy -type f -mtime +10 -delete   --- 删除历史数据信息
	find /oldboy -type f -size  +10 -delete   --- 删除大于10k文件
	-maxdepth       查找目录层级的深度
	-inum           根据文件inode信息查找
	-exec           对查找出的数据进行相应处理
    -perm           根据权限查找数据信息
	-iname          忽略名称大小写
   
	
	
01. 老三 grep 文件  对信息进行过滤筛选
    grep -B n       显示指定信息前几行内容
    grep -A n       显示指定信息后几行内容
    grep -C n       显示指定信息前后几行内容
	grep -c         显示指定信息在文件中有多少行出现
	grep -v         进行取反或者排除
	grep -E/egrep   识别扩展正则符号
	grep -o         显示过滤过程信息
	grep -n         过滤信息并显示信息行号
	grep -i         过滤信息忽略大小写
	
	老二 sed
	
	老大 awk



系统中的常见环境变量
1.  PATH                方便命令的使用

2.  PS1                 定义提示符的信息或格式
	
快捷方式：
01. ctrl+c             	中断命令执行操作过程
02. ctrl+l             	清屏操作
03. ctrl+d             	注销功能
04. tab               	补全快捷键 补全目录路径或文件名称信息/命令   
05. 方向键上下         	调取之前输入过的历史命令
06. ctrl+a              快速将光标移动到行首 a b c d
07. ctrl+e              快速将光标移动到行尾
08. ctrl+左右方向键    	按照一个英文单词进行移动光标
09. esc+.               将上一个命令最后一个信息进行调取
10. ctrl+u     			将光标所在位置到行首内容进行删除（剪切）
11. ctrl+k     			将光标所在位置到行尾内容进行删除（剪切）
12. ctrl+y     			粘贴剪切的内容
13. ctrl+s     			xshell进入到了锁定状态 suo锁
14. ctrl+q     			解除锁定状态           quit推出锁定状态
15. ctrl+r              快速搜索历史命令						
    

系统特殊符号
~                          家目录符号
..                         上一级目录
.                          当前目录
>                          标准输出重定向符号
>>                         标准输出追加重定向符号
2>                         错误输出重定向符号
2>>                        错误输出追加重定向符号
<                          标准输入重定向符号
<<                         标准输入追加重定向符号


&&                         代表前一个命令执行成功后，再执行后面的命令
;                          代表前一个命令执行之后,再执行后面的命令
#                          代表将配置文件信息进行注释
                           在命令提示符中表示超级管理员身份
$                          用于加载读取变量信息
                           表示一行的结尾
						   在命令提示符中表示普通用户身份
!                          强制
``反引号                   将引号中命令执行结果交给引号外面的命令进行处理
| 管道符号                 将前一个命令的结果交给管道后面命令进行处理
{} 序列符号(通配符)        通配符号,显示数字或字母的序列信息   
                     

linux系统的经典语录
01. 一切从根开始

02. 在linux系统中一切皆文件 
    目录--特殊的文件 存储设备--特殊文件  命令--命令文件

03. linux系统中服务配置文件被修改之后，不会立即生效
    需要重启服务（重现加载读取配置文件过程），才能使配置文件的修改生效
	
04. 在系统中对配置进行永久修改时，都需要修改配置文件
    在命令行的修改，大部分情况都是临时修改

05. 学习好运维：听话 出活

06. 在企业中运维主要干什么? 5000 
    01. 部署服务 命令       5000-6000
	02. 排错能力            9000 
	03. 服务或系统优化能力  10000 以上
	04. 数据的分析能力      15000 以上
	05. 架构能力            20000 以上
	
07. 一种错误情况:你以为
    外网不通了 ping 223.5.5.5 yum源文件
	
	
08. 安全和系统性能(管理系统效率)是成反比的
    系统越安全    管理起来效率越低
	系统越不安全  管理起来效率越高
	
09. 在编写linux配置文件信息时,能复制就不要手敲	
	
10. 企业工作中出现严重异常问题：
    放运维排错的大招：
    a 服务重新安装 
    b 重启系统 reboot
    c 重新安装系统	
	
11. 系统中不是所有命令都可以对文件进行编辑修改
    vim 文件  sed -i 文件  cat >> echo >> > 





##############################
#  linux常用英文单词
##############################


01. default  默认 
	
02. style    风格	

03. unit     单元

04. install  安装

05. enabled  启动，启用

06. disable  关闭

07. test     测试

08. media    介质/光盘介质

09. troubleshooting   排错

10. system   系统

11. network  网络

12. hostname 主机名称

13. configure/config    配置

14. general             通用配置

15. setting             设置

16. manual              手动

17. save                保存

18. apply               应用

19. destination         目标

20. standard partition  标准分区

21. boot                启动/引导

22. cancel              取消

23. accept changes      接受改变

24. security policy     安全策略

25. begin               开始

26. complete            完成

27. reboot              重启

28. login               登录

29. edit a connection   编辑一个连接/编辑网络配置信息

30. back                返回

31. quit                退出

32. start               开启
    restart             重启
	stop                停止
	status              检查服务状态
========================================================

33. device              设备

34. Connection failed       连接失败
    Connection established  连接成功
	
35. active              服务激活状态
    running             服务运行状态
    inactive            服务未激活状态
	
36. command not found   命令不能找到

37. Failed              失败

38. Permission denied   权限阻止

39. halt                系统关闭

40. No such file or directory   没有这个文件或目录

41. File exists         文件已经存在

42. insert              插入

43. omitting directory  忽略目录

44. force               强制

45. /dev/sr0 is write-protected, mounting read-only 
    /dev/sr0 是一个写保护的设备，挂载之后目录是一个只读状态

46. give root password for maintenance
    需要你输入一个root用户密码，并且会进入到维修模式

47. Memory              内存

48. info                信息

49. Average             平均

50. load                负载

51. Warning: Changing a readonly file  
    警告:    你正在修改的文件是一个只读文件

52. 'readonly' option is set (add ! to override)
    只读文件,如果想进行保存需要加上一个参数 !(强制)	

53. Permission denied   权限不足,权限阻止

54. query               查询

55. reverse             反向 逆向

56. before              在..之前

57. after               在..之后

58. center              中心

59. count               计数/会计

60. exclude             排除
    include             包含


