FROM centos:centos7
SHELL ["/bin/bash", "-c"]

# yum install
RUN yum -y update && \
yum -y install openssh-clients openssh-server sudo \
    java-1.8.0-openjdk which net-tools

# install oushudb
COPY *.rpm /home/oushu/
RUN rpm -ivh /home/oushu/*.rpm && rm /home/oushu/*.rpm
RUN echo '12345678' | passwd --stdin oushu && \
    echo "oushu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER oushu
WORKDIR /home/oushu

# install hadoop
COPY hadoop-3.3.1.tar.gz /home/oushu/hadoop-3.3.1.tar.gz
RUN tar -xf /home/oushu/hadoop-3.3.1.tar.gz -C /home/oushu && \
  rm /home/oushu/hadoop-3.3.1.tar.gz && \
  ln -s /home/oushu/hadoop-3.3.1 /home/oushu/hadoop && \
  mkdir /home/oushu/hadoop/logs
