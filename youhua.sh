# 检查操作系统
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

#创建启动文件
function creat {

#wget -P /etc/init.d  http://x.x.x.x/vpnserver

cp -a /root/softether/vpnserver  /etc/init.d/
chmod 777 /etc/init.d/vpnserver
}

function doselect {

echo "before we start,you must ADD the bridge between tap_soft and the VirtulHub?"
echo "And you must get your IP address,Contius?"
echo "1. Yes"
echo "2. No"

read num
case "$num" in
[1] ) (setup);;
[2] ) (exit);;

*) echo "OK,Bye!";;
esac
}



#查看配置
printf "
####################################################
#before we start,you must ADD the bridge between tap_soft and the VirtulHub 
# Press Enter to conitue 
####################################################
"

ifconfig tap_soft
#检查操作系统类型
checkos
read num
#创建启动文件
creat
#安装dnsmasq
#Debian7安装
if [ $OS = "debian" ]; then
   apt-get install dnsmasq -y
   #删除root下启动方式
   sed -i '/start/d' /etc/rc.local
   sed -i '/exit/d' /etc/rc.local
   #重启服务
   echo "/etc/init.d/vpnserver restart" >>  /etc/rc.local
   echo "exit 0" >>  /etc/rc.local
   chmod 777 /etc/rc.local
  
   sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
   sysctl --system
   update-rc.d  vpnserver start 2 3 4 5   stop 0 1 6
  cd /etc/rc2.d
  ln -s /etc/init.d/vpnserver S20vpnserver
fi
#Centos6安装
if [ $OS = "centos" ]; then
	yum  install dnsmasq -y
	sed -i '/vpnserver/d' /etc/rc.d/rc.local
	#开启IP4转发
     sed -i 's/ip_forward = 0/ip_forward = 1/g' /etc/sysctl.conf
     sysctl -p
    #设置随系统启动
    chkconfig --levels 235  vpnserver on
    chkconfig --levels 235 dnsmasq on
fi

#修改配置文件,增加内容
echo "interface=tap_soft" >>  /etc/dnsmasq.conf
echo "dhcp-range=tap_soft,192.168.7.50,192.168.7.100,12h" >>  /etc/dnsmasq.conf
echo "dhcp-option=tap_soft,3,192.168.7.1" >>  /etc/dnsmasq.conf


#应用配置

printf "
####################################################
# Here is your IPs !                               #
####################################################
"
#配置转发IP
	if [ "${NETWORKIP}" == "" ];then
		/sbin/ifconfig | grep "inet addr:" | cut -d ":" -f 2 | awk '{print $1}' | grep -v "127.0.0.1"
		read -p "Input your IP for netforward:" NETWORKIP
	fi

iptables -t nat -A POSTROUTING -s 192.168.7.0/24 -j SNAT --to-source ${NETWORKIP}

#Debian7安装
if [ $OS = "debian" ]; then
apt-get install iptables-persistent -y
fi
#Centos6安装
if [ $OS = "centos" ]; then
   /sbin/service iptables save
   chmod 777 /etc/rc.d/init.d/vpnserver
fi

#给予执行权限
chmod 777 /etc/init.d/vpnserver



#重启服务
/etc/init.d/vpnserver restart
/etc/init.d/dnsmasq restart


