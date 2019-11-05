#!/bin/bash
set -ex
case $1 in
  -f)
    rm -f ~/.vimrc
    rm -rf ~/.lldbinit
  ;;
  *)
    :
  ;;
esac

git config --global color.ui auto
git config --global core.editor vim
git config --global core.safecrlf true
git config --global pull.ff only
git config --global push.default current
git config --global credential.helper store
git config --global blame.date short

rm -rf ~/yizhiyang/config/git-*
version=`git --version | cut -d' ' -f3`
major_version=`echo $version | cut -d. -f1`
minor_version=`echo $version | cut -d. -f2`
patch_version=`echo $version | cut -d. -f3`
if [[ $major_version -ge 2 && $minor_version -gt 9 ]]; then
  tag=v$major_version.$minor_version.$patch_version
else
  tag=master
fi

[[ -f ~/.lldbinit ]] || ln -s ~/yizhiyang/config/lldbinit ~/.lldbinit
[[ -f ~/.vimrc ]] || ln -s ~/yizhiyang/config/vimrc ~/.vimrc
mkdir -p ~/.vim
cp ~/yizhiyang/config/cpp.vim ~/.vim/

echo 'source $HOME/yizhiyang/config/bashrc' >> ~/.bashrc

[[ -f ~/.bash_profile ]] || ln -s ~/.bashrc ~/.bash_profile
source ~/.bashrc

set +e
curl --connect-timeout 5 -k -o ~/yizhiyang/config/git-completion.bash https://raw.githubusercontent.com/git/git/$tag/contrib/completion/git-completion.bash
curl --connect-timeout 5 -k -o ~/yizhiyang/config/git-prompt.sh https://raw.githubusercontent.com/git/git/$tag/contrib/completion/git-prompt.sh
curl --connect-timeout 5 -k -o ~/yizhiyang/bin/cpplint.py https://raw.githubusercontent.com/google/styleguide/gh-pages/cpplint/cpplint.py
chmod +x ~/yizhiyang/bin/cpplint.py
set +x
