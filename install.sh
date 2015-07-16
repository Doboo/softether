#!/bin/bash

####################################################
function checkos(){
    if [ -f /etc/redhat-release ];then
        OS=centos
    elif [ ! -z "`cat /etc/issue | grep bian`" ];then
        OS=debian
    elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ];then
        OS=ubuntu
    else
        echo "Unsupported operating systems!"
        exit 1
    fi
	echo $OS
}

function set32 {
wget http://www.softether-download.com/files/softether/v4.17-9562-beta-2015.05.30-tree/Linux/SoftEther_VPN_Server/32bit_-_Intel_x86/softether-vpnserver-v4.17-9562-beta-2015.05.30-linux-x86-32bit.tar.gz
tar -zxvf softether-vpnserver-v4.17-9562-beta-2015.05.30-linux-x86-32bit.tar.gz

}
function set64 {
wget http://www.softether-download.com/files/softether/v4.17-9562-beta-2015.05.30-tree/Linux/SoftEther_VPN_Server/64bit_-_Intel_x64_or_AMD64/softether-vpnserver-v4.17-9562-beta-2015.05.30-linux-x64-64bit.tar.gz
tar -zxvf softether-vpnserver-v4.17-9562-beta-2015.05.30-linux-x64-64bit.tar.gz
}

# function doselect {
# echo "Please select your system "
# echo "1. 32bit"
# echo "2. 64bit"

# read num
# case "$num" in
# [1] ) (set32);;
# [2] ) (set64);;
# *) echo "OK,Bye!";;
# esac
# }

 
#安装编译环境

printf "
####################################################
#                                                  #
# softether vpn server install script for centos6  #
# Version: 1.1.0                                   #
# Author: guoke QQ:38196962                        #
#                                                  #
####################################################
" 
checkos


if [ $OS = "ubuntu" ]; then
			echo " Install  ubuntu wget ..."
			apt-get -y install wget
fi
if [ $OS = "debian" ]; then
apt-get update -y
#apt-get   -y install wget  build-essential gcc gcc-c++  automake autoconf libtool make
apt-get   -y install wget  build-essential 
	#删除exit 0
   sed -i '/exit/d' /etc/rc.local
   #增加启动项
   echo "/root/vpnserver/vpnserver start" >>  /etc/rc.local
   #echo "exit 0" >>  /etc/rc.local
fi
if [ $OS = "centos" ]; then
yum update -y
yum install wget gcc gcc-c++  automake autoconf libtool make -y
#设置开机启动
echo "/root/vpnserver/vpnserver start" >> /etc/rc.d/rc.local
fi


#doselect
ldconfig
#判断系统是32位还是64位
if [ $(getconf WORD_BIT) = '32' ] && [ $(getconf LONG_BIT) = '64' ] ; then

    set64

else

    set32

fi
cd vpnserver
 #开始安装
./.install.sh

 #启动
/root/vpnserver/vpnserver start
