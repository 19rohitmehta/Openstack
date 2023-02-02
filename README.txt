Please find the latest CR OS 7 scripts and manual steps for all relevant nodes:

CoD_CR_Director_v1.sh
CoD_CR_Utility_v1.sh  

Before running these 2 scripts, the following files should be in the same directory as the script:
  audit.rules_vil
  default_password-auth-ac
  default_system-auth-ac

Script execution
#dos2unix CoD_CR_Director_v1.sh 
#./CoD_CR_Director_v1.sh                   : run the script on Director Node

#dos2unix CoD_CR_Director_v1.sh 
#./CoD_CR_Utility_v1.sh                    : run the script on Utility Node 


To restore & help :-

On Director Node
#./CoD_CR_Director_v1.sh --restore         : fallback to the state before the script is executed
#./CoD_CR_Director_v1.sh --help            : print out help info

On Utility Node
#./CoD_CR_Utility_v1.sh --restore          : fallback to the state before the script is executed
#./CoD_CR_Utility_v1.sh --help             : print out help info





.


