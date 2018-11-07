FROM hub.oushu.io/hawq:vdevrun
RUN sudo rm /etc/yum.repos.d/oushu-hadoop.repo \
      /etc/yum.repos.d/oushu-hadoop-utils.repo \
      /etc/yum.repos.d/oushu-internal.repo

RUN sudo yum install -y -q yum-plugin-ovl
RUN sudo yum install -y -q vim git
RUN mkdir -p /home/gpadmin/dev
RUN mkdir -p /home/gpadmin/dev/release
RUN mkdir -p /home/gpadmin/hawq
ENTRYPOINT /home/gpadmin/yizhiyang/install.sh -f; tail -f /dev/null
