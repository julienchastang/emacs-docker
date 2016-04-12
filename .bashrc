export dotemacsrepo=~/.emacs.d/git/dotemacs/

git --git-dir=${dotemacsrepo}.git --work-tree=${dotemacsrepo} fetch 
git --git-dir=${dotemacsrepo}.git --work-tree=${dotemacsrepo} reset --hard origin/python
