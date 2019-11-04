FROM centos:6

RUN yum install -y wget
RUN wget -P /etc/yum.repos.d/ http://yum.oushu-tech.com/oushurepo/oushudatabaserepo/centos6/latest/oushu-database.repo
RUN yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
RUN yum install -y hadoop hadoop-hdfs
RUN yum install -y hawq
