

##############################
#  20-操作系统用户管理
##############################

00. 课程介绍部分
    1) 常见面试题 (系统启动流程 服务开机自启方法)
	2) 用户管理概念
	3) 用户权限说明(*)
	4) 企业中用户管理注意事项

    	
01. 课程知识回顾
    1) awk命令概念说明
	   擅长取列 擅长统计分析日志
	   awk命令语法: awk [参数] '模式{动作}' 文件
	   awk执行原理: BEGIN{} END{}
	2) awk实际解决了一些问题
	   awk匹配查询信息 ==grep
	   ~ !~  指定列进行匹配
       awk匹配替换信息 
	   gsub(/要替换的信息/,"替换的内容",将第几列进行替换)
	   awk匹配删除信息 
	   awk '!/oldboy/'
    3) awk统计分析能力
	   累加运算: i=i+1 i++
	   求和运算: i=i+$n  
    01 求出测试文件中 所有人第一次捐款的总额和第三次捐款总额
       显示表头 
       第一总额  第三次总额 	
       xxx        xxxx	 
	   awk -F ":" 'BEGIN{print "第一次总额","第三次总额"};/.*/{print $2,$4}'  awk_test.txt
	   [root@oldboyedu ~]# awk -F ":" 'BEGIN{print "第一次总额","第三次总额"}{a=a+$2;b=b+$4}END{print a,b}' awk_test.txt|column -t
       第一次总额  第三次总额
       2130        1661

02. 常见面试题: 
    系统的启动流程:
    centos6
	01. 加电自检
	    检查服务器硬件是否正常
    02. MBR引导
	    读取磁盘的MBR存储记录信息,引导系统启动
	03. grup菜单
	    选择启动的内核/进行单用户模式重置密码
    04. 加载系统内核信息
	    可以更好的使用内核控制硬件
	05. 系统的第一个进程运行起来 init (串行)
	    init进程控制后续各种服务的启动: 启动顺序 网络服务 sshd 
	
	06. 加载系统运行级别文件/etc/inittab
	07. 初始化脚本运行
	    初始化系统主机名称 和 网卡信息
	08. 运行系统特殊的脚本
	    服务运行的脚本 
	09. 运行mingetty进程
	    显示开机登录信息界面
	
	
    centos7	
	01. 加电自检
	    检查服务器硬件是否正常
    02. MBR引导
	    读取磁盘的MBR存储记录信息,引导系统启动
	03. grup菜单
	    选择启动的内核/进行单用户模式重置密码
    04. 加载系统内核信息
	    可以更好的使用内核控制硬件	
	05. 系统的第一个进程运行起来 systemd (并行)
	    服务启动的时候,同时一起启动
	06. 读取系统启动文件
	    /etc/systemd/system/default.target
	07. 读取系统初始化文件
	    /usr/lib/systemd/system/sysinit.target
	08. 使服务可以开机自启动
	    /etc/systemd/system 加载此目录中的信息,实现服务开机自动启动
	09. 运行mingetty进程
	    显示开机登录信息界面

03. 用户管理章节
    用户概念介绍:
    管理员用户  root    0      	权利至高无上
    虚拟用户    nobody  1-999 	管理进程  没家目录 不能登录系统
    普通用户    oldboy	1000+   权利有限
    
	r read
	w write
	x execute
	
	文件信息:
	r  可以读文件的内容
	w  可以编辑文件的内容
	x  执行这个文件(脚本文件)
	
	touch oldboy_root.txt -- 属主是root
	touch oldboy.txt --      属主是oldboy
	                         其他用户oldgirl
	环境准备:
	[root@oldboyedu ~]# touch oldboy_root.txt
    [root@oldboyedu ~]# ll oldboy_root.txt 
    -rw-r--r--. 1 root root 0 Apr 23 10:02 oldboy_root.txt
    [root@oldboyedu ~]# touch oldboy.txt
    [root@oldboyedu ~]# ll oldboy.txt 
    -rw-r--r--. 1 root root 51 Apr 23 10:02 oldboy.txt
    [root@oldboyedu ~]# chown oldboy oldboy.txt
    [root@oldboyedu ~]# ll oldboy.txt 
    -rw-r--r--. 1 oldboy root 51 Apr 23 10:02 oldboy.txt
    [root@oldboyedu ~]# chmod 000 oldboy_root.txt 
    [root@oldboyedu ~]# chmod 000 oldboy.txt 
    [root@oldboyedu ~]# ll oldboy_root.txt 
    ----------. 1 root root 0 Apr 23 10:02 oldboy_root.txt
    [root@oldboyedu ~]# ll oldboy.txt 
    ----------. 1 oldboy root 51 Apr 23 10:02 oldboy.txt

    文件权限配置的结论:
	01. root用户对所有文件有绝对的权限,只要有了执行权限,root用户可以无敌存在
	02. 对于文件来说,写的权限和执行的权限,都需要有读权限配合
	03. 如何想对文件进行操作,必须对文件赋予读的权限
	
	
	目录信息:
	r  读目录中的文件属性信息
	w  可以在目录中添加或删除文件数据信息
	x  是否可以进入到目录中
	
	当目录赋予读的权限
	[oldboy@oldboyedu ~]$ ll /home/oldboy/oldboy_dir/文件 
    ls: cannot access oldboy_dir/oldboy.txt: Permission denied
    total 0
    -????????? ? ? ? ?            ? oldboy.txt
	
	/           inode (5 r_x) -- block (home)
    home        inode (5 r_x) -- block (oldboy)
    oldboy   	inode (7 rwx) -- block (oldboy_dir)
	oldboy_dir  inode (4 r--) -- block (目录中文件名称)
	无法进入目录
	oldboy.txt  inode 目录中的文件inode信息无法获取,会显示文件属性信息为??? 
	
	两个权限问题:
	/oldboy/oldboy.txt 
	01. oldboy.txt   权限 rwx--xr--  属主如何操作文件  其他用户可以如何操作这个文件

    目录权限配置的结论:
	01. root用户对目录信息有绝对权限
	02. 对于目录来说,写的权限和读的权限,都需要有执行权限配合
	03. 如何想对目录进行操作,必须对目录赋予执行的权限

    一个普通文件默认权限: 644  保证属主用户对文件可以编辑  保证其他用户可以读取文件内容
	一个目录文件默认权限: 755  保证属主用户对目录进行编辑  保证其他用户可以读取目录中的信息,可以进入到目录中

    文件目录数据设置权限的方法:
	1) 根据用户信息进行设定 (属主 属组 其他用户)
	   属主-user       u  
	   属组-group      g 
	   其他用户-other  o 
	   chmod u+r/w/x u-r/w/x u=rw
	   chmod g+r/w/x u-r/w/x u=rw
       chmod o+r/w/x u-r/w/x u=rw
	2) 根据用户进行批量设定
	   数值设定:
	   [root@oldboyedu ~]# chmod 761 oldboy.txt
       [root@oldboyedu ~]# ll oldboy.txt
       -rwxrw---x. 1 root root 0 Apr 23 11:42 oldboy.txt

	   字符设定:
	   [root@oldboyedu ~]# chmod a=x oldboy.txt
       [root@oldboyedu ~]# ll oldboy.txt
       ---x--x--x. 1 root root 0 Apr 23 11:42 oldboy.txt

    问题一: 为什么创建的文件和目录权限一致
	目录权限都是 755
	文件权限都是 644 
	
	[root@oldboyedu ~]# umask 
    0022

	默认文件权限: 666 - 022 = 644
	umask数值是奇数  666 - 033 = 633 + 11 = 644
	umask数值是偶数  666 - 022 = 644
	
    默认目录权限: 777 - 022 = 755	
	umask数值是奇数  777 - 033 = 744
	umask数值是偶数  777 - 022 = 755	
	
	问题二: 如何永久修改umask信息
	vim /etc/profile
	if [ $UID -gt 199 ] && [ "`/usr/bin/id -gn`" = "`/usr/bin/id -un`" ]; then
      umask 002
    else
      umask 022  --- 可以永久修改umask数值
    fi
	
	系统中的一个特殊的目录: /etc/skel  样板房 
	[root@oldboyedu ~]# ll /etc/skel/ -a
    total 24
    drwxr-xr-x.  2 root root   62 Apr 11  2018 .
    drwxr-xr-x. 81 root root 8192 Apr 23 12:11 ..
    -rw-r--r--.  1 root root   18 Apr 11  2018 .bash_logout   当系统退出登录状态会执行的命令
    -rw-r--r--.  1 root root  193 Apr 11  2018 .bash_profile  别名和环境变量(只针对某个用户)  家规
    -rw-r--r--.  1 root root  231 Apr 11  2018 .bashrc        别名和环境变量(只针对某个用户)  家规
 
	useradd oldgirl --> /home/oldgirl/ --> 目录中的数据内容会参考/etc/skel目录中的信息
	
	/etc/skel目录作用:
	01. 目录中可以存储运维操作规范说明文件
	02. 调整命令提示符信息
	    出现问题: 命令提示符: -bash-4.2$ 
    -bash-4.2$ ll /etc/hosts
    -rw-r--r--. 2 root root 192 Apr 15 12:19 /etc/hosts
    -bash-4.2$ cp /etc/skel/.b* /home/new01/
    -bash-4.2$ exit
    logout
    [root@oldboyedu ~]# 
    [root@oldboyedu ~]# su - new01
    Last login: Tue Apr 23 12:23:36 CST 2019 on pts/2

	
04. 课程知识总结:
    1) 系统的开机流程 (centos6 centos7)
	2) 系统用户概念
	   a 用户的分类
	   b 用户的权限(文件-权限 目录-权限)
	     读写数据原理
	     / -- inode/block -- oldboy 
       c umask是什么? 控制文件或目录的默认权限
	     如何永久修改 
    3) 系统的特殊目录 /etc/skel (样板房)
	
作业:
01. chmod命令使用方法进行总结



##############################
#  21-操作系统用户权限
##############################


00. 课程介绍部分
    1) 用户相关的命令 
	2) 用户权限(如何让普通用户可以像root用户一样进行操作)
    
01. 课程知识回顾
    1) 系统启动流程
       1开机自检-2MBR引导???--3grub菜单(内核 进入单用户模式)---4加载内核
	   --->5启动系统的第一个进程init/systemd--->6自动加载系统运行级别
	   --->7加载初始化脚本--->8运行相应的自启动服务--->9加载显示登陆界面进程
	2) 系统用户管理
       a 用户的分类
       b 数据文件权限说明(rwx)
         文件权限:(更多关注一定要有read权限)
         read  读文件内容的能力	(有了读文件block能力)
         write 写文件内容的能力(有了读文件block能力)	重命名文件???	 
		 execute 执行文件的能力(脚本文件)
		 补充: 文件是否可以编辑查看,和上一级或上n级目录有关
		 读取文件数据原理 / oldboy/ oldboy01/ oldboy.txt
		 
		 目录权限:(更多关注一定要有执行权限)
		 read  读取目录下文件属性信息
		 write 可以在目录中创建或删除数据
		 execute 可以切换进入到目录中
	3) 文件数据权限修改方法
       chmod u/g/o + - = rwx   --- 针对不同用户进行设置
       chmod a + - = rwx       --- 全部用户统一设置权限
       chmod 644 xxx           --- 全部用户统一设置权限(更加灵活)	 
    4) 文件的默认权限是如何设置
       文件是: 644  666-umask(奇数+1)
       目录是: 755  777-umask
       umask(内置命令): 可以影响系统数据默认权限
	   umask如何永久设置
	   if [ $UID -gt 199 ] && [ "`/usr/bin/id -gn`" = "`/usr/bin/id -un`" ]
	          条件一             
	   then
           umask 002
       else
           umask 022
       fi
	     
	   $UID: 显示当前登录系统用户id数值
	   判断比较符号
	   -gt greater than  >
	   -lt less than     <
	   -eq equal         ==
	   -ge greater && equal >=
	   -le less && equal    <=
	   -ne not equal     <>
	   /usr/bin/id -gn  -- 显示当前用户的组名
	   /usr/bin/id -un  -- 显示当前用户名称
	   
	   if 判断的条件(有>100万) && 长得帅
	   then
	      娶到好看的女生
	   else
	      是个女的就行
	   fi
	   
	5) 特殊的目录: /etc/skel 样板房
	   用户家目录都参照样板房设计
	   用户家目录中特殊文件:
	   -rw-------.  1 oldboy oldgirl 1454 Apr 24 09:12 .bash_history   --- 历史命令记录文件
	   曾经输入的历史命令保存位置:
	   01. 保存在内存中      histroy
	       history -c
	   02. 保存在磁盘文件中: .bash_history 
	   
       -rw-------.  1 oldboy oldgirl  651 Apr 23 10:16 .viminfo        --- vim样式设置
	   自动加载文件样式信息
	   #!/bin/bash
       # 编写人: oldboy
       # 编写时间: 2019
       # 脚本作用: 

02. 系统中和用户相关的文件
    /etc/passwd*****  --- 记录系统用户信息文件 
    [root@oldboyedu oldboy]# head /etc/passwd
    root	:x	:0	:0	:root		:/root				:/bin/bash
    bin		:x	:1	:1	:bin		:/bin				:/sbin/nologin
    daemon	:x	:2	:2	:daemon		:/sbin				:/sbin/nologin
    adm		:x	:3	:4	:adm		:/var/adm			:/sbin/nologin
    lp		:x	:4	:7	:lp			:/var/spool/lpd		:/sbin/nologin
	01      02  03  04  05          06                  07
	
	第一列: 用户名
	第二列: 用户密码信息
	第三列: 用户的uid信息
	第四列: 用户的gid信息
	第五列: 用户的注释信息 
	        mysql(manager database user)
			www  (manager web server)
	第六列: 用户家目录信息
	第七列: 用户登录系统方式
            /bin/bash       --- 通用的解释器
			/usr/bin/sh     --- 等价于/bin/bash
			/usr/bin/bash
            /sbin/nologin       --- 无法登录系统
            /usr/sbin/nologin
	/etc/shadow*      --- 系统用户密码文件
	/etc/group*       --- 组用户记录文件
	/etc/gshadow*     --- 组用户密码信息
       	   
03. 系统用户相关命令
    a 创建用户命令
	  useradd oldboy   普通用户被创建出来
      useradd oldboy01 -M -s /sbin/nologin 虚拟用户被创建出来
      -M 不创建家目录
	  -s 指定使用的shell方式
	  [root@oldboyedu oldboy]# useradd Alex01 -M -s /sbin/nologin
      [root@oldboyedu oldboy]# id Alex01
      uid=1067(Alex01) gid=1067(Alex01) groups=1067(Alex01)
      [root@oldboyedu oldboy]# grep Alex01 /etc/passwd
      Alex01:x:1067:1067::/home/Alex01:/sbin/nologin
      [root@oldboyedu oldboy]# ll /home/Alex01 -d
      ls: cannot access /home/Alex01: No such file or directory
      
	  useradd Alex03 -u 2000
	  -u 指定用户uid数值信息
      [root@oldboyedu oldboy]# id Alex03
      uid=2000(Alex03) gid=2000(Alex03) groups=2000(Alex03)
	  
	  useradd Alex04 -u 2001 -g Alex02
	  -g 指定用户所属的主要组信息
      [root@oldboyedu oldboy]# id Alex04
      uid=2001(Alex04) gid=1068(Alex02) groups=1068(Alex02)
      [root@oldboyedu oldboy]# useradd Alex05 -u 2002 -g 1068
      [root@oldboyedu oldboy]# id Alex05
      uid=2002(Alex05) gid=1068(Alex02) groups=1068(Alex02)

      [root@oldboyedu oldboy]# useradd Alex07 -u 2004 -g Alex02 -G Alex03
	  -G 指定用户所属的附属组信息
      [root@oldboyedu oldboy]# id Alex07
      uid=2004(Alex07) gid=1068(Alex02) groups=1068(Alex02),2000(Alex03)

      useradd mysql -s /sbin/nologin -M -c "manager database"
	  -c 添加指定用户注释说明信息
      [root@oldboyedu oldboy]# grep mysql /etc/passwd
      mysql:x:2005:2005:manager database:/home/mysql:/sbin/nologin

    b 修改用户信息
	  usermod
	  -s    修改用户的登录方式
	  -g    修改用户的主要的组信息
	  -G    修改用户的附属组信息
	  -c    修改用户的注释信息
	  
	  修改用户shell信息
	  [root@oldboyedu oldboy]# usermod Alex02 -s /sbin/nologin
      [root@oldboyedu oldboy]# grep Alex02 /etc/passwd
      Alex02:x:1068:1068::/home/Alex02:/sbin/nologin

      修改用户uid信息
	  [root@oldboyedu oldboy]# usermod Alex02 -u 3000
      [root@oldboyedu oldboy]# id Alex02
      uid=3000(Alex02) gid=1068(Alex02) groups=1068(Alex02)

    c 删除用户信息
	  userdel
	  userdel -r Alex04
	  -r 彻底删除用户以及用户的家目录
      [root@oldboyedu oldboy]# ll /home/Alex04 -d
      ls: cannot access /home/Alex04: No such file or directory
      [root@oldboyedu oldboy]# useradd Alex04
	  
	d 用户密码设置方法
	  交互式设置密码
	  passwd oldboy 
	  非交互设置密码
	  echo 123456|passwd --stdin oldboy
	  
	  企业中设置密码和管理密码的方式
	  01. 密码要复杂12位以上字母数字及特殊符号
      02. 保存好密码信息
	      keepass
		  密码保险柜，本地存储密码
	      lastpass
		  密码保险柜，在线存储密码
	  03. 大企业用户和密码统一管理（相当于活动目录AD）
	      openldap域
		  用户信息统一保存在一个用户管理服务器中 用户的家目录中的文件 用户密码 用户名称
      04. 动态密码：动态口令，第三方提供自己开发也很简单。
	  

04. 用户组相关命令
    # groupadd 创建用户组
    [root@oldboyedu oldboy]# groupadd python
    [root@oldboyedu oldboy]# useradd python -g python
    [root@oldboyedu oldboy]# id python
    uid=3003(python) gid=3003(python) groups=3003(python)   
	
	# groupmod 修改用户组信息
	# groupdel 删除用户组信息
	
05. 用户属主属组设置命令
    chown  修改属主和属组信息
    [root@oldboyedu oldboy]# ll /etc/hosts
    -rw-r--r--. 2 root root 192 Apr 15 12:19 /etc/hosts
    [root@oldboyedu oldboy]# chown oldboy.root /etc/hosts
    [root@oldboyedu oldboy]# ll /etc/hosts
    -rw-r--r--. 2 oldboy root 192 Apr 15 12:19 /etc/hosts

    chown -R  递归修改目录属主和属组信息
    [root@oldboyedu oldboy]# ll oldboy_dir -d
    dr-xr-xr-x. 2 oldboy oldgirl 24 Apr 23 10:36 oldboy_dir
    [root@oldboyedu oldboy]# touch oldboy_dir/root.txt
    [root@oldboyedu oldboy]# ll oldboy_dir/root.txt
    -rw-r--r--. 1 root root 0 Apr 24 11:29 oldboy_dir/root.txt
    [root@oldboyedu oldboy]# id Alex01
    uid=1067(Alex01) gid=1067(Alex01) groups=1067(Alex01)
    [root@oldboyedu oldboy]# chown Alex01.Alex01 oldboy_dir
    [root@oldboyedu oldboy]# ll oldboy_dir -d
    dr-xr-xr-x. 2 Alex01 Alex01 40 Apr 24 11:29 oldboy_dir
    [root@oldboyedu oldboy]# ll oldboy_dir/
    total 0
    -rw-r--r--. 1 root root 0 Apr 23 10:36 oldboy.txt
    -rw-r--r--. 1 root root 0 Apr 24 11:29 root.txt
    [root@oldboyedu oldboy]# chown -R Alex01.Alex01 oldboy_dir
    [root@oldboyedu oldboy]# ll oldboy_dir -d
    dr-xr-xr-x. 2 Alex01 Alex01 40 Apr 24 11:29 oldboy_dir
    [root@oldboyedu oldboy]# ll oldboy_dir/
    total 0
    -rw-r--r--. 1 Alex01 Alex01 0 Apr 23 10:36 oldboy.txt
    -rw-r--r--. 1 Alex01 Alex01 0 Apr 24 11:29 root.txt
	
06. 用户信息查看命令
    a id  显示用户信息命令 (uid gid)
	b w   显示正在登陆系统的用户信息
	  [root@oldboyedu oldboy]# w
      11:33:31 up  6:33,  1 user,  load average: 0.00, 0.01, 0.05
      USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
      root     pts/0    10.0.0.1         08:55    3.00s  0.20s  0.00s w
	  01       02       03               04       05         06       07
	  
	  01. 什么用户登录到了系统中
	  02. 登录的方式  
	      pts/x 远程登录系统
		  tty1  本地登录
		  [root@oldboyedu oldboy]# echo "请不要修改恢复hosts文件配置" >/dev/pts/1 
      03. 从哪连接的服务器 
	  04. 登录时间
	  05. IDLE 空闲时间
      06. 用户操作系统 消耗的CPU资源时间
	  07. 用户在干什么

07. 用户权限说明:
    普通用户如何像root用户一些操作管理系统:
    01. 直接切换到root账户下管理系统   篡权夺位
    02. 直接修改要做的数据文件权限	
	03. root用户赋予了普通用户权利     大宝剑--sudo
	    sudo root用户授权一个能力给普通用户
		a 怎么进行授权:
		  visudo
		  93 oldboy  ALL=(ALL)       /usr/sbin/useradd, /usr/bin/rm
		  
        b 如何验证oldboy已经获取了root用户能力
		  [oldboy@oldboyedu ~]$ sudo -l 
          We trust you have received the usual lecture from the local System
          Administrator. It usually boils down to these three things:
          
              #1) Respect the privacy of others.
              #2) Think before you type.
              #3) With great power comes great responsibility.
          [sudo] password for oldboy: 
          User oldboy may run the following commands on oldboyedu:
              (ALL) /usr/sbin/useradd, /usr/bin/rm
			  
	    c 执行root用户可以执行的命令
		  [oldboy@oldboyedu ~]$ sudo useradd Alex06
          useradd: user 'Alex06' already exists
          [oldboy@oldboyedu ~]$ sudo useradd Alex07
          useradd: user 'Alex07' already exists
          [oldboy@oldboyedu ~]$ sudo useradd Alex08
          [oldboy@oldboyedu ~]$ sudo rm -f /etc/hosts




##############################
#  22-操作系统定时任务
##############################

00. 课程介绍部分
    1) 用户权限说明
	2) 系统定时任务
    
    
01. 课程知识回顾
    1) 用户相关的文件
	   /etc/passwd  --- 系统用户记录文件
	   /etc/shadow  --- 记录用户密码信息
	   /etc/group   --- 用户组文件
	   /etc/gshadow --- 用户组密码文件
	2) 用户相关的命令
	   useradd  -u -g -G -M -s -c 
	   usermod  -u -g -G -s -c 
	   userdel  -r
	   groupadd 
	   groupmod
	   groupdel
	   chown    -R
	   id
	   w
    3) 如何让普通用户获得root用户的能力
	   1) 直接切换用户为root    su - 
          su - /su 有什么区别
		  su    部分环境变量切换用户有变化
		  su -  全部环境变量切换用户有变化

          演示说明:
		  [oldboy@oldboyedu ~]$ env|grep oldboy
          HOSTNAME=oldboyedu.com
          USER=oldboy
          MAIL=/var/spool/mail/oldboy
          PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/oldboy/.local/bin:/home/oldboy/bin
          PWD=/home/oldboy
          HOME=/home/oldboy
          LOGNAME=oldboy
		  说明: 默认当前登录系统用户为oldboy时,环境变量中会体现出oldboy用户信息
		  
          [oldboy@oldboyedu ~]$ su root
          Password: 
          [root@oldboyedu oldboy]# env|grep root
          HOME=/root
          [root@oldboyedu oldboy]# env|grep oldboy
          HOSTNAME=oldboyedu.com
          USER=oldboy
          PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/oldboy/.local/bin:/home/oldboy/bin
          MAIL=/var/spool/mail/oldboy
          PWD=/home/oldboy
          LOGNAME=oldboy
          说明: 当用户su命令切换用户,系统中环境变量信息部分会变为root,但更多信息为原有oldboy用户信息
		  
          [oldboy@oldboyedu ~]$ su - root
          Password: 
          Last login: Thu Apr 25 08:51:40 CST 2019 on pts/0
          [root@oldboyedu ~]# env|grep root
          USER=root
          MAIL=/var/spool/mail/root
          PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
          PWD=/root
          HOME=/root
          LOGNAME=root
		  说明: 当用户su -命令切换用户,系统中环境变量信息会全部切换为root
		  
	   2) 直接修改文件的权限
	      rwx  属主信息
	   
	   3) 让root用户将自己的部分能力赋予给普通 sudo
	   
02. sudo功能配置说明
    a 如何配置sudo权限信息:
	  visudo(推荐使用:语法检查功能) == vi /etc/sudoers
	  [root@oldboyedu ~]# visudo -c   --- 配置好的文件语法检查
      /etc/sudoers: parsed OK
	  
	  扩展配置方法:
	  1) 授权单个命令或多个命令
	     /usr/sbin/useradd, /usr/bin/rm, ,
      2) 授权单个命令目录或多个命令目录 (需要排除部分特权命令)
	     /usr/sbin/*, !/usr/sbin/visudo , /usr/bin/*
      3) 不需要输入用户密码,可以直接sudo方式执行命令
	     NOPASSWD: /usr/sbin/*, !/usr/sbin/visudo , /usr/bin/*

    b 如何查看确认配置
	  切换到授权的用户下(oldboy)
	  sudo -l 
	  需要输入授权的用户密码(oldboy)
	  
	c 如何使用sudo功能
	  sudo 授权的命令
	  
03. 设置特殊权限位:
    rwx -w- --x  系统文件数据的9个权限位  系统中实际应该有12个权限位
	setuid: 4
	权限设置方法:
	chmod u+s  文件信息
	chmod 4755 文件信息 
	[root@oldboyedu ~]# ll /bin/cat
    -rwsr-xr-x. 1 root root 54080 Apr 11  2018 /bin/cat
	在属主权限位多出s信息
	总结: setuid权限位设置,将文件属主拥有的能力,分配给所有人
	
	setgid: 2
	[root@oldboyedu ~]# chmod g+s /bin/cat
    [root@oldboyedu ~]# ll /bin/cat
    -rwsr-sr-x. 1 root root 54080 Apr 11  2018 /bin/cat
    [root@oldboyedu ~]# chmod 2755 /bin/cat
    [root@oldboyedu ~]# ll /bin/cat
    -rwxr-sr-x. 1 root root 54080 Apr 11  2018 /bin/cat
    [root@oldboyedu ~]# chmod 6755 /bin/cat
    [root@oldboyedu ~]# ll /bin/cat
    -rwsr-sr-x. 1 root root 54080 Apr 11  2018 /bin/cat
	总结: setgid权限位设置,将文件属组拥有的能力,分配给所有用户组
	
	sticky bit:粘滞位: (创建一个共享目录) 1
	作用: 
	可以将不同用户信息放置到共享目录中,实现不同用户数据可以互相查看,但是不可以互相随意修改
	设置方法: 
	chmod o+t  目录信息
	chmod 1777 目录信息
	系统中已经准备好了一个共享目录,权限位1777
	[root@oldboyedu ~]# ll -d /tmp/
    drwxrwxrwt. 10 root root 4096 Apr 25 09:35 /tmp/
	
	总结: 普通用户拥有root用户能力
	01. 直接切换用户 su - (*)
	    优势: 简单快捷
	    劣势: 风险太高(root权限泛滥)
		
	02. 修改数据文件权限  9位权限位 属主信息
	    优势: 只针对某个数据文件进行修改 只针对某个用户进行授权
	    劣势: 需要了解权限位功能 

    03. 采用sudo提权方式
	    优势: 可以利用文件编辑指定用户有哪些指定权限  sa运维部门 dev开发人员
		劣势: 配置规划复杂
	
	04. 修改数据文件权限  3位权限位
	    优势: 设置权限简单方便
		劣势: 设置好的权限所有用户都拥有

04. 如何防范系统中的重要文件不被修改(root用户也不能修改)
    给文件加上锁头: 
    目的: 使root用户也不能直接修改相应文件
	设置方法: 
    chattr +i /etc/passwd
    ll /etc/passwd
    -rw-r--r--. 1 root root 4820 Apr 25 11:01 /etc/passwd
	解锁方法:
	chattr -i /etc/passwd
    [root@oldboyedu ~]# ll /etc/passwd
    -rw-r--r--. 1 root root 4820 Apr 25 11:01 /etc/passwd
    [root@oldboyedu ~]# lsattr /etc/passwd
    ---------------- /etc/passwd
    检查方法
    [root@oldboyedu ~]# lsattr /etc/passwd
    ---------------- /etc/passwd

05. 定时任务概念(第一个服务)
    作用: 
	1) 类似生活中闹钟
	   Alarmy  叫醒方式
	   01 关闭方式: 做算数题 2位数 乘法运算  
	   02 关闭方式: 运动关闭 摇手机 5次
	   03 关闭方式: 拍照关闭 找个地方拍照 
    2) 可以自动完成操作命令
	   夜里备份数据(访问量不大)  白天(访问量也少-游戏)
	   cp /data  /backup
	   自动清理磁盘
	   自动的进行时间同步更新 ntpdate xxx

    软件种类:
	cronie   实现定时任务功能*****
	atd      实现定时任务功能 只能一次设置定时功能 
	anacron  实现定时任务功能 应用在家用电脑  7*24服务器
    
	检查软件是否安装 cronie
	[root@oldboyedu ~]# rpm -qa cronie
    cronie-1.4.11-19.el7.x86_64
    
    [root@oldboyedu ~]# rpm -ql cronie
    /etc/cron.deny
	/bin/crontab
	
	rpm -ivh 软件包.rpm   --- 手动安装软件
	-i install 安装
	-v         显示过程信息
	-h human   以人类可读方式显示信息
	说明: 无法解决软件依赖关系
	
	补充说明: 如何让linux和windows主机之间传输数据
	yum install -y lrzsz
	在linux上进行操作
	rz -y           	从windows上下载重要数据信息
	sz -y 数据信息  	从linux上上传重要数据到windows
	
	定时任务实现方法:
	日志文件需要定期进行切割处理
	周一         secure   100M
	周二(00:00)  mv secure secure-`date +%F`  100M 切割后的文件
	             touch secure
	系统特殊目录:
	系统定时任务周期：每小时   控制定时任务目录：/etc/cron.hourly
    系统定时任务周期：每一天   控制定时任务目录：/etc/cron.daily   00:00-23:59
    系统定时任务周期：每一周   控制定时任务目录：/etc/cron.weekly  7天
    系统定时任务周期：每个月   控制定时任务目录：/etc/cron.monthly 30 28 31
	
	
	用户定时任务
	每天的02:30进行数据备份???
	a 用户定时任务查看   crontab -l（list）
	说明: 列表查看定时任务信息（cron table）

    b 用户定时任务编辑   crontab -e（edit）
    说明: 编辑配置定时任务信息

    crontab -e  编写定时任务     vi /var/spool/cron/        定时任务配置文件保存目录
	                                 /var/spool/cron/root    root用户设置的定时任务配置文件
									 /var/spool/cron/oldboy  oldboy用户设置的定时任务配置文件
	visudo      对普通用户提权   vi /etc/sudoers 

06. 定时任务实际编写方法
    a 定时任务服务环境准备  
      定时任务服务是否启动/是否开机自动启动	
	  [root@oldboyedu ~]# systemctl status crond
      ● crond.service - Command Scheduler
         Loaded: loaded (/usr/lib/systemd/system/crond.service; enabled; vendor preset: enabled)
         Active: active (running) since Tue 2019-04-23 09:15:43 CST; 2 days ago
       Main PID: 905 (crond)
         CGroup: /system.slice/crond.service
                 └─905 /usr/sbin/crond -n
      
      Apr 23 09:15:43 oldboyedu.com systemd[1]: Started Command Scheduler.
      Apr 23 09:15:43 oldboyedu.com systemd[1]: Starting Command Scheduler...
      Apr 23 09:15:43 oldboyedu.com crond[905]: (CRON) INFO (RANDOM_DELAY will be scaled with factor 30% if used.)
      Apr 23 09:15:43 oldboyedu.com crond[905]: (CRON) INFO (running with inotify support)

    b 实际编写定时任务
	  配置方法: crontab -e
	  编写语法规范:
	  # Example of job definition:
      # .---------------- minute (0 - 59)
      # |  .------------- hour (0 - 23)
      # |  |  .---------- day of month (1 - 31)
      # |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
      # |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
      # |  |  |  |  |
      # *  *  *  *  * user-name  command to be executed
	  
	  *   *   *    *   * 具体做什么事情
	  分  时  日  月  周
	  
	  写法:
	  01. 用数值表示时间信息
	      00 02 *  *  *   备份文件
	  02. 利用特殊符号表示时间信息
	      *      *      *     *     *   备份文件 
		每分钟  每小时 每天  每月  每周
		  PS: 定时任务最短执行的周期为每分钟
		  */5     */5    */5    
        每隔5分钟  每隔5小时	
          01-05   02    *    *    *		
         01到05   02    *    *    *
        指定时间的范围
	      00      14,20  *   *    *
		指定不连续的时间信息
	    
	   测验01: 每天下午02:30分钟 起来学习
	           30 14 * * *
       测验02: 每隔3天 夜里2点   执行数据备份
	           00 02 */3  *  * 
       测验03: */10  01,03  *  *   *   ??? 
               01点 每隔10分钟 
			   03点 每隔10分钟  
	           每天   凌晨1点和凌晨3点  每隔10分钟0点整 -->  01:00 03:00	   
       测验04: */10   01-03  *  *   *
       测验05: *      01,03  *  *   *   ???   
       测验06: *      01-03	 *  *   *   
       测验07: 00     02     28 */2 6 	???   
	           02:00  28 每隔两个月  星期6
	   结论: 
	   01. 在写时间信息的时候, 如果想表示每隔多久执行什么任务
	       /上面尽量用*号表示, 不要写具体数值
	   02. 时间信息由左到右依次书写, 尽量不要跳步
	   03. 当编写定时任务时,日期信息不要和星期信息同时出现
	
	   补充说明:
	   20/10  01,03 * * *  
	   01:20 01:30 01:40       01:59
	   03:00        03:59
	
    c 实际编写定时任务
      1) 每天凌晨两点备份 /data目录到 /backup
      第一个历程: 写上时间信息
      00 02 * * *
      第二个历程: 写上完成任务的具体命令
      cp -a /data /backup
      第三个历程: 编写定时任务
      crontab -e 
      00 02 * * *  cp -a /data /backup	  
	
	  定时任务排查方法:
	  01. 检查是否有定时任务配置文件
	  cat /var/spool/cron/root 
      00 02 * * *  cp -a /data /backup
	  02. 检查定时任务日志文件
	  ll /var/log/cron
      -rw-------. 1 root root 14050 Apr 25 15:49 /var/log/cron
      日志信息说明
	  Apr 25 15:53:22 oldboyedu crontab[3893]: (root) BEGIN EDIT (root)
      Apr 25 15:54:06 oldboyedu crontab[3934]: (oldboy) BEGIN EDIT (oldboy)
      Apr 25 15:54:48 oldboyedu crontab[3893]: (root) REPLACE (root)
      Apr 25 15:54:48 oldboyedu crontab[3893]: (root) END EDIT (root)
      Apr 25 15:55:01 oldboyedu crond[905]: (root) RELOAD (/var/spool/cron/root)
      Apr 25 15:55:01 oldboyedu CROND[3939]: (root) CMD (cp -a /data /backup)
      Apr 25 15:55:01 oldboyedu CROND[3937]: (root) MAIL (mailed 55 bytes of output but got status 0x004b#012)
        执行时间      主机名   编辑定时任务    以什么用户编辑或执行定时任务/干了什么事情
		                        执行定时任务
	  
	
07. 定时任务编写注意事项:(规范)
    1) 编写定时任务要有注释说明
	2) 编写定时任务路径信息尽量使用绝对路径
	3) 编写定时任务命令需要采用绝对路径执行 /usr/sbin/useradd
	   命令执行成功条件:
	   useradd  ---> $PATH ---> /sbin/useradd ---> 命令执行成功
	   定时任务执行时,识别的PATH信息只有: /usr/bin:/bin
	   useradd命令--->usr/sbin/useradd
    4) 编写定时任务时,可以将输出到屏幕上的信息保存到黑洞中,避免占用磁盘空间
	   * * * * *  sh test.sh &>/dev/null
	   
	   说明: 定时任务中执行命令,如果产生输出到屏幕的信息,都会以邮件方式告知用户
       /var/spool/mail/root          不断变大占用磁盘空间        占用的block空间
       解决方法: 将邮件服务关闭
	   systemctl stop postfix
	   
	   /var/spool/postfix/maildrop/  不断产生小文件占用磁盘空间  占用的inode空间
	   解决方法: 删除小文件
	   rm -f /var/spool/postfix/maildrop/*
	   systemctl start postfix
	5) 编写定时任务, 尽量不要产生屏幕输出信息
       cp -a /data /backup	
	   tar zcvf /backup/data.tar.gz  /data    有信息输出
	   cd / 
       tar zcf /backup/data.tar.gz  ./data    没有信息输出
	6) 当需要多个命令完成一个定时任务需求时,可以利用脚本编写定时
	   vim backup.sh 
	   cp -a /data /backup	
	   tar zcvf /backup/data.tar.gz  /data
	   
	   crontab -e 
	   # xxxxx
	   * * * * *  /bin/sh /server/scripts/backup.sh &>/dev/null

    项目经验: 在校的项目
	01 企业项目: 全网备份项目(定时任务)
	



##############################
#  23-操作系统磁盘管理
##############################

00. 课程介绍部分
    1. 磁盘层次说明
	2. 按照磁盘层次详细了解磁盘知识
      
01. 课程知识回顾
    1) 系统用户权限
	   a 利用sudo方式进行普通用户提权
	   b 利用linux系统特殊权限位配置普通用户权限
	     setuid: (4XXX)将文件数据的属主权限,赋予其他所有的用户
		 setuid权限一般赋予二进制的命令文件或者一些可执行的脚本文件 
		 
		 补充: 脚本如何执行:
		 01. 借助解释器命令执行脚本
		     sh /server/scripts/xxx.sh
			 python /server/scripts/xxx.py
		 02. 直接还行脚本(当成命令执行)
             将脚本文件赋予执行权限
             /server/scripts/xxx.sh			 
		     /server/scripts/ --> PATH
			 xxx
		 setgid: (2XXX)将文件数据的属组权限,赋予其他所有的用户
		 粘滞位: 常见一个共享目录 共享数据只能互相查看  不能互相随意修改
    
	 2) 系统中重要数据信息如何加锁
	    chattr  +i  文件信息
		chattr  -i  文件信息
		lsattr  文件信息

	 3) 定时任务实现方式
	    01. 系统自带定时任务 (4个特殊的目录)
		02. 用户自己设定定时任务 (一个命令 crontab 三个文件 日志文件 配置文件 黑名单文件)
		
	 4) 定时任务配置方法:
	    crontab -e 
		* * * * *     命令信息
		定时时间信息
    
	    时间的表示方法:
		直接用数值表示: 00 02 * * *
		可以用符号表示: * */n n,m n-m
		注意: 星期信息不要和日期信息同时设置
	   
	 5) 定时任务编写的注意事项:
	    1) 定时任务编写时需要加注释信息
		2) 文件的路径尽量采用绝对路径
		3) 命令信息最好也要用绝对路径 
		4) 编写定时任务尽量在后面加上重定向黑洞 &>/dev/null
	       定时任务中有输出到屏幕上的信息:
		   如果开启邮件服务 postfix: 输出的信息 >> /var/spool/mail/root                  block空间不足
		   如果关闭邮件服务 postfix: 输出的信息 >> /var/spool/postfix/maildrop/小文件    inode空间不足
	    5) 尽可能让命令不要产生正确或错误的输出信息
		   tar zcvf  --> tar zcf 
        6) 多个定时任务命令,最好使用脚本实现
		7) 定时任务中无法识别任务中的一些特殊符号  
           解决方式一: 利用转义符号		
		   * * * * *  /bin/date "+\%F \%T" >/tmp/time.txt
		   解决方式二: 利用脚本编写任务
		   vim /oldboy/date.sh
		   /bin/date "+%F %T"
		   
		   * * * * *  /bin/sh /oldboy/date.sh &>/dev/null
		   
02. linux系统磁盘概念
    磁盘的结构体系
	01. 磁盘的物理结构 (外部结构 内部结构) 工作原理(先切换磁头 让磁头镜像运动)  OK
	02. 磁盘阵列说明   (raid0 raid1 raid5 raid10 raid01)
	    磁盘阵列如何配置 
        配置LVM  L 逻辑  v 卷组  M 管理  逻辑卷管理 --> 实现可以随意调整磁盘分区大小 
	03. 磁盘分区概念
        给容量较小的磁盘进行分区: 小于2T  fdisk
        给容量较大的磁盘进行分区: 大于2T  parted	
    04. 磁盘格式化操作(创建文件系统)
    05. 磁盘维护管理知识(如何使用磁盘 挂载使用)	
	   
03. 磁盘层次结构详细说明--物理结构
    磁盘的外部结构: 看的见摸得到的结构
    组成部分
	a 磁盘主轴  决定磁盘转速（rpm-round per minute）
	  家用磁盘转速  7200 rpm 5400 rpm
	  企业磁盘转速  15k  rpm  10k rpm
	b 磁盘盘片  用于存储数据
	c 磁盘磁头  用于读取数据
	d 磁盘接口  用于连接主板 用于连接阵列卡

    磁盘的内部结构: 看不见的结构信息
	组成部分: 
	a 磁盘（Disk）
    b 磁头（Head）
	  作用说明：用来写入和读取数据的
	  特点说明：盘面数量等于磁头数量
	  工作原理：采用径向运动读写数据
    c 磁道（Track）
	  作用说明：用来存储用户数据
	  特点说明：由多个同心圆组成
	  
	  存储计数：最外面同心圆为0磁道
	  工作原理：磁盘默认按照磁道寻找数据
		        重点原理：磁头径向运动为机械运动（寻道）  性能小于固态硬盘(芯片)
		        原理特点：磁头机械运动较慢
    d 扇区（Sector）
	  作用说明：用来存储用户数据
	  特点说明：磁盘存储最小单位
	  存储计数：默认磁盘扇区从1扇区开始，扇区大小为512字节
	  系统存储最小单位是block
    e 柱面（Cylinder） 
	  作用说明：用来存储用户数据
	  特点说明：不同盘面上相同的磁道组成（圆柱体）
	  工作原理：磁盘默认按照柱面进行读写
		        重点原理：磁头之间的切换为电子切换
		        原理特点：磁头电子切换较快
    f 单元块（Units） 
	  作用说明：用来存储用户数据
	  特点说明：表示单个柱面大小
	   
04. 磁盘层次结构详细说明--磁盘阵列raid
    阵列有什么用?
    1) 提高磁盘存储效率
    2) 提高磁盘存储安全
    3) 提高磁盘存储容量	
	阵列的配置方法:
    raid 0   存储数据效率高  存储安全性低
    raid 1	 存储数据效率低  存储安全性高
	
	raid 5   存储数据效率较高  存储安全性较高
	说明: 至少有3块磁盘  raid5阵列中只能最多坏一块磁盘  损耗一块磁盘的容量
	300G 300G 300G --> raid5 --> 600G
	LVM 实现分区可以弹性缩融 和 扩容
	
05. 磁盘层次结构详细说明--磁盘分区方法
    预备知识: 
	a 系统启动引导记录--
	  MBR引导记录  用于引导磁盘空间小于2T
	  GPT引导记录  用于引导磁盘空间大于2T
	  
    b 分区方式
	  情况一:
	  可以划分4个主分区  /dev/sda  /dev/sda1 .. sda4   mount /dev/sda1  /mnt
	  情况二: 
	  可以划分3个主分区    /dev/sda  /dev/sda1 .. sda3 
	  可以划分1个扩展分区  扩展分区无法直接使用
      需要在扩展分区基础上划分逻辑分区:  /dev/sda5 /dev/sda6 ...	  
	  
	  




##############################
#  24-操作系统磁盘管理
##############################

00. 课程介绍部分
    1) 磁盘分区方法 (备份服务器 存储服务器 数据库服务器)         OK  fdisk  parted
	2) 实现挂载使用 (实现开机自动挂载 /etc/fstab /etc/rc.local)   ok  
	3) swap分区如何调整大小 (案例: java程序比较耗费内存 临时增加swap空间)
	4) 企业常见问题: 磁盘空间满了如何处理     
    
01. 课程知识回顾
    1) 磁盘的层次结构
	   1. 物理层次结构: 	磁盘外部和内部结构
	   2. 磁盘的阵列/LVM: 	将多块硬盘整合为一块  LVM是实现分区弹性缩容和扩容
	   3. 磁盘分区方法
	   4. 磁盘格式化操作: 	创建文件系统
	   5. 磁盘挂载使用: 
    
02. 磁盘层次结构--磁盘分区方法 
    情况一: 磁盘分区实践--磁盘小于2T
    第一个里程: 准备磁盘环境
    准备了一块新的10G硬盘

    第二个里程: 在系统中检查是否识别到了新的硬盘
    检查是否有新的磁盘存储文件
    [root@oldboyedu ~]# ll /dev/sdb
    brw-rw----. 1 root disk 8, 16 Apr 28 08:54 /dev/sdb	
	
	第三个里程: 对磁盘进行分区处理(fdisk-- 进行分区处理 查看分区信息)
	fdisk -l   --- 查看分区信息 
	[root@oldboyedu ~]# fdisk /dev/sdb
    Welcome to fdisk (util-linux 2.23.2).
    
    Changes will remain in memory only, until you decide to write them.
    Be careful before using the write command.
    
    Device does not contain a recognized partition table
    Building a new DOS disklabel with disk identifier 0x6c918c6d.
    
    Command (m for help):   可以对磁盘进行分区了
	Command action
    d   delete a partition  *****
        删除分区	
    g   create a new empty GPT partition table
	    创建一个新的空的GPT分区表(可以对大于2T磁盘进行分区)
    l   list known partition types
	    列出可以分区的类型???
    m   print this menu
	    输出帮助菜单
    n   add a new partition  *****
	    新建增加一个分区
    p   print the partition table  *****
	    输出分区的结果信息
    q   quit without saving changes 
	    不保存退出
    t   change a partition's system id
	    改变分区的系统id==改变分区类型(LVM 增加swap分区大小)
    u   change display/entry units
	    改变分区的方式  是否按照扇区进行划分
    w   write table to disk and exit  *****
	    将分区的信息写入分区表并退出==保存分区信息并退出
  
	开始分区: 
    a 规划分4个主分区 每个分区1G
	分区操作过程
	Command (m for help): n                          
    Partition type:
       p   primary (0 primary, 0 extended, 4 free)
       e   extended
    Select (default p): p
    Partition number (1-4, default 1): 1
    First sector (2048-20971519, default 2048): 
    Using default value 2048
    Last sector, +sectors or +size{K,M,G} (2048-20971519, default 20971519): +1G
    Partition 1 of type Linux and of size 1 GiB is set
    
	分区操作检查:
    Command (m for help): p
    Disk /dev/sdb: 10.7 GB, 10737418240 bytes, 20971520 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disk label type: dos
    Disk identifier: 0x3069f1dd
    
       Device Boot      Start         End      Blocks   Id  System
    /dev/sdb1            2048     2099199     1048576   83  Linux
    /dev/sdb2         2099200     4196351     1048576   83  Linux
    /dev/sdb3         4196352     6293503     1048576   83  Linux
    /dev/sdb4         6293504     8390655     1048576   83  Linux
    
    Command (m for help): n
    If you want to create more than four partitions, you must replace a
    primary partition with an extended partition first.
	
	b 规划分3个主分区 1个扩展分区 每个主分区1G  剩余都给扩展分区
    删除分区 
    Command (m for help): d   
    Partition number (1-4, default 4): 1
    Partition 1 is deleted	
	创建逻辑分区
    Command (m for help): p
    
    Disk /dev/sdb: 10.7 GB, 10737418240 bytes, 20971520 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disk label type: dos
    Disk identifier: 0x3069f1dd
    
       Device Boot      Start         End      Blocks   Id  System
    /dev/sdb1            2048     2099199     1048576   83  Linux
    /dev/sdb2         2099200     4196351     1048576   83  Linux
    /dev/sdb3         4196352     6293503     1048576   83  Linux
    /dev/sdb4         6293504    20971519     7339008    5  Extended   有了扩展分区才能逻辑分区
    
    Command (m for help): n
    All primary partitions are in use
    Adding logical partition 5
    First sector (6295552-20971519, default 6295552): 
    Using default value 6295552
    Last sector, +sectors or +size{K,M,G} (6295552-20971519, default 20971519): +1G
    Partition 5 of type Linux and of size 1 GiB is set
	
	Command (m for help): p
    Disk /dev/sdb: 10.7 GB, 10737418240 bytes, 20971520 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disk label type: dos
    Disk identifier: 0x3069f1dd
    
       Device Boot      Start         End      Blocks   Id  System
    /dev/sdb1            2048     2099199     1048576   83  Linux
    /dev/sdb2         2099200     4196351     1048576   83  Linux
    /dev/sdb3         4196352     6293503     1048576   83  Linux
    /dev/sdb4         6293504    20971519     7339008    5  Extended
    /dev/sdb5         6295552     8392703     1048576   83  Linux
  
	需求: 划分2个主分区 划分2个逻辑分区
    sdb1  2G
    sdb2  2G
    sdb5  3G
    sdb6  1G	
	  
	第四个里程: 保存退出,让系统可以加载识别分区信息
    让系统可以加载识别分区文件
    partprobe /dev/sdb 
    
	
	
	情况二: 磁盘分区实践--磁盘大于2T
	第一个里程: 准备磁盘环境 
	虚拟主机中添加一块3T硬盘
	
	第二个里程: 使用parted命令进行分区
	
	mklabel,mktable LABEL-TYPE               create a new disklabel (partition table)
	                                         创建一个分区表 (默认为mbr)
	print [devices|free|list,all|NUMBER]     display the partition table, available devices, free space, all found
                                             partitions, or a particular partition
											 显示分区信息
	mkpart PART-TYPE [FS-TYPE] START END     make a partition
	                                         创建一个分区 
    quit                                     exit program
	                                         退出分区状态
	rm NUMBER                                delete partition NUMBER
	                                         删除分区 

    修改磁盘分区类型: mklabel gpt
	分区方法: mkpart primary 0  2100G
	
	第三个里程: 加载磁盘分区
	partprobe /dev/sdc
	  
03. 磁盘层次结构--格式化操作(创建文件系统)
    mkfs.xfs  /dev/sdb1 
	mkfs -t xfs /dev/sdb2
	
	创建文件系统: 磁盘分区存储数据的方式
	
	ext3/4  centos6 
	xfs     centos7  格式效率较高  数据存储效率提升(数据库服务器)
	
	[root@oldboyedu /]# mkfs.xfs /dev/sdb2
    meta-data=/dev/sdb2              isize=512    agcount=4, agsize=65536 blks
             =                       sectsz=512   attr=2, projid32bit=1
             =                       crc=1        finobt=0, sparse=0
    data     =                       bsize=4096   blocks=262144, imaxpct=25
             =                       sunit=0      swidth=0 blks
    naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
    log      =internal log           bsize=4096   blocks=2560, version=2
             =                       sectsz=512   sunit=0 blks, lazy-count=1
    realtime =none                   extsz=4096   blocks=0, rtextents=0
	
04. 磁盘层次结构--磁盘挂载应用
    mount /dev/sdb1 /mount01
    mount /dev/sdb2 /mount02	
    检查确认:
    [root@oldboyedu /]# df -h
    /dev/sdb1      1014M   33M  982M   4% /mount01
    /dev/sdb2      1014M   33M  982M   4% /mount02
	
    如何实现开机自动挂载:
	方法一: 将挂载命令放入/etc/rc.local
	[root@oldboyedu /]# tail -2 /etc/rc.local 
    mount /dev/sdb1 /mount01
    mount /dev/sdb2 /mount02

    系统开机加载rc.local流程:
	加载/etc/rc.local --> /etc/rc.d/rc.local --> 以绝对路径方式执行
	/etc/rc.d/rc.local 
	chmod +x /etc/rc.d/rc.local
	
	方法二: 在/etc/fstab文件中进行设置
	UUID=e2fc8646-2b36-47cc-a35a-8c13208f4d0b /          xfs                 defaults            0             0
    UUID=34fc45ba-c38c-42bc-a120-90f9d5dd2382 /boot      xfs                 defaults            0             0
    UUID=62100743-6f8a-4f83-a37d-e2088c4830e2 swap       swap                defaults            0             0
	挂载磁盘文件(存储设备)                   挂载点     指定文件系统类型   挂载的参数    是否备份磁盘  是否检查磁盘 
	mount 挂载的磁盘文件 挂载点
    [root@oldboyedu ~]# tail -2 /etc/fstab
    /dev/sdb1                                 /mount01                xfs     defaults        0 0
    UUID=144738ff-0da3-4162-b574-40af379cbe9e /mount02                xfs     defaults        0 0

05. 企业磁盘常见问题:
    1) 磁盘满的情况 No space left on device
	   a 存储的数据过多了
	     模拟磁盘空间不足
		 dd if=/dev/zero of=/tmp/oldboy.txt  bs=10M count=100
         block存储空间不足了
         解决方式:
		 a 删除没用的数据		 
         b 找出大的没用的数据
		   find / -type f -size +xxx
		   du -sh /etc/sysconfig/network-scripts/*|sort -h

		 
	   补充: 按照数值排序命令
	   [root@oldboyedu mount01]# cat num.txt |sort -n
       # 1
       # 10
       # 11
       # 12
       # 2
       # 3
       # 6
       # 9
       [root@oldboyedu mount01]# cat num.txt |sort -n -k2
       # 1
       # 2
       # 3
       # 6
       # 9
       # 10
       # 11
       # 12

       b 存储的数据过多了
       inode存储空间不足了: 出现了大量小文件	   

06. 如何调整swap分区大小
    第一个历程: 将磁盘分出一部分空间给swap分区使用
	dd if=/dev/zero  of=/tmp/1G  bs=100M count=10
	
    第二个历程: 将指定磁盘空间作为swap空间使用
	[root@oldboyedu tmp]# mkswap /tmp/1G 
    Setting up swapspace version 1, size = 1023996 KiB
    no label, UUID=6dd70684-dec2-48cf-8fd9-f311548bbb4f

    第三个历程: 加载使用swap空间
	[root@oldboyedu tmp]# swapon /tmp/1G 
    swapon: /tmp/1G: insecure permissions 0644, 0600 suggested.
    [root@oldboyedu tmp]# free -h
                  total        used        free      shared  buff/cache   available
    Mem:           1.9G        225M        575M        9.6M        1.2G        1.5G
    Swap:          2.0G          0B        2.0G
    [root@oldboyedu tmp]# swapoff /tmp/1G 
    [root@oldboyedu tmp]# free -h
                  total        used        free      shared  buff/cache   available
    Mem:           1.9G        224M        576M        9.6M        1.2G        1.5G
    Swap:          1.0G          0B        1.0G
    [root@oldboyedu tmp]# rm /tmp/1G -f

07. 磁盘知识总结
    1) 掌握磁盘体系结果
	2) 磁盘的内部和外部结构(磁头 磁道 扇区 柱面) 运维---存储服务
	3) 磁盘分区的方法
	   fdisk  划分小于2T的磁盘
	   parted 划分大于2T的磁盘
	4) 如何实现格式化和自动挂载   存储服务nfs 
	   /etc/rc.local 
	   /etc/fstab 
    5) 磁盘分区满的原因  No space left on device
	   a block占用过多了
	     df -h 
		 解决方式: 删除大的没用的数据
		 如何找到大的文件
		 find / -type f -size +500M|xargs rm
		 du -sh /etc/sysconfig

       b inode占用过多了
	     df -i
		 解决方式: 删除大量的没用的小文件
	6) 如何调整swap空间大小  --- tomcat(java)	512M 
       dd 
	   mkswap 
	   swapon/off

假期作业:
01. 总结所有命令
02. 总结重要章节
    文件属性章节
	正则表达式章节
	sed命令/awk命令
	用户管理权限概念
	定时任务
	
30号测试



##############################
#  25-运维基础网络知识
##############################

00. 课程介绍部分
    1) 学习网络的课程体系            OK
	2) 两台主机通讯原理              OK
	3) 一个局域网中多台主机如何通讯 --- 交换   OK
	4) 不同局域网中多台主机如何通讯 --- 路由   OK
	5) 网络的配置操作(命令行配置)    OK
	   静态路由配置 
	   动态路由配置 RIP OSPF
    6) 网络的架构 	                  OK
	7) OSI7层模型/ TCP/IP模型         
	8) TCP三次握手过程/TCP四次挥手过程
	9) TCP是十一种状态集转换
   10) 网络重要协议 
       DNS (域名访问网站-nginx)
	   ARP (访问IP地址--MAC地址)
   11) 办公环境上网原理(家庭网络环境)
       虚拟主机访问外网原理
   12) IP地址概念
       IP地址种类划分 192.168.10.500
	   IP地址子网划分
	   交换网络vlan概念
   13) 系统中路由配置
       系统中网卡别名设置 *
   14) 网络中抓包软件使用
       wireshark
	   tcpdump
   15) 企业中网络排错思路
       系统主机无法访问网站
       系统主机访问网站慢    
    
01. 课程知识回顾
    1) 磁盘分区方法
	   fdisk  --- 对小于2T的磁盘进行划分
	              补充: fdisk最大分的区要小于2T
	   parted --- 对大于2T的磁盘进行划分
	              补充: parted可以划分一个大于2T的分区
	2) 如何进行格式化
	   mkfs --- 指定文件系统 xfs ext3 ext4
	3) 磁盘的挂载操作
	   mount / umount / df -h 
	   如何实现自动挂载
	   /etc/rc.local  --- 文件必须是执行权限
	   /etc/fstab     --- 每一列代表什么意思
    4) swap空间如何调整大小 --- 服务器中有java程序
    5) 企业磁盘异常案例
       磁盘满的原因
       a 真正数据太大存储过多  block满了
       b 存储了大量小问题      inode满了	   

       
02. 运维网络课程介绍
    学习网络的课程体系
	网络通讯基本原理
	1) 主机之间需要有传输介质
	2) 主机上必须有网卡设备
	   可以将二进制信息转换为高低电压 信号的调制过程
	   可以将高低电压转换为二进制信息 信号的解调过程
	3) 多台主机需要协商网络速率
       100Mbps 	~  100Mbit per second ~ 每秒钟传输100M bit的信息  0 1
       1M ~ 1000k   1000000b
	   1k ~ 1000b
	   常见的问题: 购买一个100M网络线路, 但是用迅雷下载软件的时候远远到达不了100M
	   100Mb 网络的数据单位 bit    1bit=1/8byte   100/8=12.5  10M  12M
       100MB 磁盘的数据单位 Byte   1byte=8bit	   100*8=800M  
    
03. 网络基础硬件介绍
    交换机: 在一个网络中实现多台主机之间通讯
	        一台交换机所连接的所有主机构成网络,成为局域网
	实现通讯:
	1) 主机上要有相应的mac地址(物理地址) 有12位16进制数组成  0-9 A B C D E F
	2) 利用交换机进行通讯,有时需要借助广播方进行通讯
	   广播的产生有时会影响主机性能
	补充: 通讯的过程一定是有去有回的
	
	路由器: 实现不同局域网主机之间的通讯
	实现通讯:
	1) 主机上要有相应的IP地址(逻辑地址)  用十进制表示  192.168.10.1
	   IP地址的组成: 网络信息(局域网标识)+主机地址信息
	2) 需要借助路由器中的路由表实现通讯
	   网络信息(局域网标识信息)   接口信息   R1
	            01                 eth0
				02				   eth1
				04                 eth2       手动配置
	   网络信息(局域网标识信息)   接口信息   R2
                02                 eth0 
                03                 eth1
                04                 eth3		  手动配置	
                01                 eth2	      手动配置	
	   网络信息(局域网标识信息)   接口信息   R3
                04                 eth0 
                03                 eth1	
                01                 eth2       手动配置      				
       路由表的信息是如何生成的?
	   1) 利用直连网络环境自动生成
	   2) 利用手工配置方式 		 (静态路由配置)
	   3) 利用路由协议动态生成  (动态路由配置)
	   
	   网关: 一个主机想访问其他网络主机的必经之路
	   路由器的接口: 网关接口
	   路由器的地址: 网关地址
	   
	静态路由配置方法:
    网络环境规划
    a 两台主机 
      主机01  192.168.1.1  == 01.01	
	          192.168.1.254
	  主机02  192.168.4.1  == 04.01
	          192.168.4.254
	b 两台交换机
	c 三台路由器
	
	第一个里程: 路由器配置(接口地址配置)
	R1 
	Router> en  	命令提示符 					用户模式提示符
	Router# conf t             					特权模式提示符  可以进行系统配置查看
	Router(config)# interface interface g0/0    配置模式提示符  
	Router(config-if)#                          接口模式提示符
	g0/0接口配置
	ip address 192.168.1.254 255.255.255.0
	no shutdown
	g0/1接口配置
	ip address 192.168.2.1 255.255.255.0
	no shutdown
	检查确认:
	ctrl+z 快速返回到特权模式
	show ip interface brief    --- 只显示ip地址信息
	Router#show ip int br
    Interface              IP-Address      OK? Method Status                Protocol 
    GigabitEthernet0/0     192.168.1.254   YES manual up                    up 
    GigabitEthernet0/1     192.168.2.1     YES manual up                    down 

	R2
    R2#show ip int br
    Interface              IP-Address      OK? Method Status                Protocol 
    GigabitEthernet0/0     192.168.2.2     YES manual up                    up 
    GigabitEthernet0/1     192.168.3.1     YES manual up                    down 
	
	R3
	Router#show ip int br
    Interface              IP-Address      OK? Method Status                Protocol 
    GigabitEthernet0/0     192.168.3.2     YES manual up                    up 
    GigabitEthernet0/1     192.168.4.254   YES manual up                    up 
  
	R1路由表信息
    R1#show ip route
         192.168.1.0/24 is variably subnetted, 2 subnets, 2 masks
    C       192.168.1.0/24   is directly connected, GigabitEthernet0/0
    L       192.168.1.254/32 is directly connected, GigabitEthernet0/0
         
	  	192.168.2.0/24 is variably subnetted, 2 subnets, 2 masks
    C       192.168.2.0/24   is directly connected, GigabitEthernet0/1
    L       192.168.2.1/32   is directly connected, GigabitEthernet0/1	
	   
	路由配置 
    ip route 去往网络地址信息 网络掩码  去往目标的下一条接口地址
    ip route 192.168.4.0 255.255.255.0 192.168.2.2	
    R1#show ip route
         192.168.1.0/24 is variably subnetted, 2 subnets, 2 masks
    C       192.168.1.0/24 is directly connected, GigabitEthernet0/0
    L       192.168.1.254/32 is directly connected, GigabitEthernet0/0
         192.168.2.0/24 is variably subnetted, 2 subnets, 2 masks
    C       192.168.2.0/24 is directly connected, GigabitEthernet0/1
    L       192.168.2.1/32 is directly connected, GigabitEthernet0/1
	
    S    192.168.4.0/24 [1/0] via 192.168.2.2
	
	R2路由表信息
         192.168.2.0/24 is variably subnetted, 2 subnets, 2 masks
    C       192.168.2.0/24 is directly connected, GigabitEthernet0/0
    L       192.168.2.2/32 is directly connected, GigabitEthernet0/0
	
         192.168.3.0/24 is variably subnetted, 2 subnets, 2 masks
    C       192.168.3.0/24 is directly connected, GigabitEthernet0/1
    L       192.168.3.1/32 is directly connected, GigabitEthernet0/1
	路由配置 
    ip route 去往网络地址信息 网络掩码  去往目标的下一条接口地址
    ip route 192.168.4.0 255.255.255.0 192.168.3.2
	ip route 192.168.1.0 255.255.255.0 192.168.2.1
	
	     192.168.2.0/24 is variably subnetted, 2 subnets, 2 masks
    C       192.168.2.0/24 is directly connected, GigabitEthernet0/0
    L       192.168.2.2/32 is directly connected, GigabitEthernet0/0
         192.168.3.0/24 is variably subnetted, 2 subnets, 2 masks
    C       192.168.3.0/24 is directly connected, GigabitEthernet0/1
    L       192.168.3.1/32 is directly connected, GigabitEthernet0/1
	
    S    192.168.4.0/24 [1/0] via 192.168.3.2
	S    192.168.1.0/24 [1/0] via 192.168.2.1
	
	R3路由表信息
    	 192.168.3.0/24 is variably subnetted, 2 subnets, 2 masks
    C       192.168.3.0/24 is directly connected, GigabitEthernet0/0
    L       192.168.3.2/32 is directly connected, GigabitEthernet0/0
	
         192.168.4.0/24 is variably subnetted, 2 subnets, 2 masks
    C       192.168.4.0/24   is directly connected, GigabitEthernet0/1
    L       192.168.4.254/32 is directly connected, GigabitEthernet0/1
	
	路由配置 
    ip route 去往网络地址信息 网络掩码  去往目标的下一条接口地址
    ip route 192.168.1.0 255.255.255.0 192.168.3.1	
	
	S    192.168.1.0/24 [1/0] via 192.168.3.1
	
         192.168.3.0/24 is variably subnetted, 2 subnets, 2 masks
    C       192.168.3.0/24 is directly connected, GigabitEthernet0/0
    L       192.168.3.2/32 is directly connected, GigabitEthernet0/0
         192.168.4.0/24 is variably subnetted, 2 subnets, 2 masks
    C       192.168.4.0/24 is directly connected, GigabitEthernet0/1
    L       192.168.4.254/32 is directly connected, GigabitEthernet0/1
	
	删除静态路由方法:
	R1取消静态路由
	no ip route 192.168.4.0 255.255.255.0 192.168.2.2
	R2取消静态路由
    no ip route 192.168.4.0 255.255.255.0 192.168.3.2
	no ip route 192.168.1.0 255.255.255.0 192.168.2.1	
	R3取消静态路由
	no ip route 192.168.1.0 255.255.255.0 192.168.3.1

  	动态路由配置方法:
	默认R1-R3路由表情况:
	R1路由表:  张三  游戏 厨艺 销售
	192.168.1.0    g0/0 
	192.168.2.0    g0/1    R1G0/1 -- R2G0/0
	
	192.168.3.0    g0/1 
	192.168.4.0    g0/1
	R2路由表:  李四  厨艺 销售 游戏
	192.168.2.0    g0/0    R1G0/1 -- R2G0/0
	192.168.3.0    g0/1    R3G0/0 -- R2G0/1
	
	192.168.1.0    g0/0
	192.168.4.0    g0/1
	R3路由表:  王五  销售 游戏 厨艺
	192.168.3.0    g0/0    R3G0/0 -- R2G0/1
	192.168.4.0    g0/1
	
	192.168.2.0    g0/0 
	192.168.1.0    g0/0

    实现多个路由器路由表信息一致的过程: 路由收敛过程
    动态路由协议如何配置:
	RIP 思科私有(EIGRP) OSPF IS-IS BGP
    R1动态路由配置:
	router rip   --- 指定配置使用什么路由协议
	network 192.168.1.0   --- 宣告过程
	network 192.168.2.0 
	
	学习的信息
	R    192.168.3.0/24 [120/1] via 192.168.2.2, 00:00:09, GigabitEthernet0/1
    R    192.168.4.0/24 [120/2] via 192.168.2.2, 00:00:20, GigabitEthernet0/1
    R2动态路由配置
	router rip
    network 192.168.2.0
	network 192.168.3.0
	
	学习的信息 
	R    192.168.1.0/24 [120/1] via 192.168.2.1, 00:00:07, GigabitEthernet0/0
	R    192.168.4.0/24 [120/1] via 192.168.3.2, 00:00:13, GigabitEthernet0/1

    R3动态路由配置
	router rip
    network 192.168.3.0
	network 192.168.4.0
	
	学习的信息 
	R    192.168.1.0/24 [120/2] via 192.168.3.1, 00:00:23, GigabitEthernet0/0
    R    192.168.2.0/24 [120/1] via 192.168.3.1, 00:00:23, GigabitEthernet0/0

04. 网络架构设计方法(网络拓扑)
    三个层次规划网络拓扑
	核心层: 路由器(网关接口)   实现和外网通讯 冗余能力(主备)
    汇聚层: 交换机(三层交换机) 冗余能力       策略控制能力
    接入层: 交换机(二层交换机) 终端设备接入网络

05. 网络层次模型
    OSI7层模型(公司的组织架构)
	
	管理部   公司决策                        	管理部
	行政部   传到领导要求 阻止活动          	行政部
	财务部   发工资 公司账目
	市场部   推广宣传
	销售部   销售产品
	物流部   运输产品
	仓储部   保存看管物品
	
	层次模型结构: 由上至下
	思科                             华为设备
	
	应用层   标准规范
	* 应用层程序接口规范  
	表示层
	* 数据转换加密 压缩
	会话层
	* 控制网络连接建立或者终止
	传输层
	* 保证数据传输的可靠性
	网络层   路由协议EIGRP(语言)     网络层   路由的能力 三层设备
	* 可以实现通过路由找到目标网络
	数据链路层                       交换能力 二层设备
	* 可以实现通过交换找到真正目标主机
	物理层
	* 指定一些网络物理设备标准  网卡 网线 光纤
	
	是由ISO(国际标准化组织): 定义了标准通讯模型
	
	利用OSI7层模型如何建立主机与主机之间的通讯
	数据的封装过程
	数据的解封装过程
	
	TCP/IP模型(4层模型)
    在OSI7层模型的基础上做了简化
    应用层      
    表示层          应用层  
    会话层 
    传输层          主机到主机层
    网络层          互联网层
    数据链路层      接入层
    物理层	

    TCP协议: 传输控制协议  --- 面向连接的网络协议
	在线发送文件==面向连接
	发送文件 --> 对端点击接收
	优点: 数据传输可靠性高 
	缺点: 数据传输效率低
	
	UDP协议: 用户报文协议  --- 无连接的网络协议
    离线发送文件==无连接
    发送文件 --> 直接发送了
	优点: 数据传输效率高
    缺点: 数据传输可靠性低
	
	QQ离线传输文件/在线传输文件: TCP协议
	在线传输 
	PC 传输文件 - 	交换机 - 检查目标QQ主机是否在局域网中
					路由器 - 目标主机
	
	离线传输
	PC 传输文件 - 互联网 - QQ公司服务器(临时存储服务器) --- 对端QQ是否登录在线
	
	
	TCP协议: 两个重要原理
	预备知识: TCP协议报文结构
	源端口:  1~65535 
	目标端口:
	占用16个bit --> 占用1个bit 0  ---> 0  1 --- 1  10 --- 2
	二进制 0   十进制 0
	二进制 1   十进制 1
	二进制 10  十进制 2
	二进制 11  十进制 3
	二进制 100 十进制 4
	1个bit 0 1          2个端口  0 1   0~1         2的1次方       2的n次方  n占用多少bit
	2个bit 00 01 10 11  4个端口  0 1 2 3  0~3      2的2次方=4 0~3
	3个bit 000 001 010 011 100 101 110 111  8个端口 0 1 2 3 4 5 6 7  0~7   2的3次方=8 0~7
   16个bit 2的16次方 1~65535
    控制字段:
	syn(1): 请求建立连接控制字段
	fin(1): 请求断开连接控制字段
	ack(1): 数据信息确认控制字段
	
	TCP三次握手过程: 
	01. 主机A向主机B发送TCP报文
	    报文中控制字段syn置为1, 请求建立连接 
	02. 主机B向主机A发送TCP响应报文
	    报文中控制字段syn置为1,ack置为1
	03. 主机A向主机B发送TCP报文 
	    报文中控制字段ack置为1, 确认主机B发送信息已经接收到了
	
	TCP四次挥手过程:
	



##############################
#  26-运维基础网络知识
##############################


00. 课程介绍部分
    1) 学习网络的课程体系            OK
	2) 两台主机通讯原理              OK
	3) 一个局域网中多台主机如何通讯 --- 交换   OK
	4) 不同局域网中多台主机如何通讯 --- 路由   OK
	5) 网络的配置操作(命令行配置)    OK
	   静态路由配置 
	   动态路由配置 RIP OSPF
    6) 网络的架构 	                  OK
	7) OSI7层模型/ TCP/IP模型         OK     
	8) TCP三次握手过程/TCP四次挥手过程  OK
	9) TCP是十一种状态集转换          OK
   10) 网络重要协议 
       DNS (域名访问网站-nginx)       OK 
	   ARP (访问IP地址--MAC地址)      OK
   11) 办公环境上网原理(家庭网络环境)OK
       虚拟主机访问外网原理          OK
   12) IP地址概念                      OK
       IP地址种类划分 192.168.10.500   OK
	   IP地址子网划分                  OK
	   交换网络vlan概念
   13) 系统中路由配置                             
       系统中网卡别名设置 *
   14) 网络中抓包软件使用
       wireshark                       OK
	   tcpdump
   15) 企业中网络排错思路
       系统主机无法访问网站
       系统主机访问网站慢    
    
01. 课程知识回顾
     
02. TCP协议重要原理
    TCP三次握手过程: 面试环节
    1) 第一次握手: 
	   发送syn请求建立连接控制字段, 发送seq序列号信息(X), 第一个数据包的系列号默认为0
	2) 第二次握手:
	   发送syn请求建立连接控制字段, 同时还会发送ack确认控制字段
	   发送seq序列号信息也为(Y), 还会发送ACK确认号(X+1)信息(对上一个数据序列号信息进行确认)
	3) 第三次握手:
	   发送ack确认控制字段,发送seq序列号信息(X+1),发送ack确认号(Y+1)

    TCP四次挥手过程: 
	1) 第一次挥手:
	   发送fin请求断开连接控制字段
	2) 第二次挥手:
	   发送ack确认控制字段 
	3) 第三次挥手:
	   发送fin请求断开连接字段, 发送ack确认字段
	4) 第四次挥手:
	   发送ack控制字段

    为什么断开连接需要4次? 
	可不可以断开连接利用3次完成?

03. TCP的十一种状态集
    TCP三次握手: 5种状态
    00: 最开始两台主机都处于关闭状态  	closed
	01: 服务端将相应服务进行开启      	closed --- listen
	02: 客户端向服务端发出连接请求    	closed --- syn_sent
	03: 服务端接收到连接请求,进行确认  listen --- syn_rcvd
	04: 客户端再次进行确认             syn_sent --- established
	05: 服务端接收到确认信息           syn_rcvd --- established
	
	TCP四次挥手:
	01: 客户端发送请求断开连接信息                  established -- fin_wait1
    02: 服务端接收断开连接请求,并进行确认           established -- close_wait
	03: 客户端接收到了确认信息                        fin_wait1   -- fin_wait2
	04: 服务端发送ack和fin字段               		  close_wait  -- last_ack
	05: 客户端接收到请求断开连接信息,发送确认        fin_wait2   -- time_wait 
	06: 服务端接收到确认信息                          last_ack   -- closed
	07: 客户端等待一段时间                           time_wait   -- closed


04. 网络中重要协议原理
    DNS: 域名解析系统
	14.215.177.39   www.baidu.com
	笔记本电脑   交换机   多个路由器    京东网站服务器
	www.baidu.com  --- 14.215.177.39
	
	金山 --- DNS的解析原理
	
	windows本地dns解析文件: C:\Windows\System32\drivers\etc\hosts
	
	ARP: 已知IP地址解析mac地址信息
	作用: 减少交换网络中广播的产生
	
	
05. IP地址概念:
    192.168.1.1 --- IP报文	
	2的32次方  
	二进制表示: 000000000000000000000000000000
	十进制表示: 0~4294967295
	
	00101010  00000000  00000000  00000000
	 十进制   十进制    十进制    十进制
	192.168.1.1  --- 点分十进制地址
	
	二进制 --> 十进制转换关系
	01010011 ---> 十进制  做求和运算
	01000000 ---> 64  64+16+2+1=83
	00010000 ---> 16
	00000010 ---> 2
	00000001 ---> 1
	
	十进制 --> 二进制转换关系
	172     ---> 二进制  做求差运算
	172 - 128 = 44 - 32 = 12 - 8 = 4 - 4 =0
	
	128 64 32 16 8  4  2  1
	0   0  0  0  0  0  0  0
	1   0  1  0  1  1  0  0
	
06. IP地址的分类
    a 按照地址的范围进行划分
	  A B C D E  
	b 按照地址用途进行划分
	  公网地址: 全球为一   护照 
	  私网地址: 重复利用地址, 避免地址枯竭, 私网地址网段不能出现在互联网路由器路由表  身份证
	            NAT
    c 按照通讯方式划分
	  单播地址:
	  网卡上配置的地址
	  广播地址:
	  主机位全为1的地址  192.168.1.11111111 --> 192.168.1.255
	  主机位全为0的地址  --- 网络地址      --> 192.168.1.0
	  
	  网络中主机数量=2的n次方-2  2的8-2=256 - 2 = 254 - 1(路由器网关地址) = 253
	  n 有多少个主机位
	  -2 一个广播地址 一个网络地址 是不能配置在网卡
	  C类地址, 一个网络中可以有 253主机
	  B类地址, 一个网络中可以有         2的16 - 3 = 65536 - 3 = 65533
	  A类地址, 一个网络中可以有         2的24 - 3 = ???
	
	  组播地址: D类地址
	  
	  192.168.1   253
	  192.168.2   253
	  
	子网划分概念: 将一个大的网络划分成几个小的网络
	
	172.16.0.0 B类地址 
	不做子网划分
	1) 一个大的网络, 不做子网划分, 造成地址浪费
	2) 一个大的网络, 不做子网划分, 造成广播风暴
	3) 一个大的网络, 不做子网划分, 造成路由压力
	做子网划分
	1) 节省IP地址
	2) 减少广播影响
	3) 减轻路由器压力
	
	如何进行子网划分
	172.16.10.0  子网掩码标识
	
	子网掩码: 32位二进制的数
	172.16.10.0  255.255.0.0
	11111111  00000000  00000000  00000000   --- 255.0.0.0     A类  /8
	11111111  11111111  00000000  00000000   --- 255.255.0.0   B类  /16
	11111111  11111111  11111111  00000000   --- 255.255.255.0 C类  /24
	
	00000000  00000000  00000000  00000000   --- IP地址网络位对应子网掩码置为1
	
	172.16.10.0     255.255.0.0
	
	面试题: 
	已知地址信息 172.16.0.0/18  172.16.0.0/16  2个主机位
	
	问题:
	01. 可以划分4个子网,子网的网络地址  OK
	02. 子网掩码信息                     ok
	03. 每个子网的主机地址范围
	
    具有30个可用IP地址的子网段，其子网掩码是： 255.255.255.224
	A类/8  2的24次方 - 2 
	B类/16 2的16次方 - 2 
	C类/24 2的8次方  - 2 253
	2*7 = 128 2*6=64 2*5=32 32-2=30
	192.168.1. 000  00000
	255.255.255.224
	
07. 办公环境上网原理 
    路由器配置:
	01. 配置上网的用户名和密码信息 实现拨号访问外网  自动获取公网地址
	    静态地址配置,在路由器外网接口配置运营商给你的公网地址
    02. 需要在路由器上配置DHCP服务信息
	03. 需要配置路由信息(静态默认路由???)
	
	虚拟主机上网原理

08. 系统路由设置
    设置方法:
    centos6: route    和网络相关的命令 使用net-tools
	静态默认路由:
	a 编写网卡配置文件
	b 利用命令临时配置
	route add default gw 10.0.0.2(网关地址)
    route del default gw 10.0.0.2
    作用: 实现主机访问外网, 用于测试新的网关地址
	
	静态网段路由:
	route add -net 10.0.3.0 netmask 255.255.255.0 gw 10.0.1.2
	route del -net 10.0.3.0 netmask 255.255.255.0 gw 10.0.1.2
	路由信息
	0.0.0.0          10.0.0.2        0.0.0.0         UG    0      0              0 eth0
	10.0.3.0         10.0.1.2        255.255.255.0         UG    0      0        0 eth0
	
	静态主机路由:
	route add -host 10.0.3.201 dev eth1
	route del -host 10.0.3.201 dev eth1

    centos7: ip route 和网络相关的命令 使用iproute
	静态默认路由:
    a 编写网卡配置文件
	b 利用命令临时配置
	ip route add default via 10.0.0.2
	ip route del default via 10.0.0.2
	
	静态网段路由:
	ip route add -net 10.0.3.0 netmask 255.255.255.0 via 10.0.1.2
	ip route del -net 10.0.3.0 netmask 255.255.255.0 via 10.0.1.2
	
	静态主机路由:
    ip route add -host 10.0.3.201 via 10.0.1.2
	ip route del -host 10.0.3.201 via 10.0.1.2
	
作业:	
01. 文字表示: DNS的解析过程  dig
02. 总结命令
03. 之前测验进行复习 文件属性 定时任务 三剑客 权限
04. 电脑或者windows系统调整好 





##############################
#  01-硬件组成概念介绍笔记
##############################




##############################
#  01-硬件组成概念介绍笔记
##############################




##############################
#  01-硬件组成概念介绍笔记
##############################




##############################
#  01-硬件组成概念介绍笔记
##############################





##############################
#  01-硬件组成概念介绍笔记
##############################




##############################
#  01-硬件组成概念介绍笔记
##############################




##############################
#  01-硬件组成概念介绍笔记
##############################






##############################
#  01-硬件组成概念介绍笔记
##############################




##############################
#  01-硬件组成概念介绍笔记
##############################




##############################
#  01-硬件组成概念介绍笔记
##############################




##############################
#  01-硬件组成概念介绍笔记
##############################





##############################
#  01-硬件组成概念介绍笔记
##############################




##############################
#  01-硬件组成概念介绍笔记
##############################




##############################
#  01-硬件组成概念介绍笔记
##############################






##############################
#  01-硬件组成概念介绍笔记
##############################




##############################
#  01-硬件组成概念介绍笔记
##############################




##############################
#  01-硬件组成概念介绍笔记
##############################




##############################
#  01-硬件组成概念介绍笔记
##############################





##############################
#  01-硬件组成概念介绍笔记
##############################




##############################
#  01-硬件组成概念介绍笔记
##############################




##############################
#  01-硬件组成概念介绍笔记
##############################


