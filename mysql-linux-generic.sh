#!/bin/bash
#判断所需的环境
yum install -y numactl
#阿里云需要安装
yum install -y libaio
#阿里云CentOS6
type xz >& /dev/null
if [ ! $? -eq 0 ]
then
	echo "安装XZ库"
	yum install -y xz
fi
cd ~
mkdir -p pkgsrc
#wget https://github.com/openssl/openssl/archive/OpenSSL_1_1_1d.tar.gz
#tar -zxvf OpenSSL_1_1_1d.tar.gz
#cd openssl-OpenSSL_1_1_1d
#./config
#make && make install
#cp /usr/local/lib64/libssl.so.1.1 /usr/lib64/libssl.so.1.1
#cp /usr/local/lib64/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1
cd pkgsrc
if [ ! -f "mysql-8.0.18-linux-glibc2.12-x86_64.tar.xz" ]
then
	wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.18-linux-glibc2.12-x86_64.tar.xz
fi
tar -xvf mysql-8.0.18-linux-glibc2.12-x86_64.tar.xz
mkdir -p /env
rm -rf /env/mysql80
mv -f mysql-8.0.18-linux-glibc2.12-x86_64 /env/mysql80
echo "[mysqld]
basedir=/env/mysql80
datadir=/env/mysql-data
socket=/env/mysql80/mysql.sock
symbolic-links=0
log-error=/env/mysql80/mariadb.log
port=3306
user=mysql

[mysql]
socket=/env/mysql80/mysql.sock

[mysql.server]
basedir=/env/mysql80

[mysqld_safe]
log-error=/env/mysql80/mariadb.log
pid-file=/env/mysql80/mariadb.pid" > /etc/my.cnf
grep "^mysql:" /etc/group >& /dev/null
if [ ! $? -eq 0 ]
then
	groupadd mysql
fi
id mysql >& /dev/null
if [ ! $? -eq 0 ]
then
	useradd -r -g mysql -s /bin/false mysql
fi
mkdir -p /env/mysql80/mysql-files
chown -R mysql:mysql /env/mysql80
chmod 750 /env/mysql80/mysql-files
if [ -d "/env/mysql-data" ]
then
	read -n1 -p "检查到已存在mysql-data文件夹，是否移除？(y or n)" STR1
	if [ $STR1 == "y" ]
	then
		rm -rf /env/mysql-data
	else
		echo "退出安装"
		exit 0
	fi
fi
/env/mysql80/bin/mysqld --initialize --user=mysql
/env/mysql80/bin/mysql_ssl_rsa_setup
cp -f /env/mysql80/support-files/mysql.server /etc/init.d/mysql
chmod +x /etc/init.d/mysql
chkconfig --add mysql
#chkconfig --level 345 mysql on