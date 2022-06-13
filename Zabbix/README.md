# Zabbix

| 수정일 | 수정 내용 | 수정자 |
| --- | --- | --- |
| 2022. 04. 19 | 최초 작성 | cs 김태현 |

> Zabbix 설치 참고 : <https://itswt.tistory.com/8?category=828925>
>
> Zabbix Git 공식 : <https://git.zabbix.com/projects/ZBX/repos/zabbix/browse>

--------------------------
<br>

## Zabbix Server 

- Apache 설치
    ```bash
    $ yum -y install httpd
    $ service httpd start

    # OS 재부팅시 자동 재시작    
    $ systemctl enable httpd
    ```    

- MariaDB 설치
    - MariaDB yum repo 등록
        ```bash
        #vi /etc/yum.repos.d/MariaDB.repo

        [mariadb]
        name = MariaDB
        baseurl = http://yum.mariadb.org/10.4/centos7-amd64
        gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
        gpgcheck=1
        ```

    -  MariaDB yum 설치
        ```bash
        $ yum install -y MariaDB    
        ```

    - MariaDB 설치 확인
        ```bash
        $ rpm -qa | grep MariaDB
        #MariaDB-compat-10.4.24-1.el7.centos.x86_64
        #MariaDB-common-10.4.24-1.el7.centos.x86_64
        #MariaDB-client-10.4.24-1.el7.centos.x86_64
        #MariaDB-server-10.4.24-1.el7.centos.x86_64

        $ mariadb --version
        #mariadb  Ver 15.1 Distrib 10.4.24-MariaDB, for Linux (x86_64) using readline 5.1
        ```
    
    - MariaDB 실행
        ```bash
        $ systemctl start mariadb

        # OS 재부팅시 자동 재시작    
        $ systemctl enable mariadb
        ```

    - MariaDB 비번 설정
        ```bash
        $ /usr/bin/mysqladmin -u root password '변경할 비밀번호 입력'
        ```

    - 포트 및 데몬 이름 확인
        ```bash
        $ netstat -anp | grep 3306

        #tcp6       0      0 :::3306                 :::*                    LISTEN      29805/mysqld
        ```

    - CharaterSet utf8mb4 설정
        ```bash
        #vi /etc/my.cnf

        #
        # This group is read both by the client and the server
        # use it for options that affect everything
        #
        #[client-server]

        #
        # include *.cnf from the config directory
        #
        !includedir /etc/my.cnf.d


        [mysqld]
        default_storage_engine=innodb

        init-connect='SET NAMES utf8mb4'
        lower_case_table_names=1
        character-set-server=utf8mb4
        collation-server=utf8mb4_unicode_ci


        [client]
        port=3306
        default-character-set = utf8mb4

        [mysqldump]
        default-character-set = utf8mb4

        [mysql]
        default-character-set = utf8mb4
        ~
        ```
    - mariaDB 재시작
        ```bash
        $ systemctl restart mariadb
        ```

    - mariaDB 설정
        ```bash
        $ mysql_secure_installation        

        NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
            SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

        In order to log into MariaDB to secure it, we'll need the current
        password for the root user. If you've just installed MariaDB, and
        haven't set the root password yet, you should just press enter here.

        Enter current password for root (enter for none):
        OK, successfully used password, moving on...

        Setting the root password or using the unix_socket ensures that nobody
        can log into the MariaDB root user without the proper authorisation.

        You already have your root account protected, so you can safely answer 'n'.

        Switch to unix_socket authentication [Y/n] Y
        Enabled successfully!
        Reloading privilege tables..
        ... Success!


        You already have your root account protected, so you can safely answer 'n'.

        Change the root password? [Y/n] n
        ... skipping.

        By default, a MariaDB installation has an anonymous user, allowing anyone
        to log into MariaDB without having to have a user account created for
        them.  This is intended only for testing, and to make the installation
        go a bit smoother.  You should remove them before moving into a
        production environment.

        Remove anonymous users? [Y/n] Y
        ... Success!

        Normally, root should only be allowed to connect from 'localhost'.  This
        ensures that someone cannot guess at the root password from the network.

        Disallow root login remotely? [Y/n] Y
        ... Success!

        By default, MariaDB comes with a database named 'test' that anyone can
        access.  This is also intended only for testing, and should be removed
        before moving into a production environment.

        Remove test database and access to it? [Y/n] Y
        - Dropping test database...
        ... Success!
        - Removing privileges on test database...
        ... Success!

        Reloading the privilege tables will ensure that all changes made so far
        will take effect immediately.

        Reload privilege tables now? [Y/n] Y
        ... Success!

        Cleaning up...

        All done!  If you've completed all of the above steps, your MariaDB
        installation should now be secure.

        Thanks for using MariaDB!
        ```

- PHP 5.6 설치
    - yum utils 설치(for php5.6 설치를 위해 쉽게 활성화 비활성화 하기 위해)
        ```bash
        $ yum install yum-utils
        ```
    - epel-release 등록
        ```bash
        $ yum -y install epel-release

        $ yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
        ```

    - 설치
        ```bash
        # 5.4 비활성화
        $ yum-config-manager --disable remi-php54

        # 72 활성화
        $ yum-config-manager --enable remi-php72

        # 설치
        $ yum install -y php php-pear php-cgi php-common php-mbstring php-snmp php-gd php-pecl-mysql php-xml php-mysql php-gettext php-bcmath
        ```

    - php timezone 설정
        ```bash
        # vi /etc/php.ini

        # Timezone 설정
        date.timezone = Asia/Seoul

        # zabbix 요구 사항 설정
        post_max_size = 16M
        max_execution_time = 300
        max_input_time = 300
        ```

        재기동

        ```bash
        $ systemctl restart httpd.service
        ```

- ntp
    - 설치
        ```bash
        $ yum -y install ntp
        ```
    - ntp 서버 설정
        ```bash
        # vi /etc/ntp.conf

        server time.bora.net
        ```

    - 확인
        ```bash
        # 서비스 시작
        $ systemctl start htpd

        # ntp 동작 확인
        ntpq -p

        #     remote           refid      st t when poll reach   delay   offset  jitter
        #==============================================================================
        # time.bora.net   .}.2..          16 u   43   64    0    0.000    0.000   0.000

        ```
    - selinux 설정

        Selinux를 disabled을 설정. 이 설정을 안하면 Zabbix Server인식이 안됨.

        - 설정
            ```bash
            # vi /etc/sysconfig/selinux

            SELINUX=disabled       
            ```

        - 재시작
            ```bash
            $ reboot
            ```

        - 설정 확인
            ```bash
            $ sestatus
            
            # SELinux status:                 disabled
            ```

- Zabbix 설치
    ```bash
    # rpm 추가
    $ rpm -ivh https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm

    # 설치
    $ yum install zabbix-server-mysql  zabbix-web-mysql zabbix-agent zabbix-get
    ```

- Zabbix 용 DB 설정
    ```bash
    # mysql 접속

    $ mysql -u root -p
    ```

    ```SQL
    <!-- zabbix db 생성 및 utf8 설정 -->
    CREATE DATABASE zabbix CHARACTER SET utf8 collate utf8_bin;

    <!-- 권한 설정 -->
    GRANT ALL PRIVILEGES ON zabbix.* to zabbix@'localhost' IDENTIFIED BY 'winitech0)';

    <!-- 적용 -->
    FLUSH PRIVILEGES;
    ```

    - 기본 테이블 생성
        > 시작전에 오류 2번( **ERROR 1118 (42000) at line 1278 오류** ) 확인 할 것!

        ```bash
        # Zabbix DB 쿼리 위치로 이동
        $ cd /usr/share/doc/zabbix-server-mysql-4.0.39
        # AUTHORS  COPYING  ChangeLog  NEWS  README  create.sql.gz

        # Zabbix 쿼리 압축 해제
        $ gunzip create.sql.gz

        # 설치한 DB에 쿼리 실행
        $ mysql -u root -p zabbix < create.sql
        ```

- Zabbix 설정

    - Zabbix server 설정
    
        설치한 DB 정보 입력

        ```bash
        # vi /etc/zabbix/zabbix_server.conf

        # 100 Line 근처
        DBName=zabbix

        # 107 Line 근처
        DBSchema=zabbix

        # 124 Line 근처
        DBPassword=Password
        ```

    - Zabbix agent 설정
        ```bash
        # vi /etc/zabbix/zabbix_agentd.conf

        # 98 Line 근처
        Server=127.0.0.1

        # 139 Line 근처
        ServerActive=127.0.0.1

        # 150 Line 근처 Web 에서 호스트 추가 할때 알고 있어야 하는 정보
        Hostname=Zabbix server
        ```

    - zabbix 서비스 시작
        ```bash
        systemctl enable zabbix-server.service

        systemctl restart zabbix-server.service

        systemctl status zabbix-server.service
        ```

- firewall 설정
    ```bash
    # 기본
    $ firewall-cmd --add-service={http,https} --permanent

    # Zabbix서버 → Zabbix에이전트:10050
    $ firewall-cmd --add-port=10050/tcp --zone=public --permanent

    # Zabbix에이전트 → Zabbix서버:10051
    $ firewall-cmd --add-port=10051/tcp --zone=public --permanent   
    
    # firewalld설정후 재시작
    $ firewall-cmd --reload
    ```
- httpd 재시작
    ```bash
    systemctl restart httpd
    ```

- zabbix 초기 설정

    1. <http://172.18.212.183/zabbix/> 이동해서 기본 세팅 시작
    2. Admin/zabbix 로 로그인 해서 page 확인


--------------------------
<br>

## Zabbix Agent

- Agent 설치
    ```bash
    $ wget https://repo.zabbix.com/zabbix/4.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.0-2+bionic_all.deb
    ```


------------------------
<br>

# 이슈사항

- /var/lib/mysql/mysql.sock 오류
    - 상황
        ```bash
        [root@localhost ~]# mysql -u root -p
        Enter password:
        ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/lib/mysql/mysql.sock' (2)
        ```

    - 해결방법

        /var/lib/mysql 권한 755 설정 이후 재기동

        ```bash
        # 권한설정
        $ chmod 755 -R /var/lib/mysql/

        # 재기동
        $ systemctl stop mariadb
        $ systemctl start mariadb

        # 재접속
        $  mysql -u root -p
        ```

- ERROR 1118 (42000) at line 1278 오류 
    > 해결 참고 : <https://support.plesk.com/hc/en-us/articles/115000256794-MySQL-database-import-in-Plesk-fails-ERROR-1118-42000-Row-size-too-large>

    - 상황 
        ```bash
        ERROR 1118 (42000) at line 1278: Row size too large (> 8126). Changing some columns to TEXT or BLOB may help. In current row format, BLOB prefix of 0 bytes is stored inline.
        ```

    - 해결 방법
        1. 백업 /etc/my.conf
        2. my.conf 수정
            ```bash
            # vi /etc/my.conf

            [mysqld]
            default_storage_engine=MyISAM
            innodb_strict_mode = 0
            ```
        3. mysql 재기동
            ```bash
            $ systemctl restart mariadb
            ```
        4. 기존에 생성한 zabbix database 삭제
            ```sql
            DROP DATABASE zabbix;

            FLUSH PRIVILEGES;            
            ```
        4. 다시 create.sql dump 시작
        5. dump 이후 my.conf 파일 복원
            ```bash
            mv /etc/my.cnf.bak /etc/my.cnf --force
            ```
        6. mysql 재기동
            ```bash
            $ systemctl restart mariadb
            ```






    