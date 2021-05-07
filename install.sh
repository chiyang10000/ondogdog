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

export YZYPATH=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")" && pwd)

git config --global color.ui auto
git config --global core.editor vim
git config --global core.safecrlf true
git config --global pull.ff only
git config --global push.default current
git config --global credential.helper store
git config --global blame.date short
git config --global grep.lineNumber true
git config --global alias.hs "log --pretty='%C(yellow)%h %C(cyan)%ad %Cblue%an%C(auto)%d %Creset%s' --date=relative --date-order --graph"




rm -rf "$YZYPATH/yizhiyang/config/git-*"
version=$(git --version | cut -d' ' -f3)
major_version=$(echo $version | cut -d. -f1)
minor_version=$(echo $version | cut -d. -f2)
patch_version=$(echo $version | cut -d. -f3)
if [[ $major_version -ge 2 && $minor_version -gt 9 ]]; then
  tag=v$major_version.$minor_version.$patch_version
else
  tag=master
fi

set +e
GIT_URL_PREFIX=https://raw.githubusercontent.com/git/git/$tag
GIT_URL_PREFIX=https://gitee.com/mirrors/git/raw/$tag/
curl --connect-timeout 5 -k -o "$YZYPATH/config/git-completion.bash" $GIT_URL_PREFIX/contrib/completion/git-completion.bash
curl --connect-timeout 5 -k -o "$YZYPATH/config/git-prompt.sh" $GIT_URL_PREFIX/contrib/completion/git-prompt.sh
# curl --connect-timeout 5 -k -o "$YZYPATH/bin/cpplint.py" https://raw.githubusercontent.com/google/styleguide/gh-pages/cpplint/cpplint.py
# chmod +x "$YZYPATH/bin/cpplint.py"
set -e

mkdir -p ~/.vim
cp "$YZYPATH/config/cpp.vim" ~/.vim/
[[ -f ~/.lldbinit ]] || ln -s ~/yizhiyang/config/lldbinit ~/.lldbinit
[[ -f ~/.vimrc ]] || ln -s ~/yizhiyang/config/vimrc ~/.vimrc

[[ -f ~/.bash_profile ]] || ln -s ~/.bashrc ~/.bash_profile
echo 'test -f ~/yizhiyang/config/bashrc && source ~/yizhiyang/config/bashrc || true' >>~/.bashrc
source ~/.bashrc
