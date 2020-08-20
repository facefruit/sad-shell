#!/bin/bash
grep "^www:" /etc/group >& /dev/null
if [ ! $? -eq 0 ]
then
	groupadd www
fi
id www >& /dev/null
if [ ! $? -eq 0 ]
then
	useradd www -d /www -g www
fi
//进入当前用户目录
cd ~
mkdir -p pkgsrc
cd pkgsrc
yum -y install gcc gcc-c++ openssl openssl-devel libcurl libcurl-devel libjpeg libjpeg-devel pcre pcre-devel libpng libpng-devel freetype freetype-devel gd gd-devel
rpm -e libzip libzip-devel
if [ ! -f "libzip-0.11.2-6.el7.psychotic.x86_64.rpm" ]
then
	wget http://packages.psychotic.ninja/7/plus/x86_64/RPMS/libzip-0.11.2-6.el7.psychotic.x86_64.rpm
fi
if [ ! -f "libzip-devel-0.11.2-6.el7.psychotic.x86_64.rpm" ]
then
	wget http://packages.psychotic.ninja/7/plus/x86_64/RPMS/libzip-devel-0.11.2-6.el7.psychotic.x86_64.rpm
fi
rpm -i libzip-0.11.2-6.el7.psychotic.x86_64.rpm libzip-devel-0.11.2-6.el7.psychotic.x86_64.rpm
#下载nginx源码安装包
if [ ! -f "nginx-1.17.1.tar.gz" ]
then
	wget http://nginx.org/download/nginx-1.17.1.tar.gz
fi
#下载zlib源码安装包
if [ ! -f "zlib-1.2.11.tar.gz" ]
then
	wget http://www.zlib.net/zlib-1.2.11.tar.gz
fi
#下载pcre源码安装包
if [ ! -f "pcre-8.43.tar.gz" ]
then
	wget https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz
fi
#下载openssl源码安装包
if [ ! -f "openssl-1.0.2s.tar.gz" ]
then
	wget https://www.openssl.org/source/openssl-1.0.2s.tar.gz
fi
tar -zxvf nginx-1.17.1.tar.gz
tar -zxvf pcre-8.43.tar.gz
tar -zxvf zlib-1.2.11.tar.gz
tar -zxvf openssl-1.0.2s.tar.gz
cd nginx-1.17.1
./configure --user=www --group=www --prefix=/env/nginx --with-openssl=../openssl-1.0.2s --with-pcre=../pcre-8.43 --with-zlib=../zlib-1.2.11 --with-http_v2_module --with-stream --with-stream_ssl_module --with-http_stub_status_module --with-http_ssl_module --with-http_image_filter_module --with-http_gzip_static_module --with-http_gunzip_module --with-ipv6 --with-http_sub_module --with-http_flv_module --with-http_addition_module --with-http_realip_module --with-http_mp4_module
make && make install
if [ ! -f "/usr/bin/nginx" ]
then
	ln /env/nginx/sbin/nginx /usr/bin
fi
chkconfig --add nginx
ps -C nginx | grep "nginx"
if [ ! $? -eq 0 ]
then
	pkill -f nginx
fi
