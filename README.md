Command line tool for templating github labels
==============================================

Command line tool to define a set of labels and initialize your github repository with.


Installation / Usage
--------------------

- copy to an local folder
- copy `config.default.cmd` to `config.cmd` and edit it
- edit / remove / add files in folders `labelset\<LABEL-SET>\*` (folder names have to be kept, do not add suffixes to the files)
- execute `createlabels.bat` (the label set is a subfolder of `labelset`)


Environment
-----------

Created and tested on MS Windows 7 (64 Bit).


Tracker
-------

https://github.com/cliffparnitzky/GitHubLabelManager/issues


Sources
-------

- Idea: http://captaincodeman.com/2012/03/07/creating-labels-github-issue-system/
- API: http://developer.github.com/v3/issues/labels/