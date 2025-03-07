#!/bin/bash
# By Dimokus (https://t.me/Dimokus)
source $HOME/.bashrc



echo "#### SETTING UP SSH ######"
echo $SSH_PUBKEY >> ~/.ssh/authorized_keys
service ssh start
service ssh status

TZ=Europe/Uk
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
apt-get update
apt-get upgrade -y
apt-get install -y wget tar nginx unzip xz-utils make gcc goxkcdpwgen
sleep 5
source $HOME/.bashrc
wget https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.39-9772-beta/softether-vpnserver-v4.39-9772-beta-2022.04.26-linux-x64-64bit.tar.gz
tar xvzf softether-vpnserver-v4.39-9772-beta-2022.04.26-linux-x64-64bit.tar.gz
rm softether-vpnserver-v4.39-9772-beta-2022.04.26-linux-x64-64bit.tar.gz
cd vpnserver
make
sleep 10
./vpnserver start
sleep 10
./vpnserver stop
sleep 20
ls
sleep 10
CONFIG=/vpnserver/vpn_server.config
line=$(grep -A 19 -n DDnsClient $CONFIG | grep -m1 -B19 "}" | grep "bool Disabled" | awk -F "-" '{print $1}')
sed -i $line's/false/true/' $CONFIG
line=$(grep -n DisableJsonRpcWebApi $CONFIG |awk -F ":" '{print $1}')
sed -i $line's/false/true/' $CONFIG

# Add new listener for port 80
sed -i '/declare ListenerList/,/}/{/}/{i\                declare Listener4\n                {\n                        bool DisableDos false\n                        bool Enabled true\n                        uint Port 80\n                }' $CONFIG

ADMINPASS=adminakash
HUBPASS=hubakash
PSKPASS=akashvpn
sleep 10
./vpnserver start
sleep 10
  ./vpncmd /SERVER 127.0.0.1 /CMD SstpEnable no
  ./vpncmd /SERVER 127.0.0.1 /CMD SyslogDisable
  ./vpncmd /SERVER 127.0.0.1 /CMD ServerCipherSet ECDHE-RSA-AES128-GCM-SHA256
  
  ./vpncmd /SERVER 127.0.0.1 /HUB:DEFAULT /CMD SecureNatEnable
  ./vpncmd /SERVER 127.0.0.1 /HUB:DEFAULT /CMD LogDisable packet
  
  ./vpncmd /SERVER 127.0.0.1 /HUB:DEFAULT /CMD UserCreate $USER /GROUP:none /REALNAME:$USER /NOTE:none
  { echo $USERPASS; echo $USERPASS; } | ./vpncmd /SERVER 127.0.0.1 /HUB:DEFAULT /CMD UserPasswordSet $USER
  
  # To enable Anonymous mode (any user password will work):
  #./vpncmd /SERVER 127.0.0.1 /HUB:DEFAULT /CMD UserAnonymousSet $USER
  
  # specify the default hub so you don't need to specify "user@<hub name>"
  ./vpncmd /SERVER 127.0.0.1 /CMD IPsecEnable /L2TP:yes /L2TPRAW:no /ETHERIP:no /PSK:$PSKPASS /DEFAULTHUB:DEFAULT

  { echo $ADMINPASS; echo $ADMINPASS; } | ./vpncmd /SERVER 127.0.0.1 /ADMINHUB:DEFAULT /CMD ServerPasswordSet
  { echo $HUBPASS; echo $HUBPASS; } | ./vpncmd /SERVER 127.0.0.1 /HUB:DEFAULT /CMD SetHubPassword

  # OpenVPN config
  ./vpncmd /SERVER /PASSWORD:$ADMINPASS localhost /CMD OpenVpnMakeConfig openvpn

 unzip openvpn.zip '*_openvpn_remote_access_l3.ovpn'
 
cat *_openvpn_remote_access_l3.ovpn | grep -Ev '^\#|^;' | strings | sed 's/^remote .*/remote <SET YOUR AKASH INGRESS URI HERE> <SET YOUR AKASH PORT MAPPED TO 443>/g' | sed 's/^proto udp/proto tcp/g' | sed 's/^cipher .*/cipher AES-256-CBC/g' > /var/www/html/VPN_on_Akash_Network.ovpn

 rm /var/www/html/index.nginx-debian.html
 cat > /var/www/html/index.html <<EOF 
 <!DOCTYPE html>
 <meta charset="utf-8">
<html>
<head>
<title>Welcome to VPN on Akash!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to VPN on Akash!</h1>
<p>VPN server successfully installed!</p>

<p>Download the OpenVPN connection
<a href="VPN_on_Akash_Network.ovpn">certificate</a>.<br/>
<p><em>Thank you for using Akash Network!</em></p>
<br/>
<br/>

<h1>Добро пожаловать в VPN на Akash!</h1>
<p>VPN сервер успешно установлен!</p>

<p>Скачайте
<a href="VPN_on_Akash_Network.ovpn">сертификат</a> подключения по OpenVPN.<br/>
<p><em>Спасибо что выбрали Akash Network!</em></p>

</body>
</html>
EOF
service nginx start
echo ===========================================
echo === Развертывание сервера VPN завершено ===
echo ===== VPN Server Deployment Completed =====
echo ===========================================
echo ============= USER VPN: $USER =============
echo ========= PASSWORD USER VPN: $USERPASS ========
echo ==== Admin server password: $ADMINPASS ====
echo ========= Hub password: $HUBPASS ==========
echo ===========================================

 echo ""
  echo "================================================================"
  echo "Save the following data somewhere safe."
  echo "================================================================"
  echo ""
  echo "===================== OpenVPN VPN =============================="
  echo "Your OpenVPN config (save it as vpn.ovpn file):"
  echo "# --------------------- CUT HERE -------------------------------"
  cat *_openvpn_remote_access_l3.ovpn | \
    grep -Ev '^\#|^;' | strings | \
    sed 's/^remote .*/remote <SET YOUR AKASH INGRESS URI HERE> <SET YOUR AKASH PORT MAPPED TO 443>/g' | \
    sed 's/^proto udp/proto tcp/g' | \
    sed 's/^cipher .*/cipher AES-256-CBC/g'
  echo "# --------------------- CUT HERE -------------------------------"
  rm -vf -- openvpn.zip *_openvpn_remote_access_l3.ovpn >/dev/null
  echo ""
  echo "=================== SoftEther VPN =============================="
  echo "SoftEther VPN Server Administrator Password: $ADMINPASS"
  echo "SoftEther VPN DEFAULT Hub Password: $HUBPASS"
  echo ""
  echo "=================== L2TP/IPSec VPN ============================="
  echo "L2TP PSK (Pre-shared key) is: $PSKPASS"
  echo "L2TP IPSec Options"
  echo "Phase 1 Algorithms: aes128-sha1-modp2048"
  echo "Phase 2 Algorithms: aes128-sha1"
  echo ""
  echo "============ Username & Password for VPN authentication ========"
  echo "Username: $USER"
  echo "Password: $USERPASS"
  echo ""
