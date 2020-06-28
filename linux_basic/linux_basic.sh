#########################
# Linux 基础知识体系
#########################


####################################
# 01 基础篇
####################################

-- Linux版本
    内核版本格式
        xx.yy.zz
	    xx 主版本
	    yy 次版本
	    zz 末版本
	小于 2.6 版本
	    次版本奇数为开发版
	    次版本偶数为稳定版
	大于 2.6 版本
            logterm 长期支撑版本
	    stable 稳定版本
	    mainline 主线开发版本

    常见发行版本
        Red Hat
	Ubuntu
	CentOS
	Debian
	Fedora

-- 重要概念
    root账号： 对应 windows 系统的管理员账号
    "/" 根目录： 对应 Windows 系统"我的电脑"


####################################
# 02 系统操作篇
####################################

## 帮助命令
-- 使用终端
    命令提示符
        $ 普通用户
	# root用户
    命令和路径补全： tab键
    命令的分类（使用type查看某个命令的所属分类）
        内部命令
	外部命令

-- 帮助命令和用法
    man
        man xxx : 获取 xxx 命令的帮助
	man l man :  查看 man 命令自身的帮助文档
    help
        help xxx : 获取内部命令的帮助
	xxx --help : 获取外部命令的帮助
        
    info
        比 man 更丰富的帮助信息，格式： info xxx

## 文件和目录管理
### 文件与目录查看命令 ls
    -l (小写L) 显示文件的详细信息
    -a 显示隐藏文件
    -r 逆序显示
    -t 按时间排序
    -R 递归显示

### 路径操作（分绝对路径和相对路径）
    cd 进入指定路径
    pwd 显示当前路径

### 建立和删除目录
    mkdir 新建目录
    rmdir 删除空目录

### 通配符
    * 匹配任意字符
    ? 匹配单个字符
    [xyz] 匹配 xyz 任意一个字符
    [a-z] 匹配字符范围
    [!xzy] 或 [^xyz] 匹配不在 xyz 中的任意字符

### 复制文件 cp
    -r 复制目录
    -p 保留用户权限时间
    -a 尽可能保留原始文件的属性，等同于 -dpR

### 删除文件 rm
    -r 递归删除
    -f 不提示

### 移动与重命名 mv
    移动文件 mv file1 dir1/
    重命名文件 mv file1 file2


## 文本查看
-- head 显示文件前 n 行
-- tail 显示结尾 n 行
-- cat
    -f 参数可以显示文件更新信息
    查看文件（文件内容过长时不建议用 cat 直接查看）
-- wc
    统计文件行数


## 打包和压缩
-- tar
    打包命令
    扩展名 .tar
    配合gzip 和 bzip2 可以使用打包和压缩功能
-- gzip
    压缩和解压缩命令
    扩展名 .gz
-- bzip2
    压缩与解压缩命令
    扩展名 .bz2


## Vim文本编辑器
-- 正常模式
    i I o O a A 进入插入模式
        i 在当前光标位置进入插入模式
	I 移动到当前光标所在的行首，进入到插入模式
	a 在当前光标位置之后进入插入模式
	A 移动到当前光标所在行尾，进入到插入模式
	o 在当前光标下一行进入插入模式
	O 在当前光标上一行进入插入模式
    v V ctrl+v 进入可视模式
    : 进入命令模式
    esc 回到正常模式
    h j k l 上下左右
    yy y$ 复制
    dd d$ 剪切
    p 粘贴
    u 撤销命令
    ctrl+r 重做命令
    x 删除单个字符
    r 替换单个字符
    G 定位指定的行
    ^$ 定位到行的开头和结尾

-- 命令模式
    w 写入文件
    w 文件名 另存文件
    q 退出
    q! 不保存退出
    !cmd 执行命令
    / 查找命令
    s/old/new/  替换命令
    set nu 设置命令

-- 插入模式


-- 可视模式
    v 字符可视化模式
    V 行可视化模式
    ctrl+v 块可视化模式



## 用户管理
-- 用户命令
    常用用户命令
        useradd 添加用户
	userdel 删除用户
	passwd 设置用户密码
	usermod 修改用户信息
	groupadd 添加用户组
	groupdel 删除用户组

    用户与用户组的概念
    用户的家目录 /home/用户名
    以管理员身份运行
        su 切换当前用户身份
	sudo 用 root 用户身份执行某条命令
	visudo 修改 sudo 命令的配置文件

-- 用户配置文件
    /etc/passwd 用户信息配置文件
    /etc/shadow 用户密码信息配置文件


## 权限管理
-- 权限的表示方法
    一般权限用三种字符表示
        r 
	w
	x

    文件权限和目录权限相同，但功能不同
        文件权限
	    r
	    w
	    x

	目录权限
	    rx 进入目录读取文件名
	    wx 修改目录内文件名
	    x 进入目录

	特殊权限
	    /etc/passwd 用户信息配置文件
	    t 增加了目录权限为 777 的目录的安全性，确保只有 root 用户和文件属主才可以操作自己的文件或目录


-- 权限相关命令
    chmod 修改权限
    chown 修改属主、属组
    chgrp 可以单独更改属组，不常用



####################################
# 03 系统管理篇
####################################

## 正则表达式
-- 正则表达式是什么
    对字符串操作的一组逻辑公式
    用于对符合规则的字符串进行查找和替换

-- 初识元字符
    ^
    $
    *

-- 扩展元字符

## 文本与文件查找
-- grep
    -l 忽略大小写
    -v 反转
    -a 处理二进制文件
    -R 递归方式

-- find
    -name 按照文件名搜索
    -perm 按照权限搜索
    -user 按照属主搜索
    -type 按照文件类型搜索

## 软件安装与更新
-- rpm 安装
    -i 安装
    -q 查询
    -U 升级
    -e 卸载

-- yum 安装
    安装 yum install xxx (软件名)
    卸载 yum remove xxx
    更新 yum update xxx

-- 源代码编译安装
    ./configure
    make
    make install


## 网络配置
-- 网络配置命令
    ifconfig 查看和配置网络接口
    ip 查看和配置网络接口、路由
    netstat 查看进程监听端口状态
    network 与 NetworkManager 网络管理脚本

-- 配置文件
    ifcfg-eth0 eth0 网卡配置文件
    networking 主机名配置文件
    resolv.conf 域名配置文件

## 防火墙
### SELinux
-- 访问控制方式分类
    DAC 自主访问控制
    MAC 强制访问控制

-- 常用命令
    getenforce 查看 SELinux状态
    setenforce 修改访问状态

-- 配置文件
    /etc/selinux/config
    enforcing 强制控制
    permissive 通知但不强制控制
    disable 禁用访问控制


### iptables
-- 表
    fillter 用于过滤
    nat 用于地址转换

-- 链
    INPUT 进入本主机方向
    OUTPUT 本主机发出方向
    FORWARD 转发方向
    PREROUTING 路由前转换
    POSTROUTING 路由后转换

-- 选项
    -i -o 接口
    -s -d IP 地址 / 子网掩码
    -p tcp/udp 指定协议
        --sport 源端口
	--dport 目的端口
    -j 动作
        ACCEPT 允许次规则匹配的数据包通过
	DROP 丢弃此规则匹配的数据包
	REJECT 拒绝此规则匹配的数据包并返回 rst 包
	SNAT 源地址转换
	DNAT 目的地址转换
	MASQUERADE 动态源地址转换

### tcpdump
-- 保存和读取规则
    -f filename 从文件读取已抓取的数据包
    -w filename 讲抓取的数据包保存至文件

-- 常用选项
    -v 显示详细信息
    -n 不将IP地址解析为主机名
    -i 接口
    host 主机
    port 端口


## 服务与日志
-- 服务状态的查看命令
    service 用法： service 服务名称 start | stop | restart | status 
    systemctl 用法： systemctl start | stop | restart | status 服务名称.service

-- 服务配置文件的编写

-- 常用系统日志
    /var/log 系统日志默认目录
    message 系统日志
    dmesg 内核启动日志
    secure 安全日志

-- 应用程序日志



## 磁盘分区
-- 链接文件
    符号链接
    硬链接

-- mount 挂载命令
    -t 文件系统类型
    -o 挂载选项
        ro 只读挂载
	rw 读写挂载
	remount 重挂载


-- 配置文件 /etc/fstab


## 文件系统
-- 常用命令
    fdisk 分区工具
        -l (小写L) 查看分区信息
	fdisk /dev/sdX 为某一个存储分区
    df 查看分区使用空间大小
    du 查看文件夹使用空间大小
    mkfs 格式化命令
        mkfs.ext4 格式化为 ext4 文件系统
	mkfs.xfs 格式化为 XFS 文件系统

-- ext4


## 逻辑卷与LVM
-- 卷用于分层管理磁盘
-- LVM分为三层
    PV 物理卷
    VG 卷组
    LV 逻辑卷
-- 常用命令
    pvcreate 建立 PV
    pvs 查看 PV
    vgcreate 建立 VG
    vgs 查看 VG
    lvcreate 建立 LV
    lvs 查看 LV
    lvextend 扩展 LV


## 系统启动与故障修复
-- 系统启动过程简述
    BIOS 选择启动设备
    MBR 硬盘可引导扇区
    GRUB Linux 系统可引导工具
    内核
    init 或 systemd
    service 服务 或 systemd 服务
        CentOS 7 以前为 init
	CentOS 7 以前仅有 service 服务
    启动 tty 等待用户登陆

-- 更新内核版本
    RPM方式更新
        安装速度快
        没有更新的版本
    源代码编译方式更新
        可以使用最新的版本
	编译时间较长



####################################
# 04 Shel篇
####################################


####################################
# 05 文本操作篇
####################################

