case $1 in
    -f)
	rm -f ~/.vimrc
	rm -rf ~/.lldbinit
        ;;
    *)
	set -e
        ;;
esac
git config --global color.ui auto
git config --global core.editor vim
git config --global core.safecrlf true
git config --global push.default current
git config --global credential.helper store
git config --global blame.date short

rm -rf ~/yizhiyang/config/git-*
curl -k -o ~/yizhiyang/config/git-completion.bash https://raw.githubusercontent.com/git/git/v2.17.0/contrib/completion/git-completion.bash
curl -k -o ~/yizhiyang/config/git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

rm -rf ~/yizhiyang/bin/cpplint.py
curl -k -o ~/yizhiyang/bin/cpplint.py https://raw.githubusercontent.com/google/styleguide/gh-pages/cpplint/cpplint.py
chmod +x ~/yizhiyang/bin/cpplint.py

ln -s ~/yizhiyang/config/.lldbinit ~/.lldbinit
ln -s ~/yizhiyang/config/.vimrc ~/.vimrc
mkdir -p ~/.vim
cp ~/yizhiyang/config/cpp.vim ~/.vim/

echo 'source $HOME/yizhiyang/config/.bashrc' >> ~/.bashrc

source ~/.bashrc
