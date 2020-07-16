

##############################
#  27-综合架构开场介绍
##############################

00. 课程介绍部分
    整体课程介绍:
	01. 备份服务
	02. 存储服务
	03. 实时同步服务
	04. 批量管理服务
	05. 网站服务(web服务)
	06. LNMP网站架构
	07. 负载均衡反向代理服务???
	08. 高可用服务
	09. 监控服务
	10. 跳板机服务
	11. 防火墙服务
	
	今天课程内容:
	01. 架构介绍
	02. 架构规划
	    网络的规划
		主机名称规划
    03. 系统优化
	    字符集优化
		安全优化(防火墙 selinux)
		远程连接优化
		命令提示符优化
		yum源优化
	04. 进行虚拟主机克隆操作
	
	上午课程: 4个小时
	下午课程: 2个小时
	
	01. 备份服务 (安装部署)
    
01. 课程知识回顾
    01. 什么是路由交换
        交换机: 实现在同一个局域网内多台主机之间的通讯
        路由器: 实现不同局域网之间主机的通讯
    02. 路由的配置方法
        静态路由
        动态路由
    03. OSI7层模型
        数据封装与解封装
    04. TCP/UDP协议
        TCP三次握手
        TCP四次挥手
        TCP十一种状态集转换(扩展)	
    05. 网络的重要原理
        DNS解析原理  域名--IP地址 
        补充: 反向DNS解析  IP地址---域名	
        ARP解析原理  IP地址---MAC地址		
    06. IP地址划分
	    IP地址的分类
		IP地址的子网划分方法
	07. linux系统中路由配置
	    静态默认网关路由
		静态网段路由
		静态主机路由


01. 中小规模网站架构组成
    1) 顾客--用户
	   访问网站的人员
	2) 保安--防火墙 (firewalld)
	   进行访问策略控制
	3) 迎宾--负载均衡服务器  (nginx)
	   对用户的访问请求进行调度处理
    4) 服务员---web服务器    (nginx)
	   处理用户的请求
	5) 厨师---数据库服务器   (mysql)
	   存储的字符数据  (耳机  500   索尼  黑色  北京地址  订单时间2019-05-05 13:00)
	6) 厨师---存储服务器     (nfs)
	   存储图片 音频 视频 附件等数据信息
	7) 厨师---备份服务器     (rsync+crond-定时备份 rsync+sersync--实时备份)
       存储网站所有服务器的重要数据
    8) 厨师---缓存服务器     (memcache redis mongodb) 
       a 将数据信息存储到内存中 
       b 减缓服务器的压力	   
    9) 经理---批量管理服务器 (ansible)
	   批量管理多台服务器主机

    部署网站架构:
	1) 需要解决网站架构单点问题
	   迎宾: 	 高可用服务---keepalived
	   数据库:   高可用服务---mha
	   存储服务: 高可用服务---keepalived实现
				  高可用服务---分布式存储
	   备份服务:  
	   面试题: 公司的数据是如何备份
	   1) 利用开源软件实现数据备份  rsync(免费)
	   2) 利用企业网盘进行数据备份  七牛云存储
	   3) 利用自建备份存储架构      两地三中心  
       缓存服务: 高可用服务--- 缓存服务集群/哨兵模式
	2) 内部员工如何远程访问架构
	   部署搭建VPN服务器 PPTP vpn
	   https://blog.oldboyedu.com/pptp-l2tp/
	3) 内部员工操作管理架构服务器要进行审计
	   跳板机服务器  jumpserver
	   https://jumpserver.readthedocs.io/zh/docs/setup_by_centos.html
	4) 架构中服务器出现问题需要进行提前报警告知
	   部署监控服务器 zabbix


02. 综合架构规划
    主机名称和IP地址规划
	01. 防火墙服务器  	firewalld    10.0.0.81(外网地址) 	172.16.1.81(内外地址)  	软件: firewalld
	02. 负载均衡服务器	lb01         10.0.0.5             	172.16.1.5            	软件: nginx keepalived
	03. 负载均衡服务器	lb02         10.0.0.6             	172.16.1.6            	软件: nginx keepalived
	04. web服务器     	web01        10.0.0.7               172.16.1.7             	软件: nginx
	05. web服务器     	web02        10.0.0.8               172.16.1.8             	软件: nginx
	06. web服务器     	web03        10.0.0.9(存储)         172.16.1.9             	软件: nginx
    07. 数据库服务器  	db01         10.0.0.51              172.16.1.51             软件: mysql(慢)  mariaDB
	08. 存储服务器    	nfs01        10.0.0.31              172.16.1.31             软件: nfs 
	09. 备份服务器    	backup       10.0.0.41              172.16.1.41             软件: rsync
    10. 批量管理服务器	m01          10.0.0.61              172.16.1.61             软件: ansible
	11. 跳板机服务器   	jumpserver   10.0.0.71(61)          172.16.1.71             软件: jumpserver
	12. 监控服务器    	zabbix       10.0.0.72(61)          172.16.1.72             软件: zabbix
	先把路走通,再进行变通
   *10. 缓存服务器     忽略
   
03. 优化配置模板主机
    1) 进行网络配置
	   a 添加网卡
	   b 配置网卡
	   vim /etc/sysconfig/network-scripts/ifcfg-eth1
       c 确认网络配置
	2) 系统优化过程
       1. 模板机优化配置---hosts文件配置
        \cp /etc/hosts{,.bak}
cat >/etc/hosts<<EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
172.16.1.5      lb01
172.16.1.6      lb02
172.16.1.7      web01
172.16.1.8      web02
172.16.1.9      web03
172.16.1.51     db01 db01.etiantian.org
172.16.1.31     nfs01
172.16.1.41     backup
172.16.1.61     m01
EOF

       2. 模板机优化配置---更改yum源
       #更改yum源
       mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup &&\
       curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
	   yum install -y wget  
       wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
       PS：yum repolist 列出yum源信息；讲解什么是epel源

       3. 模板机优化配置---关闭selinux
        #关闭selinux
        sed -i.bak 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
        grep SELINUX=disabled /etc/selinux/config 
        setenforce 0
        getenforce
          
       4. 模板机优化配置---关闭iptables 
        #关闭iptables  centos7       
        systemctl stop firewalld
		systemctl disable firewalld
		systemctl status  firewalld


       5. 模板机优化配置---提权oldboy可以sudo (可选配置)
        #提权oldboy可以sudo(可选配置)
        useradd oldboy
        echo 123456|passwd --stdin oldboy
        \cp /etc/sudoers /etc/sudoers.ori
        echo "oldboy  ALL=(ALL) NOPASSWD: ALL " >>/etc/sudoers
        tail -1 /etc/sudoers
        visudo -c

       6. 模板机优化配置---英文字符集
        #英文字符集
        localectl set-locale LANG="en_US.UTF-8"


       7. 模板机优化配置---时间同步
        #时间同步
		yum install -y ntpdate
        echo '#time sync by lidao at 2017-03-08' >>/var/spool/cron/root
        echo '*/5 * * * * /usr/sbin/ntpdate ntp1.aliyun.com >/dev/null 2>&1' >>/var/spool/cron/root
        crontab -l
       

        8. 模板机优化配置---加大文件描述
		yum install -y lsof
		lsof -i:22
        #加大文件描述
        echo '*               -       nofile          65536' >>/etc/security/limits.conf 
        tail -1 /etc/security/limits.conf
        说明:
		一个服务程序运行起来,会打开相应的文件
		crond定时任务服务---systemctl start crond --- 打开相应文件
		/var/spool/cron/root  --- 加载打开配置文件
		/var/log/cron         --- 加载打开日志文件
   		

        9. 模板机优化配置---安装其他小软件
          #安装其他小软件
          yum install lrzsz nmap tree dos2unix nc telnet wget lsof ntpdate bash-completion bash-completion-extras -y
          
        10. 模板机优化配置---ssh连接速度慢优化
          #ssh连接速度慢优化          
          sed -i.bak 's@#UseDNS yes@UseDNS no@g;s@^GSSAPIAuthentication yes@GSSAPIAuthentication no@g'  /etc/ssh/sshd_config
          systemctl restart sshd	
    

04. 进行模板主机克隆操作
    1. 进行模板机快照拍摄
	2. 进行虚拟主机克隆 
	   创建链接克隆 (学习环境)
	   优势:
	   a 节省物理主机资源
	   b 克隆主机效率快
	   劣势:
	   a 模板主机删除,链接主机也会失效
	  
	   创建完整克隆 (企业应用)
	   优势:
	   a 模板主机删除,克隆主机依然可以使用
	   劣势:
	   a 比较消耗物理主机资源
	   b 克隆主机效率低  
    3. 克隆后虚拟主机配置
       a 修改主机名称
	   hostnamectl set-hostname backup
       b 修改主机地址
	   sed -i 's#200#41#g' /etc/sysconfig/network-scripts/ifcfg-eth[01]
	   grep 41 /etc/sysconfig/network-scripts/ifcfg-eth[01]
       sed -i '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-eth[01]
       grep UUID /etc/sysconfig/network-scripts/ifcfg-eth[01]
	   systemctl restart network
       PS: 一台一台顺序启动,进行修改,不要同时启动	  

       补充: 克隆好的主机无法远程连接:
	   解决方式:
	   01. 利用ping方式测试
	   02. 关闭xshell软件重新打开
       	   

05. 备份服务器说明
    作用:
	01. 数据备份的服务器
	02. 进行日志统一保存
	[root@nfs01 backup]# grep -r oldboy /backup/
    /backup/10.0.0.7_bak/oldboy.log:oldboy
	
	如何部署搭建备份服务器: rsync服务
	
06. 什么是rsync服务
    Rsync是一款开源的、快速的、多功能的、可实现全量及增量的本地或远程数据同步备份的优秀工具
    
07. rsync软件使用方法:
    rsync命令  1v4
	
	a 本地备份数据 cp
	[root@nfs01 backup]# cp /etc/hosts /tmp
    [root@nfs01 backup]# ll /tmp/hosts
    -rw-r--r-- 1 root root 371 May  6 16:11 /tmp/hosts
	[root@nfs01 backup]# rsync /etc/hosts /tmp/host_rsync
    [root@nfs01 backup]# ll /tmp/host_rsync
    -rw-r--r-- 1 root root 371 May  6 16:12 /tmp/host_rsync
	
	b 远程备份数据 scp
	scp -rp /etc/hosts root@172.16.1.41:/backup
    root@172.16.1.41's password: 
    hosts         100%  371    42.8KB/s   00:00
    -r    --- 递归复制传输数据
    -p    --- 保持文件属性信息不变
    [root@nfs01 ~]# rsync -rp /etc/hosts 172.16.1.41:/backup/hosts_rsync
    root@172.16.1.41's password: 	
	
	rsync远程备份目录:
	[root@nfs01 ~]# rsync -rp /oldboy 172.16.1.41:/backup   --- 备份的目录后面没有 /
    root@172.16.1.41's password: 
	[root@backup ~]# ll /backup
    total 0
    drwxr-xr-x 2 root root 48 May  6 16:22 oldboy
    [root@backup ~]# tree /backup/
    /backup/
    └── oldboy
        ├── 01.txt
        ├── 02.txt
        └── 03.txt
    
    1 directory, 3 files

    [root@nfs01 ~]# rsync -rp /oldboy/ 172.16.1.41:/backup  --- 备份的目录后面有 / 
    root@172.16.1.41's password:
    [root@backup ~]# ll /backup
    total 0
    -rw-r--r-- 1 root root 0 May  6 16:24 01.txt
    -rw-r--r-- 1 root root 0 May  6 16:24 02.txt
    -rw-r--r-- 1 root root 0 May  6 16:24 03.txt
	总结: 在使用rsync备份目录时:
	备份目录后面有  / -- /oldboy/ : 只将目录下面的内容进行备份传输 
	备份目录后面没有/ -- /oldboy  : 会将目录本身以及下面的内容进行传输备份
	
	c 替代删除命令
	rm命令
	[root@nfs01 ~]# rsync -rp --delete /null/ 172.16.1.41:/backup
    root@172.16.1.41's password: 
	--delete   实现无差异同步数据
	面试题: 有一个存储数据信息的目录, 目录中数据存储了50G数据, 如何将目录中的数据快速删除
	rm /目录/* -rf
	
	d 替代查看文件命令 ls 
	[root@backup ~]# ls /etc/hosts
    /etc/hosts
    [root@backup ~]# rsync /etc/hosts
    -rw-r--r--            371 2019/05/06 11:55:22 hosts
	
08 rsync命令语法格式
   SYNOPSIS
   Local:  rsync [OPTION...] SRC... [DEST]
   本地备份数据: 
   src: 要备份的数据信息
   dest: 备份到什么路径中

   远程备份数据:
   Access via remote shell:
   Pull: rsync [OPTION...] [USER@]HOST:SRC... [DEST]
   [USER@]    --- 以什么用户身份拉取数据(默认以当前用户)
   hosts      --- 指定远程主机IP地址或者主机名称
   SRC        --- 要拉取的数据信息
   dest       --- 保存到本地的路径信息
   
   Push: rsync [OPTION...] SRC... [USER@]HOST:DEST
   SRC        --- 本地要进行远程传输备份的数据
   [USER@]    --- 以什么用户身份推送数据(默认以当前用户)
   hosts      --- 指定远程主机IP地址或者主机名称
   dest       --- 保存到远程的路径信息

   守护进程方式备份数据 备份服务 
   01. 可以进行一些配置管理
   02. 可以进行安全策略管理
   03. 可以实现自动传输备份数据
   Access via rsync daemon:
   Pull: rsync [OPTION...] [USER@]HOST::SRC... [DEST]
         rsync [OPTION...] rsync://[USER@]HOST[:PORT]/SRC... [DEST]
   Push: rsync [OPTION...] SRC... [USER@]HOST::DEST
         rsync [OPTION...] SRC... rsync://[USER@]HOST[:PORT]/DEST

09. rsync服务部署安装过程
    linux系统安装部署服务流程:
	a 下载安装软件  yum 
	b 编写配置文件
	c 搭建服务环境  备份的目录/目录权限
    d 启动服务程序	 开机自动启动
	e 测试服务功能
 
10. 课程总结
    01. 网站架构组成 
    02. 网站架构规划(主机名称 主机地址 系统优化(脚本))
    03. 虚拟主机克隆操作
        a 关闭主机--链接克隆	
		b 克隆好的主机一台一台按顺序启动,修改配置(主机名称 主机地址)
	04. rsync备份服务
	    rsync命令用法  1v4 
		rsync语法格式  本地备份 远程备份 

作业:
01. 将其他虚拟主机克隆配置完成	
02. 预习rsync守护进程部署方法

企业项目: 全网备份数据项目 





##############################
#  28-综合架构备份服务
##############################


00. 课程介绍部分
    1) 完成rsync守护进程模式搭建
	2) rsync备份传输数据原理
	3) rsync命令的常用参数
	4) 企业应用rsync技巧
	5) rsync常见错误
	6) 企业项目: 全网备份项目(脚本)
  
    
01. 课程知识回顾
    1) 综合架构的组成部分
	   前端: 防火墙 负载均衡 web服务器
	   后端: 数据库 存储服务 缓存服务 备份服务
	   扩展: 批量管理 跳板机 监控服务 vpn服务
    2) 综合架构的规划
	   IP地址规划
	   主机名称规划
	   系统的优化部分
    3) 虚拟主机克隆部分
	   a 模板机关机克隆--链接克隆
	   b 克隆好的主机需要一台一台按顺序进行配置
	     1. 不要随意修改调整虚拟主机的mac地址
		 2. NetworkManager网络管理服务  	技术经理  nmtui   关闭
		    network网络服务              	运维主管  ifcfg-eth0
	4) 备份服务 
	   rsync软件: 全量和增量备份的软件
    5) rsync命令使用方法 1v4
	6) rsync命令语法 man rsync
	   本地备份
	   远程备份
	   守护进程方式备份


02. rsync守护进程部署方式
    客户端---服务端  上厕所 4 
    rsync守护进程服务端配置:
    第一个历程: 下载安装软件
	rpm -qa|grep rsync
    yum install -y rsync 
	
	第二个历程: 编写配置文件
	man rsyncd.conf
	vim /etc/rsyncd.conf 
	##created by HQ at 2017
    ###rsyncd.conf start##
    
    uid = rsync       --- 指定管理备份目录的用户  
    gid = rsync       --- 指定管理备份目录的用户组
    port = 873        --- 定义rsync备份服务的网络端口号
    fake super = yes  --- 将rsync虚拟用户伪装成为一个超级管理员用户 
    use chroot = no   --- 和安全相关的配置
    max connections = 200  --- 最大连接数  同时只能有200个客户端连接到备份服务器
    timeout = 300          --- 超时时间(单位秒)
    pid file = /var/run/rsyncd.pid   --- 记录进程号码信息 1.让程序快速停止进程 2. 判断一个服务是否正在运行
    lock file = /var/run/rsync.lock  --- 锁文件
    log file = /var/log/rsyncd.log   --- rsync服务的日志文件 用于排错分析问题
    ignore errors                    --- 忽略传输中的简单错误
    read only = false                --- 指定备份目录是可读可写
    list = false                     --- 使客户端可以查看服务端的模块信息
    hosts allow = 172.16.1.0/24      --- 允许传输备份数据的主机(白名单)
    hosts deny = 0.0.0.0/32          --- 禁止传输备份数据的主机(黑名单)
    auth users = rsync_backup        --- 指定认证用户 
    secrets file = /etc/rsync.password   --- 指定认证用户密码文件 用户名称:密码信息
    [backup]                         --- 模块信息
    comment = "backup dir by oldboy"  
    path = /backup                   --- 模块中配置参数 指定备份目录

	第三个历程: 创建rsync服务的虚拟用户
	useradd rsync -M -s /sbin/nologin
	
	第四个历程: 创建备份服务认证密码文件
	echo "rsync_backup:oldboy123" >/etc/rsync.password
	chmod 600 /etc/rsync.password
	
	第五个历程: 创建备份目录并修改属主属组信息
	mkdir /backup
    chown rsync.rsync /backup/
	
	第六个历程: 启动备份服务
	systemctl start rsyncd
    systemctl enable rsyncd
    systemctl status rsyncd

    需要熟悉rsync守护进程名称语法:
	Access via rsync daemon:
	客户端做拉的操作: 恢复数据
    Pull: rsync [OPTION...] [USER@]HOST::SRC... [DEST]
          rsync [OPTION...] rsync://[USER@]HOST[:PORT]/SRC... [DEST]
	客户端做退的操作: 备份数据
    Push: rsync [OPTION...] SRC... [USER@]HOST::DEST
	      src: 要推送备份数据信息
		  [USER@]: 指定认证用户信息
		  HOST: 指定远程主机的IP地址或者主机名称
		  ::DEST: 备份服务器的模块信息
		  
          rsync [OPTION...] SRC... rsync://[USER@]HOST[:PORT]/DEST

    rsync守护进程客户端配置:
	第一个历程: 创建一个秘密文件
	echo "oldboy123" >/etc/rsync.password
	chmod 600 /etc/rsync.password
   
    第二个历程: 进行免交互传输数据测试
	rsync -avz /etc/hosts rsync_backup@172.16.1.41::backup --password-file=/etc/rsync.password
	
03. rsync命令参数详细说明
    -v, --verbose     显示详细的传输信息
	-a, --archive     命令的归档参数 包含: rtopgDl
	-r, --recursive   递归参数
	-t, --times       保持文件属性信息时间信息不变(修改时间)
	-o, --owner       保持文件属主信息不变
	-g, --group       保持文件属组信息不变
	PS: 如何让-o和-g参数生效,需要将配置文件uid和gid改为root,需要将 fake super参数进行注释
	-p, --perms       保持文件权限信息不变
	-D,               保持设备文件信息不变
	-l, --links       保持链接文件属性不变
	-L,               保持链接文件数据信息不变
	-P,               显示数据传输的进度信息
	--exclude=PATTERN   排除指定数据不被传输
	--exclude-from=file 排除指定数据不被传输(批量排除)
	--bwlimit=RATE    显示传输的速率  100Mb/8=12.5MB
	                  企业案例:    马路(带宽-半)   人人网地方 
    --delete          无差异同步参数(慎用)
	                  我有的你也有,我没有的你也不能有
	
04. 守护进程服务企业应用:
    a. 守护进程多模块功能配置
	sa  sa_data.txt
	dev dev_data.txt
	dba dba_data.txt
	[backup]
    comment = "backup dir by oldboy"
    path = /backup
    [dba]
    comment = "backup dir by oldboy"
    path = /dba
    [dev]
    comment = "backup dir by oldboy"
    path = /devdata

    b. 守护进程的排除功能实践
	准备环境:
	[root@nfs01 /]# mkdir -p /oldboy
    [root@nfs01 /]# mkdir -p /oldboy/{a..c}
    [root@nfs01 /]# touch /oldboy/{a..c}/{1..3}.txt
    [root@nfs01 /]# tree /oldboy
    /oldboy
    ├── 01.txt
    ├── 02.txt
    ├── a
    │?? ├── 1.txt
    │?? ├── 2.txt
    │?? └── 3.txt
    ├── b
    │?? ├── 1.txt
    │?? ├── 2.txt
    │?? └── 3.txt
    └── c
        ├── 1.txt
        ├── 2.txt
        └── 3.txt

    需求01: 将/oldboy目录下面 a目录数据全部备份 b目录不要备份1.txt文件 c整个目录不要做备份
    --exclude=PATTERN
    绝对路径方式:
    [root@nfs01 /]# rsync -avz /oldboy --exclude=/oldboy/b/1.txt --exclude=/oldboy/c/ rsync_backup@172.16.1.41::backup --password-file=/etc/rsync.password 
    sending incremental file list
    oldboy/
    oldboy/01.txt
    oldboy/02.txt
    oldboy/a/
    oldboy/a/1.txt
    oldboy/a/2.txt
    oldboy/a/3.txt
    oldboy/b/
    oldboy/b/2.txt
    oldboy/b/3.txt
 
    相对路径方式:
	[root@nfs01 /]# rsync -avz /oldboy --exclude=b/1.txt --exclude=c/ rsync_backup@172.16.1.41::backup --password-file=/etc/rsync.password 
    sending incremental file list
    oldboy/
    oldboy/01.txt
    oldboy/02.txt
    oldboy/a/
    oldboy/a/1.txt
    oldboy/a/2.txt
    oldboy/a/3.txt
    oldboy/b/
    oldboy/b/2.txt
    oldboy/b/3.txt
    
    sent 502 bytes  received 177 bytes  1,358.00 bytes/sec
    total size is 0  speedup is 0.00

    需求02: 将/oldboy目录下面 a目录数据全部备份 b目录不要备份1.txt文件 c整个目录1.txt 3.txt文件不要备份
    --exclude-from=file  --- 批量排除 
	第一个历程: 编辑好一个排除文件
	[root@nfs01 /]# cat /oldboy/exclude.txt 
    b/1.txt
    c/1.txt
    c/3.txt
    exclude.txt

	第二个历程: 实现批量排除功能
	[root@nfs01 /]# rsync -avz /oldboy --exclude-from=/oldboy/exclude.txt rsync_backup@172.16.1.41::backup --password-file=/etc/rsync.password 
    sending incremental file list
    oldboy/
    oldboy/01.txt
    oldboy/02.txt
    oldboy/a/
    oldboy/a/1.txt
    oldboy/a/2.txt
    oldboy/a/3.txt
    oldboy/b/
    oldboy/b/2.txt
    oldboy/b/3.txt
    oldboy/c/
    oldboy/c/2.txt

    c. 守护进程来创建备份目录
    [root@nfs01 /]# rsync -avz /etc/hosts  rsync_backup@172.16.1.41::backup/10.0.0.31/ --password-file=/etc/rsync.password 
    sending incremental file list
    created directory 10.0.0.31
    hosts
    
    sent 226 bytes  received 75 bytes  602.00 bytes/sec
    total size is 371  speedup is 1.23
	PS: 客户端无法在服务端创建多级目录
	
	d. 守护进程的访问控制配置
	守护进程白名单和黑名单功能
	PS: 建议只使用一种名单
	
	e. 守护进程的列表功能配置
	[root@nfs01 /]# rsync rsync_backup@172.16.1.41::
    backup         	"backup dir by oldboy"
    dba            	"backup dir by oldboy"
    dev            	"backup dir by oldboy"
	
	
作业:
01. 自己试着完成全网备份数据项目
02. 总结每个服务的部署过程


##############################
#  29-综合架构备份项目
##############################


00. 课程介绍部分
    1) 根据需求搭建环境
	2) 按照需求编写脚本
	3) 进行功能测试
    4) NFS存储服务
  
01. 课程知识回顾
    1) rsync守护进程的部署过程
	服务端部署
	a 下载安装软件
	b 编写配置文件*****
	c 创建虚拟用户(管理备份存储目录)
	d 创建认证密码文件(修改文件权限为600)
	e 创建备份目录(修改目录属主属组信息)
	f 启动守护进程服务
	客户端部署
	a 创建认证密码文件(只有密码信息即可)
	b 进行免交互传输测试  --password-file=密码文件
	
	2) rsync备份传输数据的原理
	a 有用户的身份转换 其他所有用户---rsync
	b 用户存储数据的权限 (目录本身权限755 目录的属主信息rsync)
	
	3) rsync服务的常见错误
	4) rsync命令的参数信息  -avz(压缩数据)
	5) rsync服务的企业应用
	   服务的多模块配置
	   服务的排除功能
	   服务的备份目录创建
	   服务的列表功能
	   服务的策略控制
	   服务的无差异同步
    
02. 全网备份项目环境准备
    三台服务器准备完毕
	
03. 完成项目需求
    1)所有服务器的备份目录必须都为/backup   OK
	  web01 nfs01 backup
	
    2)要备份的系统配置文件包括但不限于：    OK  
      a.定时任务服务的配置文件(/var/spool/cron/root)（适合web和nfs服务器）。
      b.开机自启动的配置文件(/etc/rc.local)（适合web和nfs服务器）。
      c.日常脚本的目录(/server/scripts)。
      d.防火墙iptables的配置文件(/etc/sysconfig/iptables)。
      e.自己思考下还有什么需要备份呢？ 
	  web01 nfs01
	  
	  
    3)Web服务器站点目录假定为(/var/html/www)。  OK 
    4)Web服务器A访问日志路径假定为（/app/logs） OK
	  web01
	
	
    5)Web服务器保留打包后的7天的备份数据即可(本地留存不能多于7天，因为太多硬盘会满)  OK
	  web01 nfs01
	
    6)备份服务器上,保留每周一的所有数据副本，其它要保留6个月的数据副本。             OK
	  部署好rsync守护进程服务 
	  backup
	
    7)备份服务器上要按照备份数据服务器的内网IP为目录保存备份，备份的文件按照时间名字保存。OK
	
	
    8)需要确保备份的数据尽量完整正确，在备份服务器上对备份的数据进行检查，把备份的成功及失败结果信息发给系统管理员邮箱中（发邮件技巧见VIP群资料）。
      backup 

    

    备份客户端要完成的工作
	mkdir -p /backup/10.0.0.31/
	
	cd /
    tar zchf /backup/system_backup_$(date +%F_week%w).tar.gz ./var/spool/cron/root ./etc/rc.local ./server/scripts ./etc/sysconfig/iptables
	tar zchf /backup/www_backup_$(date +%F_week%w).tar.gz  ./var/html/www
	tar zchf /backup/www_log_backup_$(date +%F_week%w).tar.gz  ./app/logs

	find /backup -type f -mtime +7|xargs rm 
	
	find /backup/ -type f -mtime -1 ! -name "finger*"|xargs md5sum >/backup/10.0.0.31/finger.txt
	
	rsync -avz /backup/ rsync_backup@172.16.1.41::backup --password-file=/etc/rsync.password
	

	补充: 
	01. tar命令用法
	    -h, --dereference          follow symlinks; archive and dump the files they point to
		                           将链接文件所指向的原文件进行保存备份
	
	备份服务端要完成的工作

	find /backup/ -type f -mtime +180 ! -name "*week1.tar.gz"
	
	find /backup/ -type f -name "finger.txt"|xargs md5sum -c >/tmp/check.txt
	
	mail -s "邮件测试" 330882721@qq.com </tmp/check.txt

	补充说明:
	01. 保留周一数据的方法
	    a 在数据名称信息上加上周的信息
		find /backup/ -type f -mtime +180 ! -name "*week1.tar.gz"
        b 在服务端进行检查,将每周一传输的数据进行单独保存
    02. 如何验证数据完整性
	    利用md5算法进行验证数据完整性
		#md5sum -c 指纹文件命令执行原理
        # 第一个历程: 打开一个指纹文件,将信息记录到缓存中
        # 第二个历程: 根据指纹文件的路径信息,生成md5数值信息
        # 第三个历程: 将新生成md5数值和原有指纹文件中的数值进行比较
        # 第四个历程: 如果相同显示结果为ok,如果不同显示failed
    03. 如何实现发送邮件
	    a 配置163企业邮箱
		b 编写linux服务邮件相关配置文件
		vim /etc/mail.rc
		set from=17778058507@163.com smtp=smtp.163.com    		     
        set smtp-auth-user=17778058507@163.com smtp-auth-password=oldboy123 smtp-auth=login
		systemctl restart postfix.service
		c 发送邮件测试
		echo "邮件发送测试"|mail -s "邮件测试" 330882721@qq.com
        mail -s "邮件测试" 330882721@qq.com </etc/hosts 

04. 编写全网备份脚本
    客户端脚本:
	nfs01服务器备份脚本:
    省略:
	
	web01服务器备份脚本:
	省略

	服务端脚本:
	
	测试检验脚本方法: sh -x 脚本信息

05. 实现自动完成全网数据备份(定时任务)
    客户端定时任务:
	crontab -e 
	# backup data
	0 0 * * *  /bin/sh /server/scripts/backup.sh &>/dev/null
	
	服务端定时任务
	# check backup data
	0 5 * * *  /bin/sh /server/scripts/backup_server.sh &>/dev/null

06. 还有什么完善余地 


##############################
#  30-综合架构存储服务
##############################


00. 课程介绍部分
    1) 存储服务的概念
	2) 存储服务的部署(NFS)
	3) 存储服务的配置
	   服务端配置操作
	   客户端配置操作
	4) 存储服务的原理(数据无法存储)
	5) 客户端挂载应用
	   mount -o ro
	6) 存储服务企业应用

  
01. 课程知识回顾
    1) 项目完成前项目规划(和领导确认)
	2) 按照规划一步一步完成任务
	   如何编写脚本实现运维自动化(逻辑)
	3) 进行检查测试
	
02. NFS存储服务概念介绍
    NFS是Network File System的缩写,中文意思是网络文件共享系统，
	它的主要功能是通过网络（一般是局域网）让不同的主机系统之间可以共享文件或目录
	存储服务的种类
	用于中小型企业: 实现数据共享存储
	FTP(文件传输协议)   
	运维01    服务器A  服务器B     FTP服务器
	运维02    服务器C  服务器D
    中小型电商公司(游戏点卡 游戏币 道具 Q币 充值话费) --- 财务对账信息(数据库) --- 对账文件 --- FTP服务器
    权限(用户认证的权限  存储目录的权限(用户))
	获取数据的方式 ??? SSH远程服务 sFTP
	samba     windows--linux之间数据传输  Linux部署samba
	NFS       linux--linux之间数据传输
    用于门户网站:
	一个用户    -- 存储服务器
	上万个用户  -- 存储服务器
	利用分布式存储   
	Moosefs（mfs） 比较落伍,初学学习比较简单
	GlusterFS      
	FastDFS        企业应用较多
	
03. NFS存储服务作用
    1) 实现数据的共享存储
    2) 编写数据操作管理
    3) 节省购买服务器磁盘开销 淘宝--上万 用电开销	
	
04. NFS服务部署流程	
    RPC: 远程过程调用服务程序--- 相当于租房的中介(网络编程支持)
	服务端部署
	第一个历程: 下载安装软件
	rpm -qa|grep -E "nfs|rpc"
	yum install -y nfs-utils rpcbind

    第二个历程: 编写nfs服务配置文件
	vim /etc/exports (man exports)
	01     02(03)
	01: 设置数据存储的目录 /data
	02: 设置网络一个白名单 (允许哪些主机连接到存储服务器进行数据存储)
	03: 配置存储目录的权限信息 存储目录一些功能
	/data   172.16.1.0/24(rw,sync)

    第三个历程: 创建一个存储目录
	mkdir /data
	chown nfsnobody.nfsnobody /data
	
    第四个历程: 启动服务程序
	先启动 rpc服务
	systemctl start rpcbind.service 
    systemctl enable rpcbind.service
	再启动 nfs服务
	systemctl start nfs
    systemctl enable nfs
	
	客户端部署
	第一个历程: 安装nfs服务软件
	yum install -y nfs-utils

	第二个历程: 实现远程挂载共享目录
	mount -t nfs 172.16.1.31:/data  /mnt 
	
05. NFS服务工作原理:
    服务端:
	1. 启动rpc服务,开启111端口
	2. 启动nfs服务
	3. 实现nfs服务进程和端口好的注册
	
	补充: 检查nfs服务进程与端口注册信息
	没有注册时候：
	[root@nfs01 ~]# rpcinfo -p 172.16.1.31
    program vers proto   port  service
     100000    4   tcp    111  portmapper
     100000    3   tcp    111  portmapper
     100000    2   tcp    111  portmapper
     100000    4   udp    111  portmapper
     100000    3   udp    111  portmapper
     100000    2   udp    111  portmapper
	nfs服务注册之后信息：
	[root@nfs01 ~]# rpcinfo -p 172.16.1.31
    program vers proto   port  service
     100000    4   tcp    111  portmapper
     100000    3   tcp    111  portmapper
     100000    2   tcp    111  portmapper
     100000    4   udp    111  portmapper
     100000    3   udp    111  portmapper
     100000    2   udp    111  portmapper
     100024    1   udp  53997  status
     100024    1   tcp  49863  status
     100005    1   udp  20048  mountd
     100005    1   tcp  20048  mountd
     100005    2   udp  20048  mountd
     100005    2   tcp  20048  mountd
     100005    3   udp  20048  mountd
     100005    3   tcp  20048  mountd

	客户端:
	1. 建立TCP网络连接
	2. 客户端执行挂载命令，进行远程挂载
	3. 可以实现数据远程传输存储
	
06. nfs服务端详细配置说明	
	实现多个网段主机可以进行挂载
	第一种方法：
	/data   172.16.1.0/24(rw,sync) 10.0.0.0/24(rw,sync)
	第二种方法：
	/data   172.16.1.0/24(rw,sync) 
	/data   10.0.0.0/24(rw,sync)
	
	总结：共享目录的权限和哪些因素有关：
	1）和存储目录的本身权限有关 （755 属主：nfsnobody）
	2）和配置文件中的权限配置有关 rw/ro  xxx_squash  anonuid/anongid
    3）和客户端挂载命令的参数有关  ro
	？？
	
	NFS配置参数权限
    rw   -- 存储目录是否有读写权限
	ro   -- 存储目录是否时只读权限
	sync   -- 同步方式存储数据 直接将数据保存到磁盘（数据存储安全）
	async  -- 异步方式存储数据 直接将数据保存到内存（提高数据存储效率）
	no_root_squash  -- 不要将root用户身份进行转换   
	root_squash     -- 将root用户身份进行转换
	all_squash      -- 将所有用户身份都进行转换 
	no_all_squash   -- 不要将普通用户身份进行转换

    操作演示all_squash参数功能：
	vim /etc/exports
	/data   172.16.1.0/24(ro,sync,all_squash)
    [oldboy@backup mnt]$ touch oldboy_data.txt
    [oldboy@backup mnt]$ ll
    total 4
    -rw-rw-r-- 1 nfsnobody nfsnobody 0 May  9 12:11 oldboy_data.txt

    操作演示no_all_squash参数功能：
	[root@nfs01 ~]# vim /etc/exports
    /data   172.16.1.0/24(rw,sync,no_all_squash)
    [oldboy@backup mnt]$ touch oldboy_data02.txt
    touch: cannot touch ‘oldboy_data02.txt’: Permission denied
    解决权限问题：
    [root@nfs01 ~]# chmod o+w /data/
    [root@nfs01 ~]# ll /data/ -d
    drwxr-xrwx. 2 nfsnobody nfsnobody 52 May  9 12:11 /data/
	[oldboy@backup mnt]$ touch oldboy_data02.txt
    [oldboy@backup mnt]$ ll
    total 4
    -rw-r--r-- 1 nfsnobody nfsnobody 7 May  9 10:57 backup_data.txt
    -rw-rw-r-- 1 oldboy    oldboy    0 May  9 12:17 oldboy_data02.txt
    -rw-rw-r-- 1 nfsnobody nfsnobody 0 May  9 12:11 oldboy_data.txt

    操作演示root_squash参数功能：
	vim /etc/exports
    /data   172.16.1.0/24(rw,sync,root_squash)
	[root@backup mnt]# touch root_data.txt
    [root@backup mnt]# ll
    -rw-r--r-- 1 nfsnobody nfsnobody 0 May  9 12:20 root_data.txt
	
	操作演示no_root_squash参数功能
    [root@backup mnt]# ll
    total 4
    -rw-r--r-- 1 root      root      0 May  9 12:23 root_data02.txt

	企业互联网公司如何配置NFS 各种squash参数
	保证网站存储服务器用户数据安全性：
	no_all_squash  需要进行配置   共享目录权限为www（确保客户端用户 服务端用户 uid数值一致）
	root_squash    需要进行配置   root---nfsnobody    data目录---www
	以上默认配置（很多服务默认配置都是从安全角度出发）
	如何查看nfs默认配置
	cat /var/lib/nfs/etab    --- 记录nfs服务的默认配置记录信息
	/data   172.16.1.0/24(rw,sync,wdelay,hide,nocrossmnt,secure,root_squash,no_all_squash,no_subtree_check,secure_locks,acl,n
    o_pnfs,anonuid=65534,anongid=65534,sec=sys,rw,secure,root_squash,no_all_squash)
	
	如何让root用户可以操作管理www用户管理的data目录
	root  --- root_squash --- www  ---操作--- data目录
	anonuid=65534,anongid=65534    --- 可以指定映射的用户信息

	修改映射用户：www=1002
	/data   172.16.1.0/24(rw,sync,anonuid=1002,anongid=1002)
	
	企业中如何编辑nfs配置文件
	01. 通用方法 *****
	/data   172.16.1.0/24(rw,sync)
	02. 特殊情况 （让部分人员不能操作存储目录 可以看目录中的数据）
	/data   10.0.0.0/24(ro,sync)
	03. 修改默认的匿名用户
	/data   10.0.0.0/24(ro,sync,anonuid=xxx,anongid=xxx)
	
	nfs服务问题：
	01. nfs服务器重启，挂载后创建数据比较慢
	服务器重启方式不正确
	服务重启：
	01. restart 重启服务             	强制断开所有连接            用户感受不好
	02. reload  重启服务（平滑重启） 	强制断开没有数据传输的连接  提升用户感受
	
07. nfs客户端详细配置说明	
    mount -t nfs 172.16.1.31:/data  /mnt	
	
	如何实现自动挂载：
	01. 利用rc.local
	echo "mount -t nfs 172.16.1.31:/data /mnt" >>/etc/rc.local
	02. 利用fstab文件
	vim /etc/fstab
	172.16.1.31:/data                         /mnt                    nfs     defaults        0 0
    特殊的服务已经开启了
	
	centos6：无法实现网路存储服务自动挂载原因
	根据系统服务启动顺序
	按照顺序依次启动  network服务--- sshd服务--- crond服务--- rsync服务--- rpcbind服务---  nfs服务
	先加载/etc/fstab  ---  network服务  --- autofs服务
	
	autofs服务程序：开机自动启动
	服务启动好之后，重新加载fstab  
	
	centos7：无法实现网路存储服务自动挂载原因
	根据系统服务启动顺序
	network服务
	sshd服务
	crond服务
	rsync服务
	先加载/etc/fstab  network服务
	autofs==centos7？？
	
	客户端mount命令参数
	rw   --- 实现挂载后挂载点目录可读可写  （默认）
	ro   --- 实现挂载后挂载点目录可读可写
	suid --- 在共享目录中可以让setuid权限位生效  （默认）
  nosuid --- 在共享目录中可以让setuid权限位失效   提供共享目录的安全性
	exec --- 共享目录中的执行文件可以直接执行
  noexec --- 共享目录中的执行文件可以无法直接执行 提供共享目录的安全性
	auto --- 可以实现自动挂载     mount -a 实现加载fstab文件自动挂载
  noauto --- 不可以实现自动挂载
  nouser --- 禁止普通用户可以卸载挂载点
    user --- 允许普通用户可以卸载挂载点
	[oldboy@web01 ~]$ umount /mnt
    umount: /mnt: umount failed: Operation not permitted

	客户端如何卸载
	umount -lf /mnt    --- 强制卸载挂载点
	-l  不退出挂载点目录进行卸载  
	-f  强制进行卸载操作
	
08. 课程总结：
    1）NFS存储服务器概念
	2）NFS存储工作原理图 
	3）NFS存储服务部署
	4）NFS服务端详细配置说明
	   服务端配置参数  xxx_squash 
    5) NFS客户端详细配置说明
       如何实现自动挂载 
       客户端挂载参数说明	man mount   
	   如何强制卸载共享目录   	
	
作业：
01. 实现fatab文件自动挂载的特殊服务是什么？
02. 研究user参数作用
03. NFS服务部署过程	

实时同步服务
SSH远程服务





##############################
#  31-综合架构实时同步服务
##############################

00. 课程介绍部分
    1）实现实时同步数据的原理
	2）实时实时同步数据的方法
	   a 部署好rsync守护进程服务
	   b 部署好inotify监控服务
	   c 部署好sersync实时同步服务
	3）实现实时同步数据的验证

01. 课程知识回顾
    1）NFS存储服务概念介绍
	   a 实现数据的共享存储
	   b 降低公司磁盘购买成本
	2）NFS存储服务工作原理
	   a 部署好一台存储服务器，设置好存储目录
	   b 客户端利用网络挂载的方式进行挂载存储目录
	   c 将数据存储在客户端本地挂载点目录==存储到存储服务器中
    3）NFS服务部署流程
	   RPC：类似于租房的中介  NFS服务启动会有多个进程多个端口（随机端口），客户端不方便连接服务端
       服务端部署
	   第一步：安装存储服务软件  nfs-utils rpcbind
	   第二步：编写配置文件
	   第三步：创建存储目录，并修改属主权限
	   第四步：启动服务/开机自动
	           rpcbind
			   nfs
	   客户端部署：
	   第一步：安装nfs服务软件
	   第二步：实现网络存储服务挂载
	            mount -t nfs 172.16.1.31:/data  挂载点目录
	   
	   NFS服务挂载不上排查方法：
	   服务端进行排查：
	   1. 检查nfs进程信息是否注册
	      rpcinfo -p localhost/172.16.1.31
		  问题原因：
		  服务启动顺序不对，没有启动nfs服务
	   2. 检查有没有可用存储目录
	      showmount -e 172.16.1.31
          问题原因： 
		  配置文件编写有问题，重启nfs服务
	   3. 在服务端进行挂载测试
	      是否能够在存储目录中创建或删除数据
	   客户端测试：
	   1. 检查nfs进程信息是否注册
	      rpcinfo -p localhost/172.16.1.31
		  问题原因：
		  服务启动顺序不对，没有启动nfs服务
	   2. 检查有没有可用存储目录
	      showmount -e 172.16.1.31
          问题原因： 
		  配置文件编写有问题，重启nfs服务
	      网络问题
		  ping 172.16.1.31 
		  telnet 172.16.1.31 111
	   
    4）NFS服务端配置参数
	   xxx_squash
	   
	5) NFS客户端配置说明
       mount -t 
       实现开机自动挂载
       /etc/rc.local   文件要有执行权限
       /etc/fstab      实现fstab文件挂载自动加载nfs存储目录 必须让remote-fs.target服务开机自启  
                       centos7  必须启动   remote-fs.target 
                       centos6  必须启动   netfs					   
	   
	   需求问题：如何找到一台服务器开机运行了哪些服务
	   ll /etc/systemd/system/multi-user.target.wants/
	   
	   客户端挂载的命令参数
	   
	   
03. 实时同步服务原理/概念	  
    1）需要部署好rsync守护进程服务，实现数据传输
    2）需要部署好inotify服务，实现目录中数据变化监控
    3）将rsync服务和inotify服务建立联系，将变化的数据进行实时备份传输	
	   
	   
04. 实时同步服务部署
    1）部署rsync守护进程
       服务端配置操作
       客户端配置操作	   
	2）部署inotify监控服务 
	   第一个步骤：安装软件
	   yum install -y inotify-tools
	   
	   第二个步骤：熟悉命令的使用
	   /usr/bin/inotifywait    --- 监控目录数据信息变化
       /usr/bin/inotifywatch   --- 对监控的变化信息进行统计
	   
	   /data/  oldboy01.txt   
	           oldboy02.txt   --- rsync --exclude
			   oldboy03.txt   
	   
	   inotifywait命令使用方法：
	   inotifywait [参数]  监控的目录
	   -m|--monitor   --- 实现一直监控目录的数据变化
	   -r|--recursive --- 进行递归监控
	   -q|--quiet     --- 尽量减少信息的输出
	   --format <fmt> --- 指定输出信息的格式 
	   --timefmt      --- 指定输出的时间信息格式 
	   -e|--event     --- 指定监控的事件信息
	   
	   创建文件监控信息输出
	   /data/ CREATE user13     --- 一个文件被创建
       /data/ OPEN user13       --- 打开创建的文件
       /data/ ATTRIB user13     --- 修改文件的属性信息
       /data/ CLOSE_WRITE,CLOSE user13  --- 保存关闭一个文件

	   删除文件监控信息输出
	   /data/ DELETE user13
	   
	   修改文件监控信息输出
	   /data/ CREATE user10
       /data/ OPEN user10
       /data/ MODIFY user10
       /data/ CLOSE_WRITE,CLOSE user10
	   
	   sed命令修改文件原理
	   /data/ OPEN user10          --- 打开文件
       /data/ CREATE sedpSAFR7     --- 创建出一个临时文件（内存）
       /data/ OPEN sedpSAFR7       --- 临时文件进行打开
       /data/ ACCESS user10        --- 读取源文件内容
       /data/ MODIFY sedpSAFR7     --- 修改临时文件
       /data/ ATTRIB sedpSAFR7     --- 临时文件属性变化
       /data/ CLOSE_NOWRITE,CLOSE user10   --- 不编辑直接关闭源文件
       /data/ CLOSE_WRITE,CLOSE sedpSAFR7  --- 写入关闭临时文件
       /data/ MOVED_FROM sedpSAFR7 --- 将临时文件移除
       /data/ MOVED_TO user10      --- 移入一个新的user10源文件
	
	   inotify监控命令格式：
	   inotifywait -mrq --timefmt "%F" --format "%T %w %f 事件信息:%e" /data -e CREATE
	   create创建、delete删除、moved_to移入、close_write修改
	   
	   企业应用：防止系统重要文件被破坏
	   需要用到inotify进行实时一直监控 /etc passwd  /var/spool/cron/root
	   
	
    3）部署sersync同步服务
       第一个里程：需要下载，保留上传到linux服务器中
	   https://github.com/wsgzao/sersync
	   上传linux服务器  
	   rz -y  --- 选择需要上传的数据信息
	   PS：软件尽量都统一保存在/server/tools目录中

       第二个里程：解压软件压缩包，将解压的数据进行保存
	   unzip sersync_installdir_64bit.zip
	   [root@nfs01 tools]# tree sersync_installdir_64bit
       sersync_installdir_64bit
       └── sersync
           ├── bin               --- sersync软件命令目录
           │?? └── sersync
           ├── conf              --- sersync软件配置目录
           │?? └── confxml.xml
           └── logs              --- sersync软件日志目录
       [root@nfs01 tools]# mv sersync_installdir_64bit/sersync/  /usr/local/
	   
	   第三个里程：编写配置文件：
	   vim conf/confxml.xml
       6     <filter start="false">
       7         <exclude expression="(.*)\.svn"></exclude>
       8         <exclude expression="(.*)\.gz"></exclude>
       9         <exclude expression="^info/*"></exclude>
      10         <exclude expression="^static/*"></exclude>
      11     </filter>
	  说明：排除指定数据信息不要进行实时传输同步

      12     <inotify>
      13         <delete start="true"/>
      14         <createFolder start="true"/>
      15         <createFile start="false"/>
      16         <closeWrite start="true"/>
      17         <moveFrom start="true"/>
      18         <moveTo start="true"/>
      19         <attrib start="false"/>
      20         <modify start="false"/>
      21     </inotify>
	  说明：定义inotify程序需要监控的事件
	  
	   24         <localpath watch="/opt/tongbu">
       25             <remote ip="127.0.0.1" name="tongbu1"/>
       26             <!--<remote ip="192.168.8.39" name="tongbu"/>-->
       27             <!--<remote ip="192.168.8.40" name="tongbu"/>-->
       28         </localpath>
       29         <rsync>
       30             <commonParams params="-artuz"/>
       31             <auth start="false" users="root" passwordfile="/etc/rsync.pas"/>
       32             <userDefinedPort start="false" port="874"/><!-- port=874 -->
  
	   第四个里程：启动sersync服务程序
       [root@nfs01 bin]# export PATH="$PATH:/usr/local/sersync/bin"
       [root@nfs01 bin]# echo $PATH
       /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/usr/local/sersync/bin
	   
	   参数-d:  启用守护进程模式
	   参数-r:  在监控前，将监控目录与远程主机用rsync命令推送一遍
	            进行同步测试
       参数-o:  指定配置文件，默认使用confxml.xml文件
                -o /usr/local/sersync/conf/confxml.xml
                -o /usr/local/sersync/conf/confxml02.xml

       sersync -dro  /usr/local/sersync/conf/confxml.xml   启动实时同步服务
	   yum install -y psmisc
	   killall sersync                                     停止实时同步服务
	   /etc/rc.local <-- sersync -dro  /usr/local/sersync/conf/confxml.xml   开机自动启动  


05. 实时同步服务概念总结
    1) 实现实时同步的原理
	   监控目录数据变化  --- inotify 
	   将数据进行传输    --- rsync
	   将监控和传输进行整合  --- sersync
	2) 实现实时同步部署方法
	   1. 部署rsync守护进程 
	   2. 部署inotify软件
	   3. 部署sersync软件
	   
作业:
01. 扩展实时同步软件 
    数据库需要实时同步
	windows --- windows
02. 批量管理服务ansible 安装过程  简单配置  应用(模块 剧本)





##############################
#  32-综合架构远程管理服务(SSH)
##############################


00. 课程介绍部分
    1) 远程管理服务器介绍
	2) SSH远程管理服务远程连接的原理
	3) SSH远程连接方式 秘钥连接方法
	4) SSH服务的配置文件 /etc/ssh/sshd_config
	5) SSH远程连接安全防范思路(防止入侵)
	6) 总结SSH服务相关命令 ssh scp
	7) ansible批量管理服务介绍  saltstack 
	8) ansible软件部署
	9) ansible服务简单应用

01. 课程知识回顾
    1) 实时同步服务原理
	   a 部署好rsync守护进程  传输数据
	   b 部署好inotify软件    监控数据变化
	   c 部署安装sersync软件  将rsync+inotify软件结合
    2) 相关软件部署安装
    3) sersync的配置过程
       rsync命令掌握sersync服务配置方法	
    
02. 远程管理服务概念介绍
    SSH     安全的远程连接    数据信息是加密的  22   SSH服务默认可以root用户远程连接         系统远程连接
	TELNET  不安全的远程连接  数据信息是明文的  23   telnet服务默认不可以让root用户远程连接  网络设备远程连接

	补充: 什么是shell
    1. 每连接登录到一个linux系统中,就是一个shell
    2. 可以一个linux系统有多个会话连接,每一个会话都是一个shell
    3. 系统中用户可以实现相互转换,每转换一个用户就是一个shell
    shell特点说明:
	1. 一般命令行临时配置的信息,只会影响当前shell
    2. 命令配置的信息如果想生效,需要切换shell	    eg: 修改主机名称
	
03. SSH服务连接工作原理(数据加密)
    私钥: 钥匙
	公钥: 锁头
	第一个步骤: 客户端  			执行远程连接命令
	第二个步骤: 客户端  服务端    	建立三次握手过程
	第三个步骤: 服务端            	让客户端进行确认是否接收服务端公钥信息
	第四个步骤: 客户端            	进行公钥确认,接收到公钥信息
	第五个步骤: 服务端            	让客户端确认登录用户密码信息
	第六个步骤: 客户端             	进行密码信息确认
	第七个步骤: 客户端  服务端    	远程连接建立成功

	私钥和公钥作用:
	01. 利用私钥和公钥对数据信息进行加密处理
	02. 利用公钥和私钥进行用户身份认证
	
	基于密码的方式进行远程连接: 公钥和私钥只能完成数据加密过程
	基于秘钥的方式进行远程连接: 公钥和私钥可以完成身份认证工作
	
04. SSH远程连接的方式
    a 基于口令的方式进行远程连接  连接比较麻烦		连接不太安全
	b 基于秘钥的方式进行远程连接  连接方便    		连接比较安全

    基于秘钥方式连接过程(原理)
	1. 客户端(管理端)    执行命令创建秘钥对
	2. 客户端(管理端)    建立远程连接(口令),发送公钥信息
	3. 客户端(管理端)    再次建立远程连接
	4. 服务端(被管理端)  发送公钥质询信息(你要是能打开我的锁头吗)
	5. 客户端(管理端)    处理公钥质询信息(钥匙将锁头打开),将质询结果返回给服务端
	6. 服务端(被管理端)  接收到质询结果,建立好远程连接
	
05. SSH实现基于秘钥连接的部署步骤
    准备工作:
	准备好一台管理服务器
	
	第一个历程: 管理端创建秘钥对信息
	[root@m01 ~]# ssh-keygen -t dsa
    Generating public/private dsa key pair.
    Enter file in which to save the key (/root/.ssh/id_dsa): 
    Created directory '/root/.ssh'.
    Enter passphrase (empty for no passphrase): 
    Enter same passphrase again: 
    Your identification has been saved in /root/.ssh/id_dsa.
    Your public key has been saved in /root/.ssh/id_dsa.pub.
	
	第二个历程: 管理端需要将公钥进行分发
	ssh-copy-id -i /root/.ssh/id_dsa.pub root@172.16.1.31
	
	第三个历程: 进行远程连接测试
	ssh 172.16.1.41   --- 不用输入密码信息可以直接连接
	
    问题: 
	01. 如何实现批量管理多台主机
	    如何编写脚本进行批量分发公钥???

    编写脚本最简单方式: 堆命令
	
	#!/bin/bash
	for ip in 31 7 41
    do 
	  ssh-copy-id -i /root/.ssh/id_dsa.pub root@172.16.1.$ip
    done	
	问题: 有交互过程
	01. 需要有确认yes或no
	02. 需要输入密码信息    OK
	03. 服务端端口号变化了,如何分发公钥
	
	如何不用交互输入密码信息,进行远程连接分发公钥:
	第一步骤: 下载安装软件
	yum install -y sshpass
	
	第二步骤: 执行免交互方式分发公钥命令
	sshpass -p123456 ssh-copy-id -i /root/.ssh/id_dsa.pub root@172.16.1.41
	
	如何不要输入连接yes或no的确认信息
	ssh-copy-id -i /root/.ssh/id_dsa.pub root@172.16.1.41 "-o StrictHostKeyChecking=no"
	
	服务端口号发生变化,如何进行批量分发公钥
	sshpass -p123456 ssh-copy-id -i /root/.ssh/id_dsa.pub root@172.16.1.41 -p 52113 "-o StrictHostKeyChecking=no"

    分发公钥脚本:
	[root@m01 scripts]# vim fenfa_pub_key.sh
    #!/bin/bash
    
    for ip in {1..100}
    do
      echo "==================== host 172.16.1.$ip pub-key start fenfa ==================== "
      sshpass -p123456 ssh-copy-id -i /root/.ssh/id_dsa.pub root@172.16.1.$ip "-o StrictHostKeyChecking=no" &>/dev/null
      echo -e "host 172.16.1.$ip fenfa success."
      echo "==================== host 172.16.1.$ip fenfa end ==================== "
      echo ""
    done 

    分发公钥检查脚本(批量管理脚本)  --- 串型批量管理
    [root@m01 scripts]# cat check_pub_key.sh 
    #!/bin/bash
    CMD=$1
    for ip in {7,31,41}
    do
      echo "==================== host 172.16.1.$ip check ==================== "
      ssh 172.16.1.$ip $CMD 
      echo ""
    done 

06. SSH服务配置文件
    /etc/ssh/sshd_config
	Port 22                   --- 修改服务端口信息
	ListenAddress 0.0.0.0     --- 监听地址 指定一块网卡能够接受远程访问请求  *****
	                              PS: 指定监听地址只能是本地网卡上有的地址
	PermitEmptyPasswords no   --- 是否允许远程用户使用空密码登录,默认不允许
	PermitRootLogin yes       --- 是否禁止root用户远程连接主机 建议改为no
	GSSAPIAuthentication no   --- 是否开启GSSAPI认证功能 不用的时候关闭 
	UseDNS no                 --- 是否开启反向DNS解析功能 建议进行关闭
	
							
07. SSH远程服务防范入侵的案例
    1. 用密钥登录，不用密码登陆
	2、牤牛阵法：解决SSH安全问题
	   a.防火墙封闭SSH,指定源IP限制(局域网、信任公网)
       b.开启SSH只监听本地内网IP（ListenAddress 172.16.1.61）。
    3、尽量不给服务器外网IP
    4、最小化（软件安装-授权）
    5、给系统的重要文件或命令做一个指纹
	   /etc/passwd md5sum 11110000aaaabbbb   监控	
	   inotify /bin                          监控
    6、给他锁上 chattr +i

08. SSH相关的命令总结   
    ssh-keygen
	ssh-copy-id
	sshpass 
	ssh 
	scp 
	sftp 172.16.1.41
	ls       查看远程ftp服务器信息
	cd   --- 查看远程ftp服务器信息
	lls      查看本地ftp客户端信息
	lcd  --- 查看本地ftp客户端信息
	get  --- 下载信息
	put  --- 上传信息
	help --- 查看命令帮助
	bye  --- 退出ftp连接
   
作业:
01. 利用脚本实现实时同步
    while循环	 
02. 如何实现xshell也是基于秘钥方式连接主机	
03. 提前安装部署好ansible软件
    在管理端服务器上: yum install -y ansible    
    


##############################
#  33-综合架构批量管理服务
##############################


00. 课程介绍部分
    1. ansible批量管理服务概念
	2. ansible批量管理服务特点 
	3. ansible批量管理服务部署
	4. ansible批量管理服务应用---模块应用
	   ansible模块命令语法
	   ansible常用模块
    
01. 课程知识回顾
    1. 远程管理服务介绍
	   ssh     数据加密  22
	   telnet  数据明文  23
	2. SSH远程管理服务工作原理
	   私钥  公钥  
	   用途1: 对数据进行加密处理
	   用途2: 对用户访问进行认证
	3. SSH远程连接的方式
	   a 基于口令的方式进行连接
	   b 基于秘钥的方式进行连接
	   
	   基于秘钥连接的工作原理
	4. 基于秘钥的连接部署方式
       第一个历程: 创建秘钥对(管理端服务器)	
	   ssh-keygen -t 秘钥的类型(dsa|rsa)
	   第二个历程: 将公钥进行分发(被管理端服务器)
       ssh-copy-id -i /root/.ssh/id_dsa.pub root@172.16.1.31
       如何批量分发公钥:
	   01. 需要输入连接确认信息 yes/no
	   ssh-copy-id -i /root/.ssh/id_dsa.pub root@172.16.1.31 "-o StrictHostKeyChecking=no"
	   02. 需要第一次连接输入密码
	   yum install -y sshpass
	   sshpass -p123456 ssh-copy-id -i /root/.ssh/id_dsa.pub root@172.16.1.31 "-o StrictHostKeyChecking=no"
	   03. 远程服务器SSH服务端口号改动了
	   sshpass -p123456 ssh-copy-id -i /root/.ssh/id_dsa.pub root@172.16.1.31 -p 52113 "-o StrictHostKeyChecking=no"
       
       基于秘钥连接排错思路:
	   01. 利用命令进行连接测试
	   02. 检查公钥在被管理主机上是否存在,并且与管理端公钥信息是否相同
	   03. 利用公钥分发命令重新分发公钥
	   04. 检查脚本的编写
	   05. 调试脚本功能   sh -x 
	   
	5. SSH远程服务防范入侵案例
       
	6. SSH服务的配置文件编写
	   监听地址???
    
	7. SSH服务的相关命令总结
    
02. ansible批量管理服务介绍
    ansible批量管理服务意义
	01. 提高工作的效率
	02. 提高工作准确度
	03. 减少维护的成本
	04. 减少重复性工作
	ansible批量管理服务功能
	01. 可以实现批量系统操作配置
	02. 可以实现批量软件服务部署
	03. 可以实现批量文件数据分发
	04. 可以实现批量系统信息收集

03. ansible批量管理服务部署 
    管理端服务器 
	第一个历程: 安装部署软件
	yum install -y ansible     --- 需要依赖epel的yum源
	/etc/ansible/ansible.cfg   --- ansible服务配置文件
    /etc/ansible/hosts         --- 主机清单文件   定义可以管理的主机信息
    /etc/ansible/roles         --- 角色目录???

	第二个历程: 需要编写主机清单文件
    vim /etc/ansible/hosts 
	
	第三个历程: 测试是否可以管理多个主机
	脚本  hostname
	ansible all -a "hostname"
    [root@m01 scripts]# ansible all -a "hostname"
    172.16.1.41 | CHANGED | rc=0 >>
    backup
    
    172.16.1.7 | CHANGED | rc=0 >>
    web01
    
    172.16.1.31 | CHANGED | rc=0 >>
    nfs01

04. ansible服务架构信息
    1) 主机清单配置 
	2) 软件模块信息         OK  
	3) 基于秘钥连接主机     OK
	4) 主机需要关闭selinux  OK
	5) 软件剧本功能

05. ansible软件模块应用
    ansible官方网站: https://docs.ansible.com/
	模块的应用语法格式:
	ansible 主机名称/主机组名称/主机地址信息/all  -m(指定应用的模块信息)  模块名称  -a(指定动作信息)  "执行什么动作"
	
	命令类型模块:
	掌握第一个模块: command (默认模块)
	command – Executes a command on a remote node
	          在一个远程主机上执行一个命令
	简单用法:
	[root@m01 scripts]# ansible 172.16.1.31 -m command -a "hostname"
    172.16.1.31 | CHANGED | rc=0 >>
    nfs01
  
    扩展应用:
	1) chdir  	Change into this directory before running the command.
	          在执行命令之前对目录进行切换
	   ansible 172.16.1.31 -m command -a "chdir=/tmp touch oldboy.txt"

    2) creates	If it already exists, this step won't be run.
	            如果文件存在了,不执行命令操作
       ansible 172.16.1.31 -m command -a "creates=/tmp/hosts touch oldboy.txt" 
	   
    3) removes	If it already exists, this step will be run.
                如果文件存在了,	这个步骤将执行
	   ansible 172.16.1.31 -m command -a "removes=/tmp/hosts chdir=/tmp touch oldboy.txt"
    4) free_form(required)
       The command module takes a free form command to run. 
	   There is no parameter actually named 'free form'. See the examples!
	   使用command模块的时候,-a参数后面必须写上一个合法linux命令信息
   
    注意事项:
	有些符号信息无法识别:  <", ">", "|", ";" and "&"
	

	掌握第二个模块: shell (万能模块)
	shell   – Execute commands in nodes
	          在节点上执行操作
	简单用法:
	[root@m01 scripts]# ansible 172.16.1.31 -m command -a "hostname"
    172.16.1.31 | CHANGED | rc=0 >>
    nfs01
  
    扩展应用:
	1) chdir  	Change into this directory before running the command.
	          在执行命令之前对目录进行切换
	   ansible 172.16.1.31 -m command -a "chdir=/tmp touch oldboy.txt"

    2) creates	If it already exists, this step won't be run.
	            如果文件存在了,不执行命令操作
       ansible 172.16.1.31 -m command -a "creates=/tmp/hosts touch oldboy.txt" 
	   
    3) removes	If it already exists, this step will be run.
                如果文件存在了,	这个步骤将执行
	   ansible 172.16.1.31 -m command -a "removes=/tmp/hosts chdir=/tmp touch oldboy.txt"
    4) free_form(required)
       The command module takes a free form command to run. 
	   There is no parameter actually named 'free form'. See the examples!
	   使用command模块的时候,-a参数后面必须写上一个合法linux命令信息
	   
	实践应用: 利用shell执行脚本  
    第一个步骤: 编写一个脚本
    第二个步骤: 将脚本发送到远程主机
    第三个步骤: 将脚本权限进行修改(添加执行权限)
	第四个步骤: 运行ansible命令执行脚本
	
    掌握第三个模块: script (万能模块)
	第一个步骤: 编写一个脚本
    第二个步骤: 运行ansible命令执行脚本

    PS: scripts模块参数功能和command模块类似

	文件类型模块:
	copy – Copies files to remote locations
	       将数据信息进行批量分发
	
	基本用法:
	ansible 172.16.1.31 -m copy -a "src=/etc/hosts dest=/etc/"
    172.16.1.31 | CHANGED => {       --- 对哪台主机进行操作
        "changed": true,             --- 是否对主机信息进行改变
        "checksum": "6ed7f68a1d6b4b36c1418338b2001e421eeba270",    --- 生成一个文件校验码==MD5数值
        "dest": "/etc/hosts",        --- 显示目标路径信息  
        "gid": 0,                    --- 显示复制后文件gid信息
        "group": "root",             --- 显示复制后文件属组信息
        "md5sum": "7afd7b74854f0aaab646b3e932f427c0",              --- 生成一个文件校验码==MD5数值
        "mode": "0644",              --- 显示复制后文件权限信息
        "owner": "root",             --- 显示复制后文件属主信息
        "size": 401,                 --- 显示文件的大小信息
        "src": "/root/.ansible/tmp/ansible-tmp-1557804498.23-26487341925325/source", 
        "state": "file",             --- 显示文件的类型信息
        "uid": 0                     --- 显示复制后文件uid信息
    }

    补充说明: ansible软件输出颜色说明:
	01. 绿色信息:  查看主机信息/对主机未做改动
	02. 黄色信息:  对主机数据信息做了修改
	03. 红色信息:  命令执行出错了
	04. 粉色信息:  忠告信息
	05. 蓝色信息:  显示ansible命令执行的过程???
	
	扩展用法:
	01. 在传输文件时修改文件的属主和属组信息
	ansible 172.16.1.31 -m copy -a "src=/etc/ansible/file/rsync/rsync.password dest=/etc/ owner=oldboy group=oldboy"
	02. 在传输文件时修改文件的权限信息
	ansible 172.16.1.31 -m copy -a "src=/etc/ansible/file/rsync/rsync.password dest=/etc/ mode=1777"
	03. 在传输数据文件信息时对远程主机源文件进行备份 
	ansible 172.16.1.31 -m copy -a "src=/etc/ansible/file/rsync/rsync.password dest=/etc/ backup=yes"
    04. 创建一个文件并直接编辑文件的信息
    ansible 172.16.1.31 -m copy -a "content='oldboy123' dest=/etc/rsync.password"

    自行研究: remote_src  directory_mode local_follow
	If no, it will search for src at originating/master machine.
	       src参数指定文件信息,会在本地管理端服务进行查找
    If yes it will go to the remote/target machine for the src. Default is no.
	       src参数指定文件信息,会从远程主机上进行查找

    PS: ansible软件copy模块复制目录信息
	ansible 172.16.1.31 -m copy -a "src=/oldboy dest=/oldboy"  
	src后面目录没有/: 将目录本身以及目录下面的内容都进行远程传输复制
	ansible 172.16.1.31 -m copy -a "src=/oldboy/ dest=/oldboy"  
	src后面目录有/:   只将目录下面的内容都进行远程传输复制	
	
    file – Sets attributes of files
	       设置文件属性信息
	
	基本用法:
    ansible 172.16.1.31 -m file -a "dest=/etc/hosts owner=oldboy group=oldboy mode=666"	
	
	扩展用法:
	1. 可以利用模块创建数据信息 (文件 目录 链接文件)
	state  参数
    =absent    --- 缺席/删除数据信息
    =directory --- 创建一个目录信息
    =file      --- 检查创建的数据信息是否存在 绿色存在 红色不存在
    =hard      --- 创建一个硬链接文件
    =link      --- 创建一个软链接文件
    =touch     --- 创建一个文件信息
	
	创建目录信息:
	ansible 172.16.1.31 -m file -a "dest=/oldboy/ state=directory"
	ansible 172.16.1.31 -m file -a "dest=/oldboy/oldboy01/oldboy02/ state=directory"
    创建文件信息:
	ansible 172.16.1.31 -m file -a "dest=/oldboy/oldboy.txt state=touch"
	创建链接文件信息:
	ansible 172.16.1.31 -m file -a "src=/oldboy/oldboy.txt dest=/oldboy/oldboy_hard.txt state=hard"
	ansible 172.16.1.31 -m file -a "src=/oldboy/oldboy.txt dest=/oldboy/oldboy_link.txt state=link"

	2. 可以利用模块删除数据信息
	ansible 172.16.1.31 -m file -a "dest=/oldboy/oldboy.txt state=absent"
	ansible 172.16.1.31 -m file -a "dest=/oldboy/  state=absent"

	自行研究: recurse	
    
作业:
01. 预习几个新的模块:
    yum service cron mount user group unarchive archive
02. 预习剧本的编写格式




##############################
#  34-综合架构批量管理服务
##############################

00. 课程介绍部分
    1) ansible批量管理服务模块说明
	2) ansible批量管理服务主机清单
	3) ansible批量管理服务剧本编写
	4) ansible批量管理服务实战应用(rsync nfs)

    
01. 课程知识回顾
    1) ansible服务概念介绍
	   a 批量管理多台主机
	   b 提高运维工作效率
	   c 降低运维工作难度
    2) ansible服务特点说明
	   01. 管理端不需要启动服务程序（no server）
       02. 管理端不需要编写配置文件（/etc/ansible/ansible.cfg）
       03. 受控端不需要安装软件程序（libselinux-python）
	       被管理端selinux服务没有关闭 --- 影响ansible软件的管理
		   libselinux-python让selinux开启的状态也可以使用ansible程序
       04. 受控端不需要启动服务程序（no agent）
       05. 服务程序管理操作模块众多（module）
       06. 利用剧本编写来实现自动化（playbook）
    3) ansible服务部署安装
	   a 安装服务软件
	   b 编写主机清单
	   c 进行管理测试
	
	   补充: 远程主机无法管理问题分析
	   1. 管理端没有分发好主机的公钥
	   2. 被管理端远程服务出现问题
	   3. 被管理端进程出现僵死情况
	      /usr/sbin/sshd -D  --- 负责建立远程连接
          sshd: root@pts/0   --- 用于维护远程连接(windows--linux)
          sshd: root@notty   --- 用于维护远程连接(ansible--被管理端)
	
	4) ansible服务模块应用
	   command (默认模块) 
	   shell   (万能模块)
	   script  (脚本模块)
	   copy    (批量分发文件) 管理端 ---> 多个被管理
	   fetch   (批量拉取数据) 管理端 <--- 多个被管理
	           dest
			   src
			   ansible 172.16.1.31 -m fetch -a "src=/tmp/oldboy.txt dest=/tmp"
	   file
	     
	   补充: ansible学习帮助手册如何查看
	   ansible-doc -l         --- 列出模块使用简介
	   ansible-doc -s fetch   --- 指定一个模块详细说明
	   ansible-doc fetch      --- 查询模块在剧本中应用方法

03. ansible模块说明:
    yum模块
	name  --- 指定安装软件名称
	state --- 指定是否安装软件
	          installed   --- 安装软件
			  present
			  latest
			  absent      --- 卸载软件
              removed
    ansible 172.16.1.31 -m yum -a "name=iotop state=installed"	
	
	service模块: 管理服务器的运行状态  停止 开启 重启
	name:   --- 指定管理的服务名称
	state:  --- 指定服务状态
	            started   启动
				restarted 重启
				stopped   停止
	enabled --- 指定服务是否开机自启动
	ansible 172.16.1.31 -m service -a "name=nfs state=started enabled=yes"
	
	cron模块: 批量设置多个主机的定时任务信息
	crontab -e 
	*   *  *  *  *  定时任务动作
	分 时 日 月 周
	
	minute:                # Minute when the job should run ( 0-59, *, */2, etc )
	                       设置分钟信息
	hour:                  # Hour when the job should run ( 0-23, *, */2, etc )
	                       设置小时信息
	day:                   # Day of the month the job should run ( 1-31, *, */2, etc )
                           设置日期信息
    month:                 # Month of the year the job should run ( 1-12, *, */2, etc )
	                       设置月份信息
	weekday:               # Day of the week that the job should run ( 0-6 for Sunday-Saturday, *, etc )
	                       设置周信息
	
	job                    用于定义定时任务需要干的事情
	
	基本用法:
	ansible 172.16.1.31 -m cron -a "minute=0 hour=2 job='/usr/sbin/ntpdate ntp1.aliyun.com >/dev/null 2>&1'" 

	扩展用法:
	01. 给定时任务设置注释信息
	ansible 172.16.1.31 -m cron -a "name='time sync' minute=0 hour=2 job='/usr/sbin/ntpdate ntp1.aliyun.com >/dev/null 2>&1'"
	
    02. 如何删除指定定时任务
	ansible 172.16.1.31 -m cron -a "name='time sync01' state=absent"
	PS: ansible可以删除的定时任务,只能是ansible设置好的定时任务
	
	03. 如何批量注释定时任务
	ansible 172.16.1.31 -m cron -a "name='time sync' job='/usr/sbin/ntpdate ntp1.aliyun.com >/dev/null 2>&1' disabled=yes"
	
	mount: 批量进行挂载操作
	       src:  需要挂载的存储设备或文件信息
	       path: 指定目标挂载点目录
	       fstype: 指定挂载时的文件系统类型
	       state
		   present/mounted     --- 进行挂载
		   present: 不会实现立即挂载,修改fstab文件,实现开机自动挂载
		   mounted: 会实现立即挂载, 并且会修改fstab文件,实现开机自动挂载 *****
		   
		   absent/unmounted    --- 进行卸载
		   absent:     会实现立即卸载, 并且会删除fstab文件信息,禁止开机自动挂载
	       unmounted:  会实现立即卸载, 但是不会会删除fstab文件信息  *****
	
	user模块: 实现批量创建用户
	基本用法:
	ansible 172.16.1.31 -m user -a "name=oldboy01"
	
	扩展用法:
	1) 指定用户uid信息
	ansible 172.16.1.31 -m user -a "name=oldboy02 uid=6666"
	
	2) 指定用户组信息
	ansible 172.16.1.31 -m user -a "name=oldboy03 group=oldboy02"
	ansible 172.16.1.31 -m user -a "name=oldboy04 groups=oldboy02"
	
	3) 批量创建虚拟用户
	ansible 172.16.1.31 -m user -a "name=rsync create_home=no  shell=/sbin/nologin"
	
	4) 给指定用户创建密码
	PS: 利用ansible程序user模块设置用户密码信息,需要将密码明文信息转换为密文信息进行设置
	生成密文密码信息方法:
	方法一:
	ansible all -i localhost, -m debug -a "msg={{ '密码信息123456' | password_hash('sha512', 'oldboy') }}"
	[root@m01 tmp]# ansible all -i localhost, -m debug -a "msg={{ '123456' | password_hash('sha512', 'oldboy') }}"
    localhost | SUCCESS => {
      "msg": "$6$oldboy$MVd3DevkLcimrBLdMICrBY8HF82Wtau5cI8D2w4Zs6P1cCfMTcnnyAmmJc7mQaE9zuHxk8JFTRgYMGv9uKW7j1"
    }
	
	方法二:(忽略)
	mkpasswd --method=sha-512
	
	方法三:
    yum install -y python-pip
    pip install passlib
    python -c "from passlib.hash import sha512_crypt; import getpass; print(sha512_crypt.using(rounds=5000).hash(getpass.getpass()))"
    Password: 
    $6$rJJeiIerQ8p2eR82$uE2701X7vY44voF4j4tIQuUawmTNHEZhs26nKOL0z39LWyvIvZrHPM52Ivu9FgExlTFgz1VTOCSG7KhxJ9Tqk.
	
	ansible 172.16.1.31 -m user -a 'name=oldboy08 password=$6$oldboy$MVd3DevkLcimrBLdMICrBY8HF82Wtau5cI8D2w4Zs6P1cCfMTcnnyAmmJc7mQaE9zuHxk8JFTRgYMGv9uKW7j1'

05. 剧本的编写方法
    剧本的作用: 可以一键化完成多个任务
	自动化部署rsync服务:
	服务端的操作
	第一个历程安装软件:
	ansible 172.16.1.41 -m yum -a "name=rsync state=installed"
	
	第二个历程编写文件:
	ansible 172.16.1.41 -m copy -a "src=/xxx/rsyncd.conf dest=/etc/"
	
	第三个历程创建用户
	ansible 172.16.1.41 -m user -a "name=rsync create_home=no shell=/sbin/nologin"
	
	第四个历程创建目录
	ansible 172.16.1.41 -m file -a "dest=/backup state=directory owner=rsync group=rsync"
	
	第五个历程创建密码文件
	ansible 172.16.1.41 -m copy -a "content='rsync_backup:oldboy123' dest=/etc/rsync.password mode=600"
	
	第六个历程启动服务
	ansible 172.16.1.41 -m service -a "name=rsyncd state=started enabled=yes"
	
	客户端的操作:
	第一个历程: 创建密码文件
	ansible 客户端地址 -m copy -a "content='rsync_backup:oldboy123' dest=/etc/rsync.password mode=600"
	
	剧本的做成部分:
	演员信息: 男一号   hosts
	干的事情: 吻戏     tasks
	
	演员信息: 男二号
	干的事情: 看着
    
    剧本编写规范: pyyaml -- 三点要求
	1. 合理的信息缩进  两个空格表示一个缩进关系
	   标题一
	     标题二
	       标题三
	PS: 在ansible中一定不能用tab进行缩进
 
    2. 冒号的使用方法
	   hosts: 172.16.1.41
	   tasks:
	   yum: name=xx
	PS: 使用冒号时后面要有空格信息
	    以冒号结尾,冒号信息出现在注释说明中,后面不需要加上空格
		
    3. 短横线应用 -(列表功能)
	   - 张三
	     男
	       - 打游戏
		   - 运动
		      
	   - 李四
	     女
	       学习
	          湖南
	   - 王五
	     男
	       运动
	          深圳
	PS: 使用短横线构成列表信息,短横线后面需要有空格  
	   
	开始编写剧本
    mkdir /etc/ansible/ansible-playbook
    vim rsync_server.ymal
    说明: 剧本文件扩展名尽量写为yaml
    1. 方便识别文件是一个剧本文件
    2. 文件编写时会有颜色提示	
- hosts: 172.16.1.41
  tasks:
    yum: name=rsync state=installed
    copy: src=/tmp/rsyncd.conf dest=/etc/
	
	如何执行剧本:
	第一个步骤: 检查剧本的语法格式
	ansible-playbook --syntax-check  rsync_server.yaml
    第二个步骤: 模拟执行剧本
	ansible-playbook -C rsync_server.yaml
	第三个步骤: 直接执行剧本   
	ansible-playbook rsync_server.yaml   
	   
- hosts: 172.16.1.41
  tasks:
    - name: 01-install rsync
      yum: name=rsync state=installed
    - name: 02-push conf file
      copy: src=/tmp/rsyncd.conf dest=/etc/

06. 课程总结
    1) 将常用模块进行了补充说明
	   fetch yum service user mount cron 
	2) 剧本的编写规范
	   a 空格规范
	   b 冒号规范
	   c 短横线规范(列表)
	   剧本的组成
	   - hosts: xxx
	     tasks:
		   - name: xxxx:xxx
             yum: xxx 
           - name
       剧本的执行方式
       a 检查语法
       b 模拟执行
       c 真正执行	   
	   
作业:
01. 如何利用剧本部署rsync服务
02. 如何利用剧本部署nfs服务	   
	



##############################
#  35-综合架构批量管理服务
##############################

00. 课程介绍部分
    1) 利用剧本功能简单完成服务一键化部署
	2) 主机清单配置
	3) 剧本的扩展配置功能
	4) 多个剧本如何进行整合
    5) 剧本的角色目录???
    
01. 课程知识回顾
    1) 将所有模块进行了讲解说明
	   command	模块: 	在远程主机上执行命令操作   默认模块
	   shell	模块:  	在远程主机上执行命令操作   万能模块
	   PS: 有时剧本不能反复执行!!!
	   script	模块: 	批量执行本地脚本
	   copy		模块:	用于批量分发传输数据信息
	   fetch	模块:	用于将远程主机数据进行拉取到本地管理主机
	   file		模块: 	修改数据属性信息/创建数据信息
	   yum		模块:	用于安装和卸载软件包
	   service	模块:	用于管理服务的运行状态 
       user		模块:	用于批量创建用户并设置密码信息
	   mount	模块:	用于批量挂载操作
	   cron		模块: 	批量部署定时任务信息
	   ping		模块:	远程管理测试模块
	   
    2) ansible服务剧本功能
       剧本的组成部分:
       剧本的语法规范:
       1) 空格规范: 实现缩进功能
       2) 冒号规范: 实现键值定义 
       3) 横线规范: 实现列表显示	   
	   
02. 利用剧本完成服务一键化部署:
    rsync	服务部署
	nfs		服务部署
	sersync 服务部署 
	全网备份项目
	
	rsync服务剧本编写:
	准备工作:
	01. 熟悉软件部署流程
	02. 熟悉ansible软件模块使用
	03. 熟悉ansible剧本编写规范
	ansible:
	ad-hoc    临时实现批量管理功能(模块)   --- 命令
	playbook  永久实现批量管理功能(剧本)   --- 脚本	

    剧本编写常见错误:
	01. 剧本语法规范是否符合(空格 冒号 短横线)
	02. 剧本中模块使用是否正确
	03. 剧本中一个name标识下面只能写一个模块任务信息
	04. 剧本中尽量不要大量使用shell模块
	

    [root@m01 ansible-playbook]# cat rsync_server.yaml 
- hosts: rsync_server
  tasks:
    - name: 01-install rsync  
      yum: name=rsync state=installed
    - name: 02-push conf file    
      copy: src=/etc/ansible/server_file/rsync_server/rsyncd.conf dest=/etc/
    - name: 03-create user
      user: name=rsync create_home=no shell=/sbin/nologin
      #shell: useradd rsync -M -s /sbin/nologin 
    - name: 04-create backup dir
      file: path=/backup state=directory owner=rsync group=rsync
    - name: 05-create password file
      copy: content=rsync_backup:oldboy123 dest=/etc/rsync.password mode=600
    - name: 06-start rsync server
      service: name=rsyncd state=started enabled=yes

- hosts: rsync_clients
  tasks:
    - name: 01-install rsync
      yum: name=rsync state=installed
    - name: 02-create password file
      copy: content=oldboy123 dest=/etc/rsync.password mode=600
    - name: 03-create test file
      file: dest=/tmp/test.txt  state=touch
    - name: 04-check test
      shell: rsync -avz /tmp/test.txt rsync_backup@172.16.1.41::backup --password-file=/etc/rsync.password

03. 如何配置主机清单
    第一种方式: 分组配置主机信息
	[web]
    172.16.1.7
    172.16.1.8
    172.16.1.9
    
    [data]
    172.16.1.31
    172.16.1.41
	操作过程
    [root@m01 ansible-playbook]# ansible data -a "hostname"
    172.16.1.31 | CHANGED | rc=0 >>
    nfs01
    
    172.16.1.41 | CHANGED | rc=0 >>
    backup
    
    [root@m01 ansible-playbook]# ansible web -a "hostname"
    172.16.1.7 | CHANGED | rc=0 >>
    web01
	
	第二种方式: 主机名符号匹配配置
	[web]
    172.16.1.[7:9]
	[web]
    web[01:03]
	
	第三种方式: 跟上非标准远程端口
	[web]
    web01:52113
    172.16.1.7:52113
	
	第四种方式: 主机使用特殊的变量
    [web]
    172.16.1.7 ansible_ssh_port=52113 ansible_ssh_user=root ansible_ssh_pass=123456
    [web]
    web01 ansible_ssh_host=172.16.1.7 ansible_ssh_port=52113 ansible_ssh_user=root ansible_ssh_pass=123456

    第五种方式: 主机组名嵌入配置
	[rsync:children]    --- 嵌入子组信息
    rsync_server
    rsync_client
    
    [rsync_server]
    172.16.1.41
    
    [rsync_client]
    172.16.1.31
    172.16.1.7
	
	[web:vars]         --- 嵌入式变量信息
    ansible_ssh_host=172.16.1.7
    ansible_ssh_port=52113
    ansible_ssh_user=root
    ansible_ssh_pass=123456
    [web]
    web01

    主机清单的配置方法:
	https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
	
04. 剧本的扩展功能配置
    参照剧本编写扩展文档说明    
	
05. 课程知识总结
    1) rsync服务一键化部署剧本
	2) 主机清单编写方法
	   5种方式
	3) 剧本的扩展编写方法
	   如何设置变量信息  3种
	   如何设置注册信息  debug
	   如何设置判断信息  setup
    	
	
作业:
01. 一键化部署全网备份项目
02. 一键化部署NFS服务
03. 一键化部署实时同步服务	




##############################
#  35-剧本扩展功能实践
##############################


ansible剧本功能实践介绍
================================================================================================
01. 编写剧本的重要功能介绍
    a 在剧本中设置变量信息  OK
	b 在剧本中设置注册信息  OK 执行剧本时,可以显示输出命令结果信息
	b 在剧本中设置判断信息  OK
	c 在剧本中设置循环信息
	d 在剧本中设置错误忽略
	d 在剧本中设置标签信息
	e 在剧本中设置触发信息
	f 在剧本中进行剧本整合
	
	
02. 在剧本中设置变量信息
    方式一：直接在剧本文件编写  
	vars:
      oldboy01: data01
      oldboy02: data02
 
    方式二：在命令行中进行指定
    ansible-playbook --extra-vars=oldboy01=data01

    方式三：在主机清单文件编写
    [oldboy]
    oldboy01=data01
    oldboy02=data02

    三种变量设置方式都配置了,三种方式的优先级???
	最优先: 命令行变量设置
	次优先: 剧本中变量设置
    最后:   主机清单变量设置

	如何全局设置变量: roles 剧本整合
	
	
03. 在剧本中设置注册信息
    - hosts: oldboy
      tasks:
        - name: check server port
          shell: netstat -lntup  --- 端口信息
          register: get_server_port<--端口信息
    
        - name: display port info
          debug: msg={{ get_server_port.stdout_lines }}
	显示进程信息,表示服务已经正常启动
	PS: 设置变量不能有空格信息
		  
04. 在剧本中设置判断信息
    如何指定判断条件:
	(ansible_hostname == "nfs01")
	(ansible_hostname == "web01")
	setup模块中显示被管理主机系统的详细信息

    - hosts: oldboy
      remote_user: root
      tasks:
        - name: Check File
          file: path=/tmp/this_is_{{ ansible_hostname }}_file state=touch
          when: (ansible_hostname == "nfs") or (ansible_hostname == "backup")	
	
	    - name: install httpd
		  yum: name=httpd state=installed
		  when: (系统情况 == "CentOS")
		  
		- name: install httpd2
          yum: name=httpd2 state=installed
          when: (系统情况 == "ubuntu") 

	获取内置变量方法：
	ansible oldboy -m setup -a "filter=ansible_hostname"
    常见主机信息：
    ansible_all_ipv4_addresses：				仅显示ipv4的信息。
    ansible_devices：							仅显示磁盘设备信息。
    ansible_distribution：						显示是什么系统，例：centos,suse等。
    ansible_distribution_major_version：		显示是系统主版本。
    ansible_distribution_version：				仅显示系统版本。
    ansible_machine：							显示系统类型，例：32位，还是64位。
    ansible_eth0：								仅显示eth0的信息。
    ansible_hostname：							仅显示主机名。
    ansible_kernel：							仅显示内核版本。
    ansible_lvm：								显示lvm相关信息。
    ansible_memtotal_mb：						显示系统总内存。
    ansible_memfree_mb：						显示可用系统内存。
    ansible_memory_mb：							详细显示内存情况。
    ansible_swaptotal_mb：						显示总的swap内存。
    ansible_swapfree_mb：						显示swap内存的可用内存。
    ansible_mounts：							显示系统磁盘挂载情况。
    ansible_processor：							显示cpu个数(具体显示每个cpu的型号)。
    ansible_processor_vcpus：					显示cpu个数(只显示总的个数)。
	
	获取子信息方法:
	ansible_eth0[ipv4]

04. 在剧本中设置循环信息
    vim test04.yml
    - hosts: all
      remote_user: root
      tasks:
        - name: Add Users
          user: name={{ item.name }} groups={{ item.groups }} state=present
          with_items: 
    	    - { name: 'testuser1', groups: 'bin' }
    		- { name: 'testuser2', groups: 'root' }
    
    vim test05.yml
    - hosts: all
      remote_user: root
      tasks:
        - name: Installed Pkg
          yum: name={{ item }}  state=present
          with_items:
    	    - wget
    		- tree
    		- lrzsz	

05. 在剧本中设置忽略错误
    默认playbook会检查命令和模块的返回状态，如遇到错误就中断playbook的执行
    可以加入ignore_errors: yes忽略错误
    vim test06.yml
    - hosts: all
      remote_user: root
      tasks:
        - name: Ignore False
          command: /bin/false
    	  ignore_errors: yes
        - name: touch new file
    	  file: path=/tmp/oldboy_ignore state=touch		

06. 在剧本中设置标签功能
    - hosts: oldboy
      ignore_errors: yes
      remote_user: root
      tasks:
        - name: Check File
          file: path=/tmp/this_is_{{ ansible_hostname }}_file state=touch
          when: (ansible_hostname == "nfs01") or (ansible_hostname == "backup")
		  tags: t1
    
        - name: bad thing
          command: ech 123
          #ignore_errors: yes
		  tags: t2
    
        - name: install httpd
          yum: name=httpd state=installed
          when: (ansible_all_ipv4_addresses == ["172.16.1.7","10.0.0.7"])
		  tags: t3
    
        - name: install httpd2
          yum: name=httpd2 state=installed
          when: (ansible_distribution == "ubuntu")
		  tags: t4
		  
	指定执行哪个标签任务： ansible-playbook --tags=t2 test05.yml 
	跳过指定标签任务：     ansible-playbook --skip-tags=t2 test05.yml 		

07. 在剧本中设置触发功能
    - hosts: backup
      remote_user: root
      tasks:
        - name: 01 Install rsync
          yum: name=rsync state=present
        
        - name: 02 push config file
          copy: src=./file/{{ item.src }} dest=/etc/{{ item.dest }} mode={{ item.mode }} 
          with_items:
            - { src: "rsyncd.conf", dest: "rsyncd.conf", mode: "0644" }
            - { src: "rsync.password", dest: "rsync.password", mode: "0600" }
          notify: restart rsync server

      handlers:
        - name: restart rsync server
          service: name=rsyncd state=restarted   


08. 将多个剧本进行整合
    方式一：include_tasks: f1.yml
    - hosts: all
      remote_user: root
      tasks:
        - include_tasks: f1.yml
        - include_tasks: f2.yml

    方式二：include: f1.yml
    - include：f1.yml	
    - include：f2.yml

	方式三：- import_playbook:
	[root@m01 ansible-playbook]# cat main.yml 
    - import_playbook: base.yml     
    - import_playbook: rsync.yml    
    - import_playbook: nfs.yml      
	- import_playbook: oxxx.yml
    - import_playbook: rsync.yml
    - import_playbook: nfs.yml


##############################
#  36-剧本功能实践
##############################

00. 课程说明:
    1) 剧本扩展功能讲解完毕
	2) nfs服务一键化部署     使用剧本扩展功能
	3) 如何将rsync和nfs两个剧本进行整合
	4) 掌握剧本roles编写方法  标准化完善剧本的过程
	
01. 课程回顾:
    1) ansible程序的主机清单配置
	   五种配置方法:
	   a 分组配置管理主机信息  *****
	   b 支持符号信息进行匹配
	     web01.oldboy.com  --> web[01:02].oldboy.com 
		 web02.oldboy.com 
       c 主机信息加上端口配置
	     172.16.1.31:52113
		 web01:52113
	   d 主机后面添加变量信息
	     172.16.1.31 ansible_ssh_port=52113 ansible_ssh_user=root ansible_ssh_pass=123456
	   e 采用嵌入信息方式配置
	     1) [web01]
		    xxxxx
		    [web02]
			xxxx 
			[web:children]
			web01 
			web02
         2) [web01]
		    172.16.1.7
			[web:vars]
			ansible_ssh_port=52113
            ansible_ssh_user=root
            oldboy=123
    2) 剧本扩展功能 
	   
01. 编写剧本的重要功能介绍
    a 在剧本中设置变量信息  OK 3种方式 常用方式--剧本中设置
	b 在剧本中设置注册信息  OK 执行剧本时,可以显示输出命令结果信息  debug
	b 在剧本中设置判断信息  OK                                       setup
	c 在剧本中设置循环信息  OK
	d 在剧本中设置错误忽略  OK
	d 在剧本中设置标签信息  OK
	e 在剧本中设置触发信息  OK
	详细的剧本扩展:
	https://docs.ansible.com/ansible/latest/user_guide/playbooks.html
	
	
	f 在剧本中进行剧本整合
	
	
02. 在剧本中设置变量信息
    方式一：直接在剧本文件编写  
	vars:
      oldboy01: data01
      oldboy02: data02
 
    方式二：在命令行中进行指定
    ansible-playbook --extra-vars=oldboy01=data01

    方式三：在主机清单文件编写
    [oldboy]
    oldboy01=data01
    oldboy02=data02

    三种变量设置方式都配置了,三种方式的优先级???
	最优先: 命令行变量设置
	次优先: 剧本中变量设置
    最后:   主机清单变量设置

	如何全局设置变量: roles 剧本整合
	
	
03. 在剧本中设置注册信息
    - hosts: oldboy
      tasks:
        - name: check server port
          shell: netstat -lntup  --- 端口信息
          register: get_server_port<--端口信息
    
        - name: display port info
          debug: msg={{ get_server_port.stdout_lines }}
	显示进程信息,表示服务已经正常启动
	PS: 设置变量不能有空格信息
		  
04. 在剧本中设置判断信息
    如何指定判断条件:
	(ansible_hostname == "nfs01")
	(ansible_hostname == "web01")
	setup模块中显示被管理主机系统的详细信息

    - hosts: oldboy
      remote_user: root
      tasks:
        - name: Check File
          file: path=/tmp/this_is_{{ ansible_hostname }}_file state=touch
          when: (ansible_hostname == "nfs") or (ansible_hostname == "backup")	
	
	    - name: install httpd
		  yum: name=httpd state=installed
		  when: (系统情况 == "CentOS")
		  
		- name: install httpd2
          yum: name=httpd2 state=installed
          when: (系统情况 == "ubuntu") 

	获取内置变量方法：
	ansible oldboy -m setup -a "filter=ansible_hostname"
    常见主机信息：
    ansible_all_ipv4_addresses：				仅显示ipv4的信息。
    ansible_devices：							仅显示磁盘设备信息。
    ansible_distribution：						显示是什么系统，例：centos,suse等。
    ansible_distribution_major_version：		显示是系统主版本。
    ansible_distribution_version：				仅显示系统版本。
    ansible_machine：							显示系统类型，例：32位，还是64位。
    ansible_eth0：								仅显示eth0的信息。
    ansible_hostname：							仅显示主机名。
    ansible_kernel：							仅显示内核版本。
    ansible_lvm：								显示lvm相关信息。
    ansible_memtotal_mb：						显示系统总内存。
    ansible_memfree_mb：						显示可用系统内存。
    ansible_memory_mb：							详细显示内存情况。
    ansible_swaptotal_mb：						显示总的swap内存。
    ansible_swapfree_mb：						显示swap内存的可用内存。
    ansible_mounts：							显示系统磁盘挂载情况。
    ansible_processor：							显示cpu个数(具体显示每个cpu的型号)。
    ansible_processor_vcpus：					显示cpu个数(只显示总的个数)。
	
	获取子信息方法:
	ansible_eth0[ipv4]

04. 在剧本中设置循环信息
    vim test04.yml
    - hosts: all
      remote_user: root
      tasks:
        - name: Add Users
          user: name={{ item.name }} groups={{ item.groups }} state=present
          with_items: 
    	    - { name: 'testuser1', groups: 'bin' }
    		- { name: 'testuser2', groups: 'root' }
    
    vim test05.yml
    - hosts: all
      remote_user: root
      tasks:
        - name: Installed Pkg
          yum: name={{ item }}  state=present
          with_items:
    	    - wget
    		- tree
    		- lrzsz	

    剧本执行出现错误排查思路/步骤:
	1) 找到剧本中出现问题关键点
	2) 将剧本中的操作转换成模块进行操作
	3) 将模块的功能操作转换成linux命令
	   本地管理主机上执行命令测试
	   远程被管理主机上执行命令测试
	   
    - name: 01-install rsync
      yum:
        name: ['rsync', 'tree', 'wget']  --- saltstack
        state: installed
    
	- name: xxx 
	  yum: name=xxx state=installed      --- ansible



05. 在剧本中设置忽略错误
    默认playbook会检查命令和模块的返回状态，如遇到错误就中断playbook的执行
    可以加入ignore_errors: yes忽略错误
    vim test06.yml
    - hosts: all
      remote_user: root
      tasks:
        - name: Ignore False
          command: /bin/false
    	  ignore_errors: yes
        - name: touch new file
    	  file: path=/tmp/oldboy_ignore state=touch		

06. 在剧本中设置标签功能
    - hosts: oldboy
      ignore_errors: yes
      remote_user: root
      tasks:
        - name: Check File
          file: path=/tmp/this_is_{{ ansible_hostname }}_file state=touch
          when: (ansible_hostname == "nfs01") or (ansible_hostname == "backup")
		  tags: t1
    
        - name: bad thing
          command: ech 123
          #ignore_errors: yes
		  tags: t2
    
        - name: install httpd
          yum: name=httpd state=installed
          when: (ansible_all_ipv4_addresses == ["172.16.1.7","10.0.0.7"])
		  tags: t3
    
        - name: install httpd2
          yum: name=httpd2 state=installed
          when: (ansible_distribution == "ubuntu")
		  tags: t4
		  
	指定执行哪个标签任务： ansible-playbook --tags=t2 test05.yml 
	跳过指定标签任务：     ansible-playbook --skip-tags=t2 test05.yml 		

07. 在剧本中设置触发功能
    - hosts: backup
      remote_user: root
      tasks:
        - name: 01 Install rsync
          yum: name=rsync state=present
        
        - name: 02 push config file
          copy: src=./file/{{ item.src }} dest=/etc/{{ item.dest }} mode={{ item.mode }} 
          with_items:
            - { src: "rsyncd.conf", dest: "rsyncd.conf", mode: "0644" }
            - { src: "rsync.password", dest: "rsync.password", mode: "0600" }
          notify: restart rsync server

      handlers:
        - name: restart rsync server
          service: name=rsyncd state=restarted   


08. 将多个剧本进行整合
    方式一：include_tasks: f1.yml  
    - hosts: all
      remote_user: root
      tasks:
        - include_tasks: f1.yml
        - include_tasks: f2.yml

    方式二：include: f1.yml
    - include：f1.yml	
    - include：f2.yml

	方式三：- import_playbook:
	[root@m01 ansible-playbook]# cat main.yml 
    - import_playbook: base.yml     
    - import_playbook: rsync.yml    
    - import_playbook: nfs.yml      
	- import_playbook: oxxx.yml
    - import_playbook: rsync.yml
    - import_playbook: nfs.yml
	
09 编写NFS服务剧本
   第一个历程: 创建几个目录
   [root@m01 ansible-playbook]# tree nfs-file/
   nfs-file/
   ├── nfs-client
   └── nfs-server
   
   第二个历程: 编写剧本信息
   主机清单:
   [nfs:children]
   nfs_server
   nfs_client
   [nfs_server]
   172.16.1.31
   [nfs_client]
   172.16.1.7
   #172.16.1.8
   #172.16.1.9

- hosts: nfs
  tasks:
    - name: 01-install nfs software
      yum:
        name: ['nfs-utils','rpcbind']
        state: installed

- hosts: nfs_server
  #vars:
  #  Data_dir: /data
  tasks:
    - name: 01-copy conf file
      copy: src=/etc/ansible/ansible-playbook/nfs-file/nfs-server/exports dest=/etc
      notify: restart nfs server
    - name: 02-create data dir
      file: path={{ Data_dir }} state=directory owner=nfsnobody group=nfsnobody 
       # path: ['data01','data02','data03'] 
       # state: directory 
       # owner: nfsnobody 
       # group: nfsnobody
    - name: 03-boot server
      #service: name=rpcbind state=started enabled=yes
      #service: name=nfs state=started enabled=yes
      service: name={{ item }} state=started enabled=yes
      with_items:
        - rpcbind
        - nfs     
 
  handlers:
    - name: restart nfs server
      service: name=nfs state=restarted
       
- hosts: nfs_client
  #vars:
  #  Data_dir: /data
  tasks:
    - name: 01-mount
      mount: src=172.16.1.31:{{ Data_dir }} path=/mnt fstype=nfs state=mounted
    - name: 02-check mount info
      shell: df -h|grep /data
      register: mount_info
    - name: display mount info
      debug: msg={{ mount_info.stdout_lines }}      
   第三个历程: 进行剧本测试
	
	
10. ansible程序roles --- 规范
    剧本编写完问题:
    1. 目录结构不够规范            OK
    2. 编写好的任务如何重复调用
    3. 服务端配置文件改动,客户端参数信息也自动变化
    4. 汇总剧本中没有显示主机角色信息
    5. 一个剧本内容信息过多,不容易进行阅读,如何进行拆分	 OK
	
	第一个历程: 规范目录结构
	cd /etc/ansible/roles
	mkdir {rsync,nfs}   --- 创建相应角色目录
	mkdir {nfs,rsync}/{vars,tasks,templates,handlers,files}  --- 创建角色目录下面的子目录
	[root@m01 roles]# tree 
    .
    ├── nfs
    │   ├── files       --- 保存需要分发文件目录 
    │   ├── handlers	--- 保存触发器配置文件信息
    │   ├── tasks       --- 保存要执行的动作信息文件   ok
    │   ├── templates   --- 保存需要分发模板文件 模板文件中可以设置变量信息
    │   └── vars        --- 保存变量信息文件
    └── rsync
        ├── files
        ├── handlers
        ├── tasks
        ├── templates
        └── vars
	
    第二个历程: 在roles目录中创建相关文件
	编写文件流程图:
	1) 编写tasks目录中的main.yml文件
	- name: 01-copy conf file
      copy: src=exports dest=/etc
      notify: restart nfs server
    - name: 02-create data dir
      file: path={{ Data_dir }} state=directory owner=nfsnobody group=nfsnobody   
      # path: ['data01','data02','data03']    
      # state: directory    
      # owner: nfsnobody    
      # group: nfsnobody
    - name: 03-boot server
      service: name={{ item }} state=started enabled=yes
      with_items:
        - rpcbind
        - nfs
  	
	vim main.yml
	- include_tasks: copy_info.yml
	- include_tasks: create_dir.yml
	- include_tasks: boot_server.yml
	
    vim copy_info.yml 	
	- name: 01-copy conf file
      copy: src=exports dest=/etc
      notify: restart nfs server

    vim create_dir.yml
    - name: 02-create data dir
      file: path={{ Data_dir }} state=directory owner=nfsnobody group=nfsnobody 

    vim boot_server.yml
    - name: 03-boot server
      service: name={{ item }} state=started enabled=yes
      with_items:
        - rpcbind
        - nfs	

	2) 编写vars目录中的main.yml文件 
	[root@m01 vars]# vim main.yml
    Data_dir: /data
	
	3) 编写files目录中的文件
	[root@m01 files]# ll
    total 4
    -rw-r--r-- 1 root root 29 May 17 15:23 exports
	
	4) 编写handlers目录中的main.yml文件 
	vim main.yml
    - name: restart nfs server
    service: name=nfs state=restarted
	
	目录中文件编写好汇总结构
	[root@m01 nfs]# tree
    .
    ├── files
    │   └── exports
    ├── handlers
    │   └── main.yml
    ├── tasks
    │   └── main.yml
    ├── templates
    └── vars
        └── main.yml
		
    第三个历程: 编写一个主剧本文件
	[root@m01 roles]# cat site.yml 
    - hosts: nfs_server
      roles:
        - nfs-server
    
    - hosts: rsync_server
      roles:
        - rsync

作业:
01. ansible剧本扩展功能进行总结
02. (选做) 总结ansible剧本roles
03. 预习web服务 http协议原理  nginx(安装 配置)


01. 一键化部署全网备份项目
02. 一键化部署实时同步服务




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

