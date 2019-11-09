FROM centos:6

RUN yum install -y wget
RUN wget -P /etc/yum.repos.d/ http://yum.oushu-tech.com/oushurepo/oushudatabaserepo/centos6/latest/oushu-database.repo
RUN yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
RUN yum install -y hadoop hadoop-hdfs
RUN yum install -y hawq
RUN yum install -y xz
RUN curl https://raw.githubusercontent.com/chiyang10000/thirdparty/master/toolchain-clang-x86_64-Linux.sh | bash
RUN curl https://raw.githubusercontent.com/chiyang10000/thirdparty/master/toolchain-gcc-x86_64-Linux.sh | bash
RUN yum install -y gcc git xz binutils
RUN yum install -y vim
RUN yum install -y centos-release-scl
RUN yum install -y rh-git29 python27-python-pip
RUN . /opt/rh/python27/enable && pip install gcovr
RUN yum install -y devtoolset-6-binutils-2.27
ENV PATH=/opt/rh/devtoolset-6/root/usr/bin/:$PATH
