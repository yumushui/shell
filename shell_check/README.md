#  ShellCheck - A shell script static analysis tool

ShellCheck is a GPLv3 tool that gives warnings and suggestions for bash/sh shell scripts:

Screenshot of a terminal showing problematic shell script lines highlighted

The goals of ShellCheck are

To point out and clarify typical beginner's syntax issues that cause a shell to give cryptic error messages.

To point out and clarify typical intermediate level semantic problems that cause a shell to behave strangely and counter-intuitively.

To point out subtle caveats, corner cases and pitfalls that may cause an advanced user's otherwise working script to fail under future circumstances.

See the gallery of bad code for examples of what ShellCheck can help you identify!



##  Table of Contents
```
How to use
    On the web
    From your terminal
    In your editor
    In your build or test suites
Installing
Compiling from source
    Installing Cabal
    Compiling ShellCheck
    Running tests
Gallery of bad code
    Quoting
    Conditionals
    Frequently misused commands
    Common beginner's mistakes
    Style
    Data and typing errors
    Robustness
    Portability
    Miscellaneous
Testimonials
Ignoring issues
Reporting bugs
Contributing
Copyright
Other Resources
```

### How to use
There are a number of ways to use ShellCheck!

####  On the web
Paste a shell script on **https://www.shellcheck.net** for instant feedback.

ShellCheck.net is always synchronized to the latest git commit, and is the easiest way to give ShellCheck a go. Tell your friends!

####  From your terminal
Run **shellcheck yourscript** in your terminal for instant output, as seen above.

In your editor
You can see ShellCheck suggestions directly in a variety of editors.

Vim, through ALE, Neomake, or Syntastic:


##  Installing
The easiest way to install ShellCheck locally is through your package manager.


On EPEL based distros:
```
yum -y install epel-release
yum install ShellCheck
```

On macOS (OS X) with Homebrew:
```
brew install shellcheck
```
On Debian based distros:
```
apt-get install shellcheck
```

