case $1 in
    -f)
	# rm -f ~/.bashrc
	# rm -f ~/.bash_profile
	rm -f ~/.vimrc
	rm -rf ~/.vim
	rm -rf ~/.lldbinit
        ;;
    *)
	set -e
        ;;
esac
git config --global color.ui auto
git config --global core.editor vim
git config --global push.default simple
# git config --global core.autocrlf true
git config --global core.safecrlf true
git config --global credential.helper store

rm -rf ~/yizhiyang/config/git-*
curl -o ~/yizhiyang/config/git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
curl -o ~/yizhiyang/config/git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

rm -rf ~/yizhiyang/bin/cpplint.py
curl -o ~/yizhiyang/bin/cpplint.py https://raw.githubusercontent.com/google/styleguide/gh-pages/cpplint/cpplint.py
chmod +x ~/yizhiyang/bin/cpplint.py

ln -s ~/yizhiyang/config/.lldbinit ~/.lldbinit

ln -s ~/yizhiyang/config/.vimrc ~/.vimrc
mkdir -p ~/.vim
cp ~/yizhiyang/config/cpp.vim ~/.vim/

# ln -s ~/yizhiyang/config/.bashrc ~/.bashrc
# ln -s ~/.bashrc ~/.bash_profile

echo 'source $HOME/yizhiyang/config/.bashrc' >> ~/.bashrc

source ~/.bashrc
