###################################################################
# RabbitMq install script
###################################################################
#!/usr/bin/env bash

# user
user="wini"

# Path
top_path="/opt/rabbitmq"
rpm_path="$top_path/rpm"
openssl_path="/usr/local/src"
rabbitmq_path="$top_path/rabbitmq"
erlang_path="$top_path/erlang"




echo "================ openssl version ================"
openssl version

echo "================ openssl ciphers ================"
openssl ciphers -v | awk '{print $2}' | sort | uniq

echo "================ remove openssl ================"
sudo yum remove -y openssl

echo "================ install openssl package ================"
sudo yum install -y gcc gcc-c++ pcre-devel zlib-devel perl wget

echo "================ install openssl ================"
cd $openssl_path

echo "================ tar down ================"
wget https://www.openssl.org/source/openssl-1.1.1m.tar.gz -P $openssl_path

tar -xvf openssl-1.1.1m.tar.gz && cd $openssl_path/openssl-1.1.1m && ./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib; make & make install

echo "" >> /etc/profile
echo "/usr/local/ssl/lib" >> /etc/ld.so.conf.d/openssl-1.1.1k.conf

echo "================ create symbol link ================"
ln -s /usr/local/ssl/lib/libssl.so.1.1 /usr/lib64/libssl.so.1.1
ln -s /usr/local/ssl/lib/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1
ln -s /usr/local/ssl/bin/openssl /bin/openssl

echo "================ check openssl version ================"
openssl version

echo "================ check openssl ciphers ================"
openssl ciphers -v | awk '{print $2}' | sort | uniq


echo ""
echo ""
echo ""
echo "================ Install Erlang ================"
yum install -y epel-release && wget http://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm -P $erlang_path && cd $erlang_path && rpm -Uvh erlang-solutions-1.0-1.noarch.rpm && yum install -y erlang &&

cat /usr/lib64/erlang/releases/RELEASES

echo ""
echo ""
echo ""
echo "================ Install RabbitMq ================"

cd $rabbitmq_path

sudo yum install socat && wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.28/rabbitmq-server-3.8.28-1.el8.noarch.rpm && rpm --import https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc && rpm -Uvh https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.28/rabbitmq-server-3.8.28-1.el8.noarch.rpm && rabbitmq-plugins enable rabbitmq_management && rabbitmq-plugins enable rabbitmq_management_agent && rabbitmq-plugins enable rabbitmq_mqtt

# empd
firewall-cmd --permanent --zone=public --add-port=4369/tcp

# TLS가 있거나 없는 AMQP 0-9-1 및 AMQP 1.0 클라이언트에서 사용
firewall-cmd --permanent --zone=public --add-port=5671/tcp    
firewall-cmd --permanent --zone=public --add-port=5672/tcp

# TLS가 있거나 없는 RabbitMQ Stream 프로토콜 클라이언트 에서 사용
firewall-cmd --permanent --zone=public --add-port=5551/tcp    
firewall-cmd --permanent --zone=public --add-port=5552/tcp

# Erlang 분산(inter-node와 cli 통신을 위한 사용 (rabbitmqctl))
# 노드 간 및 CLI 도구 통신(Erlang 배포 서버 포트)에 사용되며 동적 범위에서 할당
firewall-cmd --permanent --zone=public --add-port=25672/tcp

# 관리 플러그인을 사용할때(http api , management UI)(optional)
firewall-cmd --permanent --zone=public --add-port=15672/tcp

# STOMP 클라이언트 (optional)
firewall-cmd --permanent --zone=public --add-port=61613/tcp
firewall-cmd --permanent --zone=public --add-port=61614/tcp

# MQTT 클라이언트 (optional)
firewall-cmd --permanent --zone=public --add-port=1883/tcp
firewall-cmd --permanent --zone=public --add-port=8883/tcp

# ???
firewall-cmd --permanent --zone=public --add-port=35197/tcp

firewall-cmd --reload && rabbitmqctl list_users && rabbitmqctl add_user wini admin && rabbitmqctl set_user_tags wini administrator

systemctl start rabbitmq-server




