# User Interface

This branch contains code for User Interface module implementation as well as its test cases. 
There are two ruby files:
1. UserInterface.rb - This contains the implementation of the UI.
2. TestUserInterface - This contains the unit test cases for the implementation. So far, there are total of 3 Tests and 36 Assertions.

Note that I have used 'vcs' as the keyword just as 'git' in GitHub.

The implementation is yet incomplete. It only checks for the valid commands and ignores its options. 
For E.g 'vcs commit' is recognized while in 'vcs commit -m', -m is ignored.

As the requirement becomes more clear, these options will be added.