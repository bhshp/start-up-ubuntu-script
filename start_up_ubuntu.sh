export PASSWORD=whatyouwant
export GIT_USERNAME=whatyouwant
export GIT_EMAIL_ADDRESS=whatyouwant

# update sources
sudo cp -a /etc/apt/sources.list /etc/apt/sources.list.bak
sudo sed -i "s@http://.*archive.ubuntu.com@http://repo.huaweicloud.com@g" /etc/apt/sources.list
sudo sed -i "s@http://.*security.ubuntu.com@http://repo.huaweicloud.com@g" /etc/apt/sources.list

sudo apt update; echo "Y" | sudo apt upgrade

# install
echo "Y" | sudo apt install \
                git \
                apt-transport-https \
                ssh \
                vim \
                net-tools \
                gcc-9 \
                gcc-10 \
                g++-9 \
                g++-10 \
                binutils \
                libboost-all-dev \
                llvm \
                cmake \
                default-jdk \
                default-jre \
                maven \
                python3-pip \
                python-is-python3

# config git
git config --global user.name $GIT_USERNAME
git config --global user.email $GIT_EMAIL_ADDRESS

# config gcc g++ to version 10
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 100
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 90
sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 100

# change source of pip3
mkdir ~/.pip
touch ~/.pip/pip.conf
echo "[global]
index-url = https://repo.huaweicloud.com/repository/pypi/simple
trusted-host = repo.huaweicloud.com
timeout = 120" | sudo tee ~/.pip/pip.conf

# add workpath of pip3's recommendation
echo "
export PATH=\"\$PATH:/home/$USER/.local/bin\"" | sudo tee -a ~/.bashrc
source ~/.bashrc

# install docker
echo "Y" | sudo apt remove docker docker-engine docker.io containerd runc
sudo apt update; echo "Y" | sudo apt install \
                apt-transport-https \
                ca-certificates \
                curl \
                gnupg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update; echo "Y" | sudo apt install docker-ce docker-ce-cli containerd.io

# install elastic-stack 7.x
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
sudo apt update; echo "Y" | sudo apt install elasticsearch logstash kibana

# config elasticsearch
sudo userdel elasticsearch
sudo groupdel elasticsearch
sudo groupadd elasticsearch
sudo useradd elasticsearch -g elasticsearch
echo "$PASSWORD
$PASSWORD" | sudo passwd elasticsearch
sudo chown elasticsearch:elasticsearch -R /usr/share/elasticsearch
sudo chown elasticsearch:elasticsearch -R /var/log/elasticsearch
sudo chown elasticsearch:elasticsearch -R /var/lib/elasticsearch
sudo chown elasticsearch:elasticsearch -R /etc/default/elasticsearch
sudo chown elasticsearch:elasticsearch -R /etc/elasticsearch

# # start logstash
# cd /usr/share/logstash/bin
# sudo ./logstash -e "input{ stdin{} } output { stdout{} }"
# sudo ./logstash -e "input{ stdin{} } output{ stdout{} elasticsearch { hosts => \"http://localhost:9200/\" codec => "json" } }"
