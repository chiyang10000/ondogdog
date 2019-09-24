export USER=`whoami`
system=`uname -s`
if [ $system == Linux ]; then
  shopt -s checkwinsize
  alias ls='ls --color'
  alias toolchain='source ~/dev/hornet/thirdparty/toolchain-clang-x86_64-Linux.sh'
else
  CLICOLOR=1 #for mac and BSD
  export LSCOLORS=gxfxcxdxbxegedabagacad
  alias toolchain='source /opt/dependency-Darwin/package/env.sh'
  if [ `which gls`_ == _ ]; then
    alias ls='ls -G'
  else
    alias ls='gls --color'
    alias date='gdate'
  fi
fi
HAWQ_SRC=~/dev/hawq
HORNET_SRC=~/dev/hornet

export PGDATABASE=postgres

export LESS=eFRX
export LANG=en_US
export LC_ALL=en_US.utf-8

export DEPENDENCY_PATH=/opt/dependency/package
export JAVA_LIBRARY_PATH=/usr/hdp/current/hadoop-client/lib/native/:/opt/dependency/package/lib/:/usr/local/lib
export MACOSX_DEPLOYMENT_TARGET=10.12

export GOPATH=~/dev/goprojects
export PATH=$HOME/yizhiyang/bin:$HOME/yizhiyang/usr/bin:/usr/local/sbin/:/usr/local/bin/:$GOPATH:/Library/Developer/CommandLineTools/usr/bin/:/bin/:$PATH
export PATH="$HOME/.cargo/bin:$PATH"

git-writer() {
  git ls-tree -r -z --name-only HEAD -- $1 | xargs -0 -n1 git blame  --line-porcelain HEAD |grep  "^author-mail"|sort|uniq -c|sort -nr
}

mytime() {
  ts_start=`date +%s%3N`
  echo $@
  eval $@
  ts_end=`date +%s%3N`
  t=`expr $ts_end - $ts_start`
  echo $t ms
}

instrument() {
  instruments -l $1 -t Time\ Profiler -p `hawq-qe 2`
}
format-code() {
  git diff HEAD --name-only| xargs clang-format -i -style=google
  git diff HEAD --name-only| xargs cpplint.py
}

find-latest() {
  find . -iname "$1" |xargs ls -ltr
}
find-latest-diff() {
  find . -iname '*.diff' |xargs ls -ltr
}
lldb-latest() {
  if [ -n "$1" ]; then
    lldb -c `ls -rt /cores/core.$1.* | tail -n 1`
  else
    lldb -c /cores/`ls -rt /cores | tail -n 1`
  fi
}
alias lldb-recent='lldb -c /cores/`ls -rt /cores| tail -n 2| head -n 1`'

alias vi=vim
alias grep='grep --color'
alias vi-latest='vi `ls -1t|head -1`'
alias cutf="tr -s ' '| cut -d ' ' -f "

alias log-newqe='cd ~/dev/hawq/src/test/feature/newexecutor'
log-featuretest() {
  if [ -d /usr/local/hawq/feature-test ]; then
    cd /usr/local/hawq/feature-test
  fi
  if [ -d ~/dev/hawq/src/test/feature ]; then
    cd ~/dev/hawq/src/test/feature
  fi
}
log-master() {
  d=$(ps -eo pid,command| grep 'hawq.*-M master' | grep D | sed -E 's|.*-D ([^ ]+) .*|\1|')
  log=$(ls -tr $d/pg_log | grep hawq | tail -n1)
  tail -f $d/pg_log/$log
}
log-segment() {
  d=$(ps -eo pid,command| grep 'hawq.*-M segment' | grep D | sed -E 's|.*-D ([^ ]+) .*|\1|')
  log=$(ls -tr $d/pg_log | grep hawq | tail -n1)
  tail -f $d/pg_log/$log
}
log-namenode() {
  d=$(ps -eo pid,command|grep proc_namenode | grep D | sed -E 's|.*-Dhadoop.log.dir=([^ ]+) .*|\1|')
  cd $d
}
log-datanode() {
  d=$(ps -eo pid,command|grep proc_datanode | grep D | sed -E 's|.*-Dhadoop.log.dir=([^ ]+) .*|\1|')
  cd $d
}

alias vi-tpch='vi ~/dev/hawq/src/test/feature/tpchtest/tpchorc_newqe.xml'
alias gpdb='source /usr/local/gpdb/greenplum_path.sh'
alias oushudb='source /usr/local/hawq/greenplum_path.sh'
alias apache-hawq='source /usr/local/apache-hawq/greenplum_path.sh'

alias apache-diff='git diff oushu/wcy-merge-apache'
alias apache-checkout='git checkout oushu/wcy-merge-apache'
alias fix='cp ~/FindSSL.cmake ./depends/libhdfs3/CMake/FindSSL.cmake && find . -name hawq_type_mapping.h| xargs rm'



#-------------------------------------------------------------------------------
#
# lava and ci
#
#-------------------------------------------------------------------------------
ci-get() {
  if [ -n "$1" ]; then
    lava scp -r \
    ciserver:/home/ec2-user/jenkins_home/.lava/machines/$1 \
    ~/.lava/machines
  fi
  find ~/.lava -name *.json |xargs sed -i '' "s|/var/jenkins_home/|$HOME/|g"
  find ~/.lava -name *.json |xargs sed -i '' "s|/Users/[^/]*/|$HOME/|g"
}
lava-clean() {
  nodes=`lava ls| grep Error| tr -s ' '| cut -d ' ' -f 1`
  for node in $nodes
  do
    echo $node
    find ~/.lava -name $node| xargs rm -rf
  done
}



#-------------------------------------------------------------------------------
#
#   Hawq 
#
#-------------------------------------------------------------------------------
hawq-qe() {
  if [ -n "$1" ]; then
    ps -eo pid,command| grep [p]ostgres.*con.*seg| awk '{print $1}' |
    sort|head -n $1|tail -n 1
  else
    ps -eo pid,command| grep [p]ostgres.*con.*seg| awk '{print $1}' |
    sort
  fi
}
hawq-qd() {
  ps -eo pid,command| grep [p]ostgres.*con.*cmd | awk '{print $1}'
}
hawq-perf() {
  t=100
  tt=0
  while [[ -z `hawq-qe` || $t -ne $tt ]]; do
    t=$tt
    tt=`hawq-qe|wc -l`
  done
  hawq-qe |
    awk 'BEGIN {ORS=","} {print $1}' |
    xargs perf record $@ -p
}
hawq_magma_locations_master=/db_data/hawq-data-directory/magma_master
hawq_magma_locations_segment=/db_data/hawq-data-directory/magma_segment
hawq_master_directory=/db_data/hawq-data-directory/masterdd
hawq_segment_directory=/db_data/hawq-data-directory/segmentdd
magma-clean() {
  killall -9 magma_server
  rm -rf $hawq_magma_locations_master
  rm -rf $hawq_magma_locations_segment
  mkdir -p $hawq_magma_locations_master
  mkdir -p $hawq_magma_locations_segment
}
hawq-clean() {
  rm -rf $hawq_master_directory
  rm -rf $hawq_segment_directory
  mkdir -p $hawq_master_directory
  mkdir -p $hawq_segment_directory
  hdfs dfs -rmr /hawq_default*
  if [ $system == Linux ]; then
    rm -rf /data*/hawq/gsmaster/*
    rm -rf /data*/hawq/gssegment/*
    rm -rf /data1/hawq/master/*
    rm -rf /data2/hawq/segment/*
    rm -rf /data*/hawq/tmp/master/*
    rm -rf /data*/hawq/tmp/segment/*
    sudo -iu hdfs hdfs dfs -rm -f -r /hawq_data
    sudo -iu hdfs hdfs dfs -mkdir /hawq_data
    sudo -iu hdfs hdfs dfs -chown gpadmin /hawq_data
  fi
}
magma-init() {
  hawq sql -c "drop database hawq_feature_test_db;"
  hawq-setup-feature-test
  magma-clean
  rm -rf /cores/*
  hawq-restart
}
hawq-config() {
  hawq config --skipvalidation --change $1 --value $2
}
hawq-init() {
  num=${1-4}
  rm -rf /cores/*
  hawq-stop
  magma-clean
  hawq-clean
  hawq-config default_hash_table_bucket_number $num
  hawq-config default_magma_hash_table_nvseg_per_node $num
  hawq-config hawq_rm_nvseg_perquery_perseg_limit $num
  hawq-config magma_range_number $num
  hawq-config hawq_magma_locations_master file://$hawq_magma_locations_master
  hawq-config hawq_magma_locations_segment file://$hawq_magma_locations_segment
  hawq-config hawq_master_directory $hawq_master_directory
  hawq-config hawq_segment_directory $hawq_segment_directory
  hawq init cluster -a --locale='C' --lc-collate='C' \
        --lc-ctype='C' --lc-messages='C' \
        --lc-monetary='C' --lc-numeric='C' \
        --lc-time='C'
  hawq-setup-feature-test && rm -rf ~/hawqAdminLogs
}
hawq-stop() {
  ps -eo pid,command | grep [p]ostgres | awk '{print $1}' | xargs kill -9
  ps -eo pid,command | grep [m]agma_server | awk '{print $1}' | xargs kill -9
}
hawq-restart () {
  rm -rf /cores/*;
  if [ "$#" -eq 1 ]; then
    val=$1
    echo "set QE num to $1"
    hawq-config hawq_rm_nvseg_perquery_perseg_limit $val
    hawq-config default_hash_table_bucket_number $val
    hawq-config default_magma_hash_table_nvseg_per_node $val
  else
    hawq-config hawq_rm_nvseg_perquery_perseg_limit
    hawq-config default_hash_table_bucket_number
    hawq-config default_magma_hash_table_nvseg_per_node
  fi
  hawq-config gp_vmem_idle_resource_timeout 3600000
  hawq-config hawq_magma_locations_master file://$hawq_magma_locations_master
  hawq-config hawq_magma_locations_segment file://$hawq_magma_locations_segment
  hawq-config hawq_master_directory $hawq_master_directory
  hawq-config hawq_segment_directory $hawq_segment_directory
  hawq-stop
  hawq start cluster -a -M immediate
}
hawq-setup-feature-test() {
  TEST_DB_NAME="hawq_feature_test_db";
  hawq sql -d postgres << EOF
  drop database if exists $TEST_DB_NAME;
  create database $TEST_DB_NAME;
  alter database $TEST_DB_NAME set lc_messages to 'C';
  alter database $TEST_DB_NAME set lc_monetary to 'C';
  alter database $TEST_DB_NAME set lc_numeric to 'C';
  alter database $TEST_DB_NAME set lc_time to 'C';
  alter database $TEST_DB_NAME set timezone_abbreviations to 'Default';
  alter database $TEST_DB_NAME set timezone to 'PST8PDT';
  alter database $TEST_DB_NAME set datestyle to 'postgres,MDY';
EOF
}
hawq-test-list() {
  $HAWQ_SRC/src/test/feature/feature-test --gtest_list_tests
}
hawq-test() {
  ftest="$HAWQ_SRC/src/test/feature/feature-test"
  if [[ -f /usr/local/hawq/feature-test/feature-test ]]; then
    ftest="/usr/local/hawq/feature-test/feature-test"
  else
    cd $HAWQ_SRC;
    make -j8 feature-test > /dev/null;
    if [[ ! $? -eq 0 ]]; then
      return
    fi
  fi
  TEST_DB_NAME="hawq_feature_test_db";
  export PGDATABASE=$TEST_DB_NAME;
  if [ -n "$1" ]; then
    bash -c "
    source /usr/local/hawq/greenplum_path.sh
    $ftest --gtest_filter=$1";
  else
    bash -c "
    source /usr/local/hawq/greenplum_path.sh
    $ftest --gtest_filter=TestNewExec*:-*MagmaTP*:*MagmaAP*";
  fi
  cd -
  export PGDATABASE=postgres;
}



#-------------------------------------------------------------------------------
#
#  Hornet 
#
#-------------------------------------------------------------------------------
gen-coverage() {
  lcov --base-directory . --directory . --capture --output-file CodeCoverage.info --ignore-errors graph
  lcov --remove CodeCoverage.info '/opt/*' '/usr/*' '/Library/*' '/Applications/*' \
  '*/build/src/storage/format/orc/*' \
  '*/test/unit/*' '*/testutil/*' \
  '*/protos/*' '*/proto/*' '*/thrift/*' \
  --output-file CodeCoverage.info.cleaned
  genhtml CodeCoverage.info.cleaned -o CodeCoverageReport
  test -d /var/www/html/ && sudo cp -r CodeCoverageReport/* /var/www/html/
  open CodeCoverageReport/index.html
}
export RUN_UNITTEST=no
hornet-debug() {
  cd ~/dev/hornet && make incremental && cd -
}
hornet-unittest() {
  cd ~/dev/hornet && RUN_UNITTEST=YES make incremental && cd -
}
hornet-release() {
  cd ~/dev/release/hornet && make incremental && cd -
}
hornet-coverage() {
  test $# -eq 1 || echo 'Error'
  case $1 in
    dbcommon);;
    univplan);;
    interconnect);;
    storage);;
    executor);;
    *) return;;
  esac
  hornet-debug
  component=$1
  cd ~/dev/coverage/hornet && ~/dev/hornet/bootstrap
  mkdir -p ~/dev/coverage/hornet/$component/build
  cd ~/dev/coverage/hornet/$component/build
  ~/dev/hornet/$component/bootstrap --enable-coverage
  make resetcoverage
  make -j8 unittest
  gen-coverage
}
hornet-test() {
  if [ -n "$1" ]; then
    if [[ `pwd` =~ "magma" ]]; then
      make -j8 unit && test/unit/magma_server/unit --gtest_filter=$1;
    else
      make -j8 unit && test/unit/unit --gtest_filter=$1;
    fi
  else
    make -j8 unit && make punittest
  fi
}
hornet-test-list() {
  if [[ `pwd` =~ "magma" ]]; then
    make -j8 unit && test/unit/magma_server/unit --gtest_list_tests
  else
    make -j8 unit && test/unit/unit --gtest_list_tests
  fi
}
hornet-test-lldb() {
  if [[ `pwd` =~ "magma" ]]; then
    make -j8 unit && lldb test/unit/magma_server/unit -- --gtest_filter=$1;
  else
    make -j8 unit && lldb test/unit/unit -- --gtest_filter=$1;
  fi
}




#-------------------------------------------------------------------------------
#
#   Docker on Hawq
#
#-------------------------------------------------------------------------------
yizhiyang-start()
{
  sudo docker run -d -t --entrypoint bash                        \
  -v /var/run/docker.sock:/var/run/docker.sock                   \
  -v $HOME/dev-linux/dependency:/root/dependency                 \
  -v $HOME/.m2:/root/.m2                                         \
  -v $HOME/dev-linux/:/root/hawq                                 \
  -v $HOME/dev/:/root/dev                                        \
  -e BUILD_OPTION=debug                                          \
  -e BUILD_NUMBER=38324                                          \
  -e DB_VERSION=14122                                            \
  -e MAKE_COMPONET=hawq                                          \
  -e OVERWRITE_OPTION=YES                                        \
  -e PS1='[\u@\h \w]\$ '                                         \
  --name yizhiyang                                               \
  --privileged=true hub.oushu-tech.com/hawq_compile:v4.0.0.0
}
yizhiyang-login() {
  sudo docker exec -it yizhiyang /bin/bash
}
yizhiyang-stop() {
  sudo docker stop yizhiyang
  sudo docker rm yizhiyang
}
docker-clean() {
  sudo docker ps -a|grep Dead|cut -d ' ' -f 1|xargs sudo docker rm
  sudo docker ps -a|grep Exit|cut -d ' ' -f 1|xargs sudo docker rm
  sudo docker images|grep none|tr -s ' '|cut -d ' ' -f 3|xargs sudo docker rmi
}



#-------------------------------------------------------------------------------
#
#   Basic
#
#-------------------------------------------------------------------------------
# Green for Linux, yellow for macOS.
PS1='\[\033[00m\][\t] '                                                   # time
if [ $system == Linux ]; then                                    # user and host
  PS1=$PS1'\[\033[01;32m\]\u\[\033[00m\]@\[\033[32m\]\h\[\033[00m\]'
else
  PS1=$PS1'\[\033[01;33m\]\u\[\033[00m\]@\[\033[33m\]\h\[\033[00m\]'
fi
PS1=$PS1':\[\033[01;34m\]\w\[\033[00m\]'                     # working directory

# Disable git prompt in docker to improve response speed.
if [ -f ~/yizhiyang/config/git-completion.bash -a -z "${I_AM_DOCKER+x}" ]
then
  source ~/yizhiyang/config/git-completion.bash
  source ~/yizhiyang/config/git-prompt.sh
  GIT_PS1_SHOWDIRTYSTATE=true
  GIT_PS1_SHOWUNTRACKEDFILES=true
  GIT_PS1_SHOWUPSTREAM="verbose name"
  PS1=$PS1'`__git_ps1 " (%s)"`'
fi
                                                           # last command status
export PS1='$(s=$? && test $s -ne 0 && echo \[\033[31mExit code is $s)'$PS1
export PS1=$PS1'\n\$ '                                              # UID symbol

export LS_COLORS="rs=0:di=38;5;27:ln=38;5;51:mh=44;38;5;15:pi=40;38;5;11:so=38;5;13:do=38;5;5:bd=48;5;232;38;5;11:cd=48;5;232;38;5;3:or=48;5;232;38;5;9:mi=05;48;5;232;38;5;15:su=48;5;196;38;5;15:sg=48;5;11;38;5;16:ca=48;5;196;38;5;226:tw=48;5;10;38;5;16:ow=48;5;10;38;5;21:st=48;5;21;38;5;15:ex=38;5;34:*.tar=38;5;9:*.tgz=38;5;9:*.arc=38;5;9:*.arj=38;5;9:*.taz=38;5;9:*.lha=38;5;9:*.lz4=38;5;9:*.lzh=38;5;9:*.lzma=38;5;9:*.tlz=38;5;9:*.txz=38;5;9:*.tzo=38;5;9:*.t7z=38;5;9:*.zip=38;5;9:*.z=38;5;9:*.Z=38;5;9:*.dz=38;5;9:*.gz=38;5;9:*.lrz=38;5;9:*.lz=38;5;9:*.lzo=38;5;9:*.xz=38;5;9:*.bz2=38;5;9:*.bz=38;5;9:*.tbz=38;5;9:*.tbz2=38;5;9:*.tz=38;5;9:*.deb=38;5;9:*.rpm=38;5;9:*.jar=38;5;9:*.war=38;5;9:*.ear=38;5;9:*.sar=38;5;9:*.rar=38;5;9:*.alz=38;5;9:*.ace=38;5;9:*.zoo=38;5;9:*.cpio=38;5;9:*.7z=38;5;9:*.rz=38;5;9:*.cab=38;5;9:*.jpg=38;5;13:*.jpeg=38;5;13:*.gif=38;5;13:*.bmp=38;5;13:*.pbm=38;5;13:*.pgm=38;5;13:*.ppm=38;5;13:*.tga=38;5;13:*.xbm=38;5;13:*.xpm=38;5;13:*.tif=38;5;13:*.tiff=38;5;13:*.png=38;5;13:*.svg=38;5;13:*.svgz=38;5;13:*.mng=38;5;13:*.pcx=38;5;13:*.mov=38;5;13:*.mpg=38;5;13:*.mpeg=38;5;13:*.m2v=38;5;13:*.mkv=38;5;13:*.webm=38;5;13:*.ogm=38;5;13:*.mp4=38;5;13:*.m4v=38;5;13:*.mp4v=38;5;13:*.vob=38;5;13:*.qt=38;5;13:*.nuv=38;5;13:*.wmv=38;5;13:*.asf=38;5;13:*.rm=38;5;13:*.rmvb=38;5;13:*.flc=38;5;13:*.avi=38;5;13:*.fli=38;5;13:*.flv=38;5;13:*.gl=38;5;13:*.dl=38;5;13:*.xcf=38;5;13:*.xwd=38;5;13:*.yuv=38;5;13:*.cgm=38;5;13:*.emf=38;5;13:*.axv=38;5;13:*.anx=38;5;13:*.ogv=38;5;13:*.ogx=38;5;13:*.aac=38;5;45:*.au=38;5;45:*.flac=38;5;45:*.mid=38;5;45:*.midi=38;5;45:*.mka=38;5;45:*.mp3=38;5;45:*.mpc=38;5;45:*.ogg=38;5;45:*.ra=38;5;45:*.wav=38;5;45:*.axa=38;5;45:*.oga=38;5;45:*.spx=38;5;45:*.xspf=38;5;45:"

# Iterm
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
export PROMPT_COMMAND='echo -ne "\033];${PWD##/Users/admin/}\007";'
