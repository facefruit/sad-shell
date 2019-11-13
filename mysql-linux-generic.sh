#!/bin/bash
cd ~
mkdir pkgsrc
cd ~/pkgsrc
#wget https://github.com/openssl/openssl/archive/OpenSSL_1_1_1d.tar.gz
#tar -zxvf OpenSSL_1_1_1d.tar.gz
#cd openssl-OpenSSL_1_1_1d
#./config
#make && make install
#cp /usr/local/lib64/libssl.so.1.1 /usr/lib64/libssl.so.1.1
#cp /usr/local/lib64/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1
#cd ~/pkgsrc
wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.18-linux-glibc2.12-x86_64.tar.xz
tar -xvf mysql-8.0.18-linux-glibc2.12-x86_64.tar.xz
mkdir /env
mv mysql-8.0.18-linux-glibc2.12-x86_64 /env/mysql80
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
cd /env/mysql80
groupadd mysql
useradd -r -g mysql -s /bin/false mysql
mkdir mysql-files
chown mysql:mysql mysql-files
chmod 750 mysql-files
yum install -y numactl
chown -R mysql:mysql /env/mysql80
/env/mysql80/bin/mysqld --initialize --user=mysql
/env/mysql80/bin/mysql_ssl_rsa_setup
cp support-files/mysql.server /etc/init.d/mysql
chmod +x /etc/init.d/mysql
chkconfig --add mysql
#chkconfig --level 345 mysql on