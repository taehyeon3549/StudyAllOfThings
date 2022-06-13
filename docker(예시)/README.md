## docker 설치

- root 계정접속
- cd /
- mkdir rpm
- yum install -y yum-utils device-mapper-persistent-data lvm2
- yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
- yum install docker-ce docker-ce-cli containerd.io --downloadonly --downloaddir=/rpm
- cd rpm
- rpm -Uvh *

## docker 실행

- systemctl enable docker
- systemctl start docker

## 권한부여

- sudo usermod -aG docker $USER

## docker-compose 설치

- wget https://github.com/docker/compose/releases/download/1.26.0/docker-compose-Linux-x86_64
- mv docker-compose-Linux-x86_64 docker-compose 
- sudo mv docker-compose /usr/local/bin/ 
- sudo chmod +x /usr/local/bin/docker-compose

## docker-compose 실행

- 

## docker - mosquitto 설치(성공)

- docker pull eclipse-mosquitto
- docker images 를 이용해 잘 설치되어있는지 확인

## 명령어
- pull : 도커허브에서 가져오기
- docker images : 도커이미지 확인
- docker rmi : 도커이미지 삭제

## docker - mosquitto 실행(성공)
- docker run --restart=always --name mosquitto -p 1883:1883 -p 9001:9001 -v /docker/conf/mosquitto/mosquitto.conf:/mosquitto/config/mosquitto.conf -d eclipse-mosquitto
- docker run --restart=always --name mosquitto --net=host -v /docker/conf/mosquitto/mosquitto.conf:/mosquitto/config/mosquitto.conf -d eclipse-mosquitto

## 명령어
- run 컨테이너 실행
- stop 컨테이너 종료
- -i -t : 상호작용하기위한 옵션 (interactive)
- -p : 포트포워딩 (port)
- -v : 외부 파일 사용 (volume)
- ps : 실행중인 컨테이너 조회, -a 전체 컨테이너 조회
- rm : 컨테이너 삭제
- docker rm 'docker ps -a -q' : 컨테이너 전체삭제
- -d : 데몬
- --name 컨테이너이름지정

## docker - mosquitto 저장/로드(성공)
- 저장 : docker save -o eclipse-mosquitto.tar eclipse-mosquitto:latest
- 로드 : docker load -i eclipse-mosquitto.tar

## 방화벽해제(성공)
- firewall-cmd --permanent --zone=public --add-port=1883/tcp
- firewall-cmd --reload
