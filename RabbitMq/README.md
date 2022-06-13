
# RabbitMq

| 수정일 | 수정 내용 | 수정자 |
| --- | --- | --- |
| 2022. 04. 13 | 최초 작성 | cs 박영희 |
| 2022. 04. 15 | 설치 가이드 추가 | cs 김태현 |
-----------------------
</br>

## 설치 가이드
| 환경 | 설치 버전 |
| --- | --- |
| OS | CentOS Linux release 7.9.2009 (Core) |
| RabbitMq | 3.8.28 |
| Erlang | 24.2.1 |
| Others | OpenSSL 1.1 |

> **RabbitMq는 Erlang과 호환성이 중요**
>
> 호환성 확인 : <https://www.rabbitmq.com/which-erlang.html>

> Erlang 24를 CentOS7에서 사용하기 위해선 OpenSSL1.1로 upgrade 필요
> 
> 공식 문서:
> Older distributions can also lack a recent enough version of OpenSSL. **Erlang 24 cannot be used on distributions that do not provide OpenSSL 1.1 as a system library. CentOS 7 and Fedora releases older than 26 are examples of such distributions.**
>
> 이전 배포판에는 충분히 최신 버전의 OpenSSL이 없을 수도 있습니다. **시스템 라이브러리로 OpenSSL 1.1을 제공하지 않는 배포판에서는 Erlang 24를 사용할 수 없습니다. CentOS 7과 26보다 오래된 Fedora 릴리스가 그러한 배포판의 예입니다.**

- 설치 링크

    Erlang : <https://www.erlang.org/patches/otp-23.3.4.13>

    RabbitMq : <https://packagecloud.io/rabbitmq/rabbitmq-server/>

- 설치
    - OpenSSL 1.1 설치
        ```bash
        # OpenSSL 버전 확인 
        # centos7 에선 OpenSSL 1.0.2k-fips  26 Jan 2017 표출
        $ openssl version

        # TLS 지원 버전 확인
        # centos7 에선 SSLv3, TLSv1.2 2개만 표출
        $ openssl ciphers -v | awk '{print $2}' | sort | uniq

        # 기존 openssl 삭제
        $ yum remove openssl

        # 패키지 설치
        $ yum install -y gcc gcc-c++ pcre-devel zlib-devel perl wget

        # tar 다운
        $ wget https://www.openssl.org/source/openssl-1.1.1m.tar.gz

        # tar 압축 해제
        $ tar -xvf openssl-1.1.1m.tar.gz

        # 이동
        $ cd openssl-1.1.1m

        # make를 하기 위해 config 실행
        $ ./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib

        # make
        $ make & make install

        # 해당 파일에 openssl 경로 입력
        $ vi /etc/ld.so.conf.d/openssl-1.1.1k.conf
        
        # 파일안에 ssl 컴파일 경로 기재
        /usr/local/ssl/lib

        # lib64에 심볼 링크 생성
        $ ln -s /usr/local/ssl/lib/libssl.so.1.1 /usr/lib64/libssl.so.1.1
        $ ln -s /usr/local/ssl/lib/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1
        $ ln -s /usr/local/ssl/bin/openssl /bin/openssl

        # 설치 이후 버전 및 TLS 지원 확인        
        $ openssl version
        #OpenSSL 1.1.1m  14 Dec 2021
        
        $ openssl ciphers -v | awk '{print $2}' | sort | uniq
        #SSLv3
        #TLSv1
        #TLSv1.2
        #TLSv1.3        
        ```
    - Erlang 설치
        ```bash
        # EPEL 저장소 추가
        $ yum install epel-release

        # erlang 설치를 위한 npm 다운
        $ wget http://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm

        # rpm 실행(repo 추가)
        $ rpm -Uvh erlang-solutions-1.0-1.noarch.rpm

        # erlang 설치
        $ yum install erlang

        # erlang 버전 확인
        $ cat /usr/lib64/erlang/releases/RELEASES
        ```
    - RabbitMq 설치              
        ```bash       
        # socat 설치
        sudo yum install socat

        # npm 다운
        $ wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.28/rabbitmq-server-3.8.28-1.el8.noarch.rpm

        #Signing Keys 추가
        $ rpm --import https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc
        
        # 설치            
        rpm -Uvh https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.28/rabbitmq-server-3.8.28-1.el8.noarch.rpm
        ```  

----------------------------------
<br>

## 플러그인 활성화

```bash
#관리자페이지 
$ rabbitmq-plugins enable rabbitmq_management

# 관리자에이전트 
$ rabbitmq-plugins enable rabbitmq_management_agent

# MQTT 
$ rabbitmq-plugins enable rabbitmq_mqtt
```

----------------------------------
<br>

## 포트오픈
> 참고 : <https://docs.vmware.com/en/VMware-Tanzu-RabbitMQ-for-Kubernetes/1.2/tanzu-rmq/GUID-networking.html#ports>

- 설정(firewall-cmd)
    ```bash
    # empd
    $ firewall-cmd --permanent --zone=public --add-port=4369/tcp

    # TLS가 있거나 없는 AMQP 0-9-1 및 AMQP 1.0 클라이언트에서 사용
    $ firewall-cmd --permanent --zone=public --add-port=5671/tcp    
    $ firewall-cmd --permanent --zone=public --add-port=5672/tcp

    # TLS가 있거나 없는 RabbitMQ Stream 프로토콜 클라이언트 에서 사용
    $ firewall-cmd --permanent --zone=public --add-port=5551/tcp    
    $ firewall-cmd --permanent --zone=public --add-port=5552/tcp

    # Erlang 분산(inter-node와 cli 통신을 위한 사용 (rabbitmqctl))
    # 노드 간 및 CLI 도구 통신(Erlang 배포 서버 포트)에 사용되며 동적 범위에서 할당
    $ firewall-cmd --permanent --zone=public --add-port=25672/tcp

    # 관리 플러그인을 사용할때(http api , management UI)(optional)
    $ firewall-cmd --permanent --zone=public --add-port=15672/tcp

    # STOMP 클라이언트 (optional)
    $ firewall-cmd --permanent --zone=public --add-port=61613/tcp
    $ firewall-cmd --permanent --zone=public --add-port=61614/tcp

    # MQTT 클라이언트 (optional)
    $ firewall-cmd --permanent --zone=public --add-port=1883/tcp
    $ firewall-cmd --permanent --zone=public --add-port=8883/tcp

    # ???
    $ firewall-cmd --permanent --zone=public --add-port=35197/tcp
    ```
- 설정(iptables)
    ```bash
    $ iptables -I INPUT -m tcp -p tcp --dport 35197 -j ACCEPT
    # 등등등....
    ```

- 적용
    ```bash    
    $ firewall-cmd --reload
    ```

- 확인
    ```bash
    $ firewall-cmd –-list-all
    ```

----------------------------------
<br>

## 기본설정
- rabbitmq-server 실행 
    ```bash
    $ systemctl start rabbitmq-server
    ```

- ravvitmq-server 상태
    ```bash
    $ systemctl status rabbitmq-server
    ```

- rabbitmq 상태 확인
    ```bash
    $ rabbitmq-diagnostics status
    ```

- rabbitmq 로그 확인
    ```bash
    $ cat /var/log/rabbitmq/~~~.log
    ```
----------------------------------
<br>

## 노드명 변경
> 노드명은 시스템 user, host 명과 중복이 되지 않게 설정 할 것!!!
> 클러스터링 묶을때 slave mq가 연결할 때 혼동이 생겨 연결이 안됨.
>
> 참고 : <https://sleeplessbeastie.eu/2020/02/03/how-to-specify-rabbitmq-node-name/>

- 기존 파일 삭제(**Optional**)
    ```bash
    $ rm -rf /var/lib/rabbitmq/mnesia/*
    ``` 
- 환경 변수 파일 생성
    > **파일명 조심할것!! ==> .config, .conf**
    - rabbitmq.config    
        ```bash
        # vi /etc/rabbitmq/rabbitmq.config
        # 뒤에 마침표(.) 필히 찍어 줄것
        [
            {mnesia,
                [
                {dump_log_write_threshold, 1000},
                {dc_dump_limit, 40}
                ]
            },
            {rabbit,
                [
                {tcp_listeners, [5672]},
                {vm_memory_high_watermark, 0.4}
                ]
            },
            {rabbitmq_tracing,
                [
                {username, "wini"}
                ]
            }
        ].
        ```

    - rabbitmq-env.config
        > **꼭!!!! nodename에 node이름@호스트명 을 필기 작성해줄 것**
        ```bash
        # vi /etc/rabbitmq/rabbitmq-env.config    
        # Defaults to rabbit. This can be useful if you want to run more than one node
        # per machine - RABBITMQ_NODENAME should be unique per erlang-node-and-machine
        # combination. See the clustering on a single machine guide for details:
        # http://www.rabbitmq.com/clustering.html#single-machine
        NODENAME=wini1@rabbit1
        # By default RabbitMQ will bind to all interfaces, on IPv4 and IPv6 if
        # available. Set this if you only want to bind to one network interface or#
        # address family.
        #NODE_IP_ADDRESS=127.0.0.1
        # Defaults to 5672.
        #NODE_PORT=5672
        #USE_LONGNAME=true
        ```
- node 표현 확인
    ```bash
    $ rabbitmqctl eval "node()."

    #[root@localhost rabbitmq]# rabbitmqctl eval "node()."
    #wini2@rabbit2
    ```
----------------------------------
<br>

## 계정
- 계정조회 : rabbitmqctl list_users
- 계정등록 : rabbitmqctl add_user 계정명 비밀번호
- 권한부여 : rabbitmqctl set_user_tags 계정명 administrator
- 계정 할당 권한 부여 : rabbitmqctl set_permissions -p / wini ".*" ".*" ".*"

----------------------------------
<br>

## 도메인적용
1) vi /etc/hosts 추가
2) hostnamectl set-hostname myhost

----------------------------------
<br>

## 클러스터링
> 공식 : <https://www.rabbitmq.com/clustering.html>
>
> 참고 : <https://intrepidgeeks.com/tutorial/rabbitmq-cluster-and-load-balancing-construction>
>
> **rabbitmqctl reset 하면 userlist가 초기화 되니 재설정 해줄것**

- 클러스터 구성할 서버들 host 설정
    ```bash
    # vi /etc/hosts

    172.18.220.160 rabbit1
    172.18.222.136 rabbit2
    ```

- 클러스터 구성 포트 허용 확인
    ```bash
    # 클러스터 노드 찾는 port
    $ firewall-cmd --permanent --zone=public --add-port=4369/tcp    

    # TLS가 있거나 없는 AMQP 0-9-1 및 AMQP 1.0 클라이언트에서 사용
    $ firewall-cmd --permanent --zone=public --add-port=5671/tcp    
    $ firewall-cmd --permanent --zone=public --add-port=5672/tcp
    
    # inter-node 와 cli 통신을 위한 사용 (rabbitmqctl)
    $ firewall-cmd --permanent --zone=public --add-port=25672/tcp

    # http api, management UI
    $ firewall-cmd --permanent --zone=public --add-port=15672/tcp    

    # 적용    
    $ firewall-cmd --reload
    
    # 확인    
    $ firewall-cmd –-list-all
    ```

- Erlang 쿠키 맞추기
    - master 에 있는 /var/lib/rabbitmq/.erlang.cookie 를 slave로 옮겨줌
        > 기존 파일 권한을 777로 준 다음 다시 400으로 세팅할 것
        ```bash
            $ scp /var/lib/rabbitmq/.erlang.cookie wini@rabbit2:/var/lib/rabbitmq/
        ```

-  rabbitmq 클러스터 설정
    > 설정은 slave -> master 로만 설정

    ```bash    
    # 노드 중지
    $ rabbitmqctl stop_app --

    # 노드 다시 세팅
    $ rabbitmqctl reset

    # 클러스터 조인
    # slave->master
    $ rabbitmqctl join_cluster wini1@rabbit1

    # 각 rabbitmq 시작
    $ rabbitmqctl start_app

    # 각 rabbitmq 상태 확인
    $ rabbitmqctl cluster_status
    ```

- rabbitmq 클러스터 성공 결과
    ```bash
    # rabbitmqctl cluster_status

    Cluster status of node wini2@rabbit2 ...
    Basics

    Cluster name: wini1@rabbit2

    Disk Nodes

    wini1@rabbit1
    wini2@rabbit2

    Running Nodes

    wini1@rabbit1
    wini2@rabbit2

    Versions

    wini1@rabbit1: RabbitMQ 3.8.28 on Erlang 24.2.1
    wini2@rabbit2: RabbitMQ 3.8.28 on Erlang 24.2.1

    Maintenance status

    Node: wini1@rabbit1, status: not under maintenance
    Node: wini2@rabbit2, status: not under maintenance

    Alarms

    (none)

    Network Partitions

    (none)

    Listeners

    Node: wini1@rabbit1, interface: [::], port: 15672, protocol: http, purpose: HTTP API
    Node: wini1@rabbit1, interface: [::], port: 1883, protocol: mqtt, purpose: MQTT
    Node: wini1@rabbit1, interface: [::], port: 25672, protocol: clustering, purpose: inter-node and CLI tool communication
    Node: wini1@rabbit1, interface: [::], port: 5672, protocol: amqp, purpose: AMQP 0-9-1 and AMQP 1.0
    Node: wini2@rabbit2, interface: [::], port: 15672, protocol: http, purpose: HTTP API
    Node: wini2@rabbit2, interface: [::], port: 1883, protocol: mqtt, purpose: MQTT
    Node: wini2@rabbit2, interface: [::], port: 25672, protocol: clustering, purpose: inter-node and CLI tool communication
    Node: wini2@rabbit2, interface: [::], port: 5672, protocol: amqp, purpose: AMQP 0-9-1 and AMQP 1.0

    Feature flags

    Flag: drop_unroutable_metric, state: enabled
    Flag: empty_basic_get_metric, state: enabled
    Flag: implicit_default_bindings, state: enabled
    Flag: maintenance_mode_status, state: enabled
    Flag: quorum_queue, state: enabled
    Flag: user_limits, state: enabled
    Flag: virtual_host_metadata, state: enabled
    ```

    ![클러스터링 성공 결과](https://user-images.githubusercontent.com/39556223/163900239-fe2f9661-f3a7-41b4-84a2-13804662b039.png)

----------------------------------
<br>

## MQTT 적용
1) exchange : amq.topic
2) routingKey : 슬러쉬(/) 대신 점(.) 으로 표기

```bash
# /usr/local/etc/rabbitmq/etc/rabbitmq/rabbitmq.conf

mqtt.listeners.tcp.default = 1883
## Default MQTT with TLS port is 8883
# mqtt.listeners.ssl.default = 8883

# anonymous connections, if allowed, will use the default
# credentials specified here
mqtt.allow_anonymous  = true
mqtt.default_user     = guest
mqtt.default_pass     = guest

mqtt.vhost            = /
mqtt.exchange         = amq.topic
# 24 hours by default
mqtt.subscription_ttl = 86400000
mqtt.prefetch         = 10
mqtt.subscription_ttl = undefined
```