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

# TLS??? ????????? ?????? AMQP 0-9-1 ??? AMQP 1.0 ????????????????????? ??????
firewall-cmd --permanent --zone=public --add-port=5671/tcp    
firewall-cmd --permanent --zone=public --add-port=5672/tcp

# TLS??? ????????? ?????? RabbitMQ Stream ???????????? ??????????????? ?????? ??????
firewall-cmd --permanent --zone=public --add-port=5551/tcp    
firewall-cmd --permanent --zone=public --add-port=5552/tcp

# Erlang ??????(inter-node??? cli ????????? ?????? ?????? (rabbitmqctl))
# ?????? ??? ??? CLI ?????? ??????(Erlang ?????? ?????? ??????)??? ???????????? ?????? ???????????? ??????
firewall-cmd --permanent --zone=public --add-port=25672/tcp

# ?????? ??????????????? ????????????(http api , management UI)(optional)
firewall-cmd --permanent --zone=public --add-port=15672/tcp

# STOMP ??????????????? (optional)
firewall-cmd --permanent --zone=public --add-port=61613/tcp
firewall-cmd --permanent --zone=public --add-port=61614/tcp

# MQTT ??????????????? (optional)
firewall-cmd --permanent --zone=public --add-port=1883/tcp
firewall-cmd --permanent --zone=public --add-port=8883/tcp

# ???
firewall-cmd --permanent --zone=public --add-port=35197/tcp

firewall-cmd --reload && rabbitmqctl list_users && rabbitmqctl add_user wini admin && rabbitmqctl set_user_tags wini administrator

systemctl start rabbitmq-server




