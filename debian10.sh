#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

echo -e 'LANG=en_US.UTF-8\nLANGUAGE=en_US.UTF-8\nLC_CTYPE=en_US.UTF-8\nLC_ALL=en_US.UTF-8' > /etc/default/locale
locale-gen en_US.UTF-8

# purge unecessary install pending fix on tasksel
tasksel remove print-server xfce-desktop xfce-desktop
#install aptitude
#apt-get install -y aptitude
# install standard packages
#yes | aptitude install ~pstandard ~pimportant ~prequired
# ensure ssh server installed
tasksel install ssh-server
# ensure sudo installed
apt-get install -y sudo

#tzdata安装非交互式
echo -e "Asia\nShanghai" | apt-get install -y tzdata
echo 'tzdata tzdata/Areas select Europe' | debconf-set-selections
echo 'tzdata tzdata/Zones/Europe select Paris' | debconf-set-selections
DEBIAN_FRONTEND="noninteractive" apt install -y tzdata
ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
dpkg-reconfigure -f noninteractive tzdata


echo "hello debian" > /root/testok1.txt

#2.SSH 必定限制 IP 密钥登⼊（IPTABLES，防⽕墙等限制），使⽤ 22 端⼝，关闭密码登录, 修改 /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

#3.(重装系统也要保证) 为 root ⽤⼾写⼊ /root/.ssh/authorized_keys，内容如下
mkdir -p /root/.ssh
cat <<EOF > /root/.ssh/authorized_keys
ssh-rsa
AAAAB3NzaC1yc2EAAAADAQABAAABgQCbOVVWMytUpj2o4FFgd2KimK1kHswObRGQftCBTG6za67QKq6DOpVOBlwFDPdr6yeS65YQjC8o+i5ns/1FN2ZVw67Erh+tAcJ3Wxa3YQyNfmpl2FJUSYQm71k2ILLoDLjQPImgu71r/M4O6vrbZcOqMm4nLushYaFdmi3yP82Hc7aQhKks6Rz6gYxwKij3OgYydkzmo/J35VvbCMR/OVtV0BUKFzSoy9k1SvweVoB34IuAWpcTDE1wsZpWr26dXzAWaVYCZz/gwjkcs0/4onBcK7+KuRhk8RO5WQxwl29piJ6+E8BqsgIYBsjBTHQ7EABPWM+3IMA5k1wzMiNCDeLBk0EFVsOO7uJzQuWONmvOCEF5Y8dEGTz97KC8tK2Yhg1zn9mYacTrX3RA7/0CRJVTxIu7fGQ+FgjqTc6rQAwoCQF1lrFbdFYIRja7W6/X8ac4z5VugGHMTa3gHpooXxXNWdxutOaiap+Yo1wRDbraUjn3/dFZjR92F0rTdQycsSk= liuyunpeng.0103@bytedance.com

ssh-rsa
AAAAB3NzaC1yc2EAAAADAQABAAABAQC2mGxnviYLKudMp/T2d1cx13vA+uZeD0jf1kidbs+k7VAk+qb2pt6kX2FuW58Ix18+fnS3HMjOvonhvvMh4GLT7WPnUFiaVfKTWXiIb48srFfVTHjhmXsw0nB/OsCHperYdUmm43tnEWpHxJuIkq57lkFfbjGpJTlihZetG2I6VEqCRQX5Af0wXkoKCc2FjKiw78VYnpljXGOJYXVtmlrhFmhguadZt+pvtpFvoD64sYldZ0W0f7/EXPnlrL18evmHQSFX6P+GPO/6UxxV3xAG3PDZR+R4J6TXcDSsUoIvjXPa3Z9T22hCI9qBhJi/Wi+7dcU15xMwZoD0mW2+c7Rr icdn-key-20240620
EOF
chmod 600 /root/.ssh/authorized_keys
systemctl restart ssh

#4.换公⽹源
cat <<EOF > /etc/apt/sources.list
deb http://mirrors.volces.com/debian buster main contrib non-free
deb http://mirrors.volces.com/debian buster-backports main contrib non-free
deb http://mirrors.volces.com/debian-security buster/updates main contrib non-free
EOF

apt-get update
#apt-get update -y && apt-get upgrade -y

#5.下载 dependencies
#apt-get install sudo lvm2 wget parted xfsprogs smartmontools lm-sensors net-tools bc hddtemp sysstat vim perl curl dnsutils nload ethtool jq iotop tree net-tools vlan -y

#wget http://archive.ubuntu.com/ubuntu/pool/universe/h/hddtemp/hddtemp_0.3-beta15-53_amd64.deb
#dpkg -i hddtemp_0.3-beta15-53_amd64.deb
#apt-get install ./hddtemp_0.3-beta15-53_amd64.deb -y

#6.确认root登⼊没问题后，把其他不需要的⽤⼾(/home/*)除掉
#deluser --remove-all-files --remove-home icdnXXX

#7.升级内核⾄ 5.X
#apt-get -t buster-backports upgrade -y
#reboot now

#apt-get update
#apt-get -t buster-backports install linux-image-amd64 -y
#apt-get -t buster-backports install linux-headers-amd64 -y
#update-grub

#shutdown -r now

#8.安装 Docker (版本 >20), cgroup 安装并确保是 v1版本，不能是v2
# Add Docker's official GPG key:
#apt-get update
#apt-get install ca-certificates curl -y
#install -m 0755 -d /etc/apt/keyrings
#curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
#chmod a+r /etc/apt/keyrings/docker.asc
## Add the repository to Apt sources:
#echo \
#	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
#	$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
#	tee /etc/apt/sources.list.d/docker.list > /dev/null
#apt-get update
#apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
#docker info | grep 'Cgroup Version'


