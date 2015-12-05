
## Octopus - Repo
## Overview
There are total three classes in Repo   

- class Tree   
- class Snapshot   
- class Repos

Tree and Snapshot are used for implementing repo's structure. Technically we should call it a "graph" instead of a tree since one child may have multiple parents (this happens after Merge). Repos is a interface to interact with other modules, every function starts with "self", which means they can be called by "Repos.xxx" 

## Details
(detail is more like general idea here instead of specific implementaion, for specific instruction can check comments in code) 
  
**Tree**

 The tree(graph) keeps and array of snapshots and each time new snapshots added, it needs several parameters and add them into snapshots. 
 
 **Snapshot**
 
 in Snapshot class, where a snapshot is get initialized, it starts with it's ID, array of parent and child and it's repos_hash to handle each commit's file
 
 **Repos**
 
 Here we have over 10 functions in order to satisfy what DVCS should have. Snapshots are saved and reopen by Marshall, so most functions are heavily depend on that as you would see in code. 
 
## Notes

I hope comments in code are enough to illustrate any detail, if you have any question or suggestion, contact us by email in full documentation in main oct branch. 
 


