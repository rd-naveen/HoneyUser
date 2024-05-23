## HoneyUser

### Background Story/Idea

The idea here is to create a cerain list of common wellknown usernames, like Administator, ipsupport, itadmin, or some common real users (set the real very complex & long passwords: random)

Create a SIEM alerts to look for any alerts related to these users, as these are fake users, they should never be used. If we see something, it means, there is something weird going on. 

This logic is applicable to both linux and windows:

    TIP: Look for windows authentication logs and windows auth.log

### Tool Walkthrough

Importing HoneyUsers module in the system:

1. Open a powershell in administrator
2. Download the HoneyUsers folder from the git repo
3. Navigate into the Downloaded folder cd HoneyUses\
4. Intall the module using import-module cmdlet
```
PS C:\CustomScripts\HoneyUsers> Import-Module  -name .\HoneyUsers.psm1 -Verbose
VERBOSE: Loading module from path 'C:\CustomScripts\HoneyUsers\HoneyUsers.psm1'.
VERBOSE: Exporting function 'New-RandomPassword'.
VERBOSE: Exporting function 'Add-LocalHoneyUsers'.
VERBOSE: Exporting function 'Remove-LocalHoneyUsers'.
VERBOSE: Importing function 'Add-LocalHoneyUsers'.
VERBOSE: Importing function 'New-RandomPassword'.
VERBOSE: Importing function 'Remove-LocalHoneyUsers'.
```
5. Verify the instllation using get-module cmdlet
```
PS C:\CustomScripts\HoneyUsers> Get-Module -Name HoneyUsers

ModuleType Version    Name                                ExportedCommands
---------- -------    ----                                ----------------
Script     1.0.0      HoneyUsers                          {Add-LocalHoneyUsers, New-RandomPassword, Remove-LocalHoneyUsers}
```
6 (Bonus) To view the help for any functions available in this module

To add a set of Honey Users in the local system
```
PS C:\CustomScripts\HoneyUsers> Get-Help Add-LocalHoneyUsers

NAME
    Add-LocalHoneyUsers

SYNOPSIS
    Create set of honey users in the local system..


SYNTAX
    Add-LocalHoneyUsers [-ConfirmHoneyUserCreation] [-HoneyUserNameCsv] <String> [<CommonParameters>]


DESCRIPTION
    Create set of honey users in the local system..


RELATED LINKS

REMARKS
    To see the examples, type: "get-help Add-LocalHoneyUsers -examples".
    For more information, type: "get-help Add-LocalHoneyUsers -detailed".
    For technical information, type: "get-help Add-LocalHoneyUsers -full".
```

To Remove set of Honey Users from the local system

```
PS C:\CustomScripts\HoneyUsers> Get-Help Add-LocalHoneyUsers

NAME
    Add-LocalHoneyUsers

SYNOPSIS
    Create set of honey users in the local system..


SYNTAX
    Add-LocalHoneyUsers [-ConfirmHoneyUserCreation] [-HoneyUserNameCsv] <String> [<CommonParameters>]


DESCRIPTION
    Create set of honey users in the local system..


RELATED LINKS

REMARKS
    To see the examples, type: "get-help Add-LocalHoneyUsers -examples".
    For more information, type: "get-help Add-LocalHoneyUsers -detailed".
    For technical information, type: "get-help Add-LocalHoneyUsers -full".
```

To Create Honey Users on the local system: 

Pre-Requsite: list of users in the csv file `honey_user` is the header

```
PS C:\CustomScripts\HoneyUsers> Get-Content .\users_file.csv
honey_user
user1
user2
user2
```

Run the powershell with admin privilages ( this is only applicable for local system only)
```
PS C:\CustomScripts\HoneyUsers> Add-LocalHoneyUsers -HoneyUserNameCsv .\users_file.csv -ConfirmHoneyUserCreation

Creating Honey User  user1  in the Local System
Creating Honey User  user2  in the Local System
Creating Honey User  user3  in the Local System
Created the following users.. in the local system. Please add these users in the SIEM known-bad username list
Saving the list of Honey users created in  C:\Users\adhd\honey_users_23-05-2024-10-21-53.csv
Created  3  honey user accounts in the local system
Name  Enabled Description
----  ------- -----------
user1 True    Regaular User
user2 True    Regaular User
user3 True    Regaular User
```

    PS: please document these usernames somewhere for monitoring and removing them when necessary

To remove the already created Honey Users from the local system: 

Run the powershell with admin privilages ( this is only applicable for local system only)
```
PS C:\CustomScripts\HoneyUsers> Remove-LocalHoneyUsers -HoneyUserNameCsv C:\Users\adhd\honey_users_23-05-2024-10-21-53.csv -ConfirmHoneyUserDeletion
Deleted  user1  honey user accounts from the local system
Deleted  user2  honey user accounts from the local system
Deleted  user3  honey user accounts from the local system
```
### Warnings

1. This PowerShell script was not created for the production environment use, Please use it with caution. 
2. Above PowerShell script will create a users with long and complex passwords
3. To avoid, cyber defense operations, these accounts should not be used by anyone (out side the actions part of the deceptions itself, you know; "the fake logins, to trick the attacker")


### Thanks Note
Would like to Thanbks John Stran/BHIS for the inspirational course on active defense and defensive countermeasures.

### Refernces

- https://github.com/strandjs/IntroLabs/blob/master/IntroClassFiles/Tools/IntroClass/honeyuser/honeyuser.md
- https://docs.rapid7.com/insightidr/honey-users


