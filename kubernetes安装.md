k8s-18.2安装教程

# docker 安装

系统：centos7.4+  
版本：docker-ce 19.03.8 （推荐）  
**安装依赖：**  

> yum install -y yum-utils device-mapper-persistent-data lvm2  

**add repository：**

>    yum-config-manager --add-repo \
>   https://download.docker.com/linux/centos/docker-ce.repo

**Install：**

>    yum update -y && yum install -y \  
>          containerd.io-1.2.13 \  
>          docker-ce-19.03.8 \  
>          docker-ce-cli-19.03.8

**修改配置**

> mkdir /etc/docker  
> cd /etc/docker  
> cat > /etc/docker/daemon.json <<EOF  
> {  
>   "exec-opts": ["native.cgroupdriver=systemd"],  
>   "log-driver": "json-file",  
>   "log-opts": {  
>     "max-size": "100m"  
>   },  
>   "storage-driver": "overlay2",  
>   "storage-opts": [  
>     "overlay2.override_kernel_check=true"  
>   ]  
> }  
> EOF  

> mkdir -p /etc/systemd/system/docker.service.d

**Restart Docker**  

> systemctl daemon-reload  
> systemctl restart docker  
