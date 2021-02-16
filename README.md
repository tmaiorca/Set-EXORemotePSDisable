# Set-EXORemotePSDisable
Simple PS script to connect to EXON and disable Reomte PowerShell for all users, with option to exclude specific users

Use this with a scheduled task to automate the process for disabling Remote PowerShell on all newly provisioned mailboxes

To exclude users:
1. Edit the variables in lines #40 & #41
2. Include variables from lines #40 and/or #41 in the $users variable from line #42
