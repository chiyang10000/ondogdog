FROM centos:6

RUN yum install -y gcc git xz binutils patch
RUN yum install -y vim
RUN yum install -y centos-release-scl
RUN yum install -y rh-git29 python27-python-pip

COPY chiyang.patch /tmp/chiyang.patch
RUN source /opt/rh/python27/enable && pip install gcovr==4.1
RUN patch -p1 -i /tmp/chiyang.patch  -d /opt/rh/python27/root/usr/lib/python2.7/site-packages/gcovr

RUN yum install -y devtoolset-6-binutils-2.27 && rm /opt/rh/devtoolset-6/root/usr/bin/sudo
RUN yum install -y openssh-server sudo ntp

RUN yum install -y wget
RUN wget -P /etc/yum.repos.d/ http://yum.oushu-tech.com/oushurepo/oushudatabaserepo/centos6/latest/oushu-database.repo
RUN yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
RUN yum install -y hadoop hadoop-hdfs

RUN wget https://raw.githubusercontent.com/chiyang10000/thirdparty/master/toolchain-clang-x86_64-Linux.sh
RUN bash toolchain-clang-x86_64-Linux.sh
RUN wget https://raw.githubusercontent.com/chiyang10000/thirdparty/master/toolchain-gcc-x86_64-Linux.sh
RUN bash toolchain-gcc-x86_64-Linux.sh

RUN yum clean all && rm -f /etc/yum.repos.d/oushu-database.repo && wget -P /etc/yum.repos.d/ http://yumazure.oushu-tech.com:12000/oushurepo/yumrepo/test/oushu-database/centos6/4.0.0.0/release/oushu-database.repo
RUN yum install -y hawq

RUN rm -rf /opt/gcc*
RUN bash toolchain-gcc-x86_64-Linux.sh
