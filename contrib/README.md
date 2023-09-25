# contrib 

contains files that can be modified for your specific purpose
Many scripts were written to solve specific issues which may have been resolved in other ways
## example:  

threads are set as 1 by default if threads is not defined.  Modification of rules to include threads allows use of the 

### when threads is defined in the workflow, set-threads works
rule myrule:
  threads: 1  

--set-threads myrule=8
