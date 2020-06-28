the file is used test file.


error: pathspec 'file'' did not match any file(s) known to git

D:\my_code_soft\my_github\shell (master -> origin)
λ git status
On branch master
Your branch is up to date with 'origin/master'.

Untracked files:
  (use "git add <file>..." to include in what will be committed)

        linux_basic/

nothing added to commit but untracked files present (use "git add" to track)

D:\my_code_soft\my_github\shell (master -> origin)
λ git add linux_basic\
warning: LF will be replaced by CRLF in linux_basic/linux_basic.sh.
The file will have its original line endings in your working directory

D:\my_code_soft\my_github\shell (master -> origin)
λ git commit -m 'Add new file'
error: pathspec 'new' did not match any file(s) known to git
error: pathspec 'file'' did not match any file(s) known to git

