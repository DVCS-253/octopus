# User Interface

This branch contains code that provides the implementation of the user interface of DVCS

##Description of contents
+ UserInterface.rb - Implementation of the UI.   
+ TestUserInterface.rb - Unit tests for UI (12 Tests and 36 Assertions).
+ MockUI.rb - Used for unit testing. Mock output is generated so that it remains independent from other modules.
+ doc - Contains documentation of the UI module
+ UI_Design.pdf - Design and specification of the UI

##UI Dependencies
+ Depends on Repos, Push-Pull and Workspace for the actual execution of the commands. Response from these modules is shown to the user by this module. 


##Documentation
+ Rdoc was used for autimatically generating documentation for the module
+ Documentation can be viewed from doc/index.html file

##How to run
+ Run the UserInterface.rb along with command line arguments
+ For E.g. <i>ruby UserInterface.rb commit -m 'some changes' MyFile.txt</i>

##How to test
+ Run the TestUserInterface.rb as <i>ruby TestUserInterface.rb</i>

##Help
+ To get list of supported commands and their format, run the following command
+ <i>ruby UserInterface.rb help</i>