
function New-RandomPassword {
    param (
        [Parameter(Mandatory = $true)]
        [int]$Length, # or whatever your organiazation allows
        [string]$Characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+[]{}|;:,.<>?',
        [switch]$ConfirmLessSecure
    )

    if ($Length -le 22) {

        if ( !$ConfirmLessSecure){
            Write-Host "Password Length should be more than 22 Characters."
            
            $ch = Read-Host "Do you want to set the password lenght to 22 Chars or something else. \n Y/y to use 15 or N/n to continue to use the give password length"
                
            if (($ch -eq 'Y') -or $ch -eq 'y') {
                $Length = 22
            }
            else {
                Write-Host "Using the given password Lenght: " + $Length
            }
        }
       
    }
     
    $password = -join (1..$length | ForEach-Object { Get-Random -InputObject $characters.ToCharArray() })
    return $password
	
	<# 
    .Synopsis
    Generate a random complex password with custom length ..

    .Description
    Generate a random complex password with custom length 

    .Parameter Length
    Length of the user password is mandatory. Recommended 22 chars, anything less than that will require confirmation

    .Parameter Characters
    Custom password character set. By default Script will use a-zA-Z0-9 and ASCII speical Symbols
	
	.Parameter ConfirmLessSecure
    ConfirmLessSecure is required, when using password lenght less than 22
	

    .Example
    New-RandomPassword -Length 25
    New-RandomPassword -Length 25 -Characters "1234567890!@#$%^&*()"
    #>
}

function Add-LocalHoneyUsers{
    param (
    [switch]$ConfirmHoneyUserCreation,
    [Parameter(Mandatory = $true)]
    [string]$HoneyUserNameCsv
    )

    if ((Test-Path $HoneyUserNameCsv) -eq "True"){
        $csv_data = Import-Csv $HoneyUserNameCsv

        $honey_users = $csv_data|Select-Object -Property honey_user
        
        if ($honey_users.Count -eq 0){
            Write-Host "Please provide the honey username in the correct format"
            Write-Host """
            # for local users csv file header and format should be as follows
            #'honey_user
            #-----
            #user1
            #user2
            # ..."""

            exit 0
        }
               
        $created_users = @()

        if (!$ConfirmHoneyUserCreation) {
            Write-Host "Script will create $($honey_users.Length) user in the local system" -ForegroundColor Red
            $confirm_string = Read-Host "Confirm Honey User Creation by Typing(case sensitive): Confirm"
            
            if (!$confirm_string -eq "Confirm"){
                Write-Host "Given input is not \"Confirm\" Hence exiting the program" -ForegroundColor Red
                exit 0
            }
    
        }
        foreach ($csv_user in $honey_users){
            $user_name = $csv_user.honey_user

            $password = New-RandomPassword -Length 25
            try{
                New-LocalUser -Name $user_name -FullName $user_name -Description "Regaular User" -Password (ConvertTo-SecureString -AsPlainText $password -Force) -AccountNeverExpires  -PasswordNeverExpires -ErrorAction Stop
        
                Enable-LocalUser -Name $user_name  -ErrorAction Stop
            
                if ($(Get-Localuser -name $user_name).Enabled -eq "True"){
                    Write-Host "Creating Honey User " $user_name " in the Local System"
                    $created_users += [PSCustomObject]@{honey_user = $user_name}
                }
            }
            catch {
                Write-Host "Failed to create Honey User " $user_name " in the Local System"  -ForegroundColor Red
                Write-Host $_.Exception.Message  -ForegroundColor Red
                Write-Host ""
            }
            
        }

        Write-Host "Created the following users.. in the local system. Please add these users in the SIEM known-bad username list"
        Write-Host ""

        if ((Test-Path $home) -ne "True"){
            $csv_out_location =  Read-Host "Enter the full file path (use .csv extension)"
        }

        $csv_out_location =  $home+"\honey_users_"+(Get-Date -Format "dd-MM-yyyy-hh-mm-ss")+".csv"

        Write-Host "Saving the list of Honey users created in "  $csv_out_location
        Write-Host ""

        $created_users | Export-Csv -Path $csv_out_location -NoTypeInformation

        Write-Host "Created " $created_users.length " honey user accounts in the local system"
        Write-Host ""
    }
    else{
        Write-Host "Given file is not exists or readable"
    }

    <# 
    .Synopsis
    Create set of honey users in the local system..

    .Description
    Create set of honey users in the local system..

    .Parameter HoneyUserNameCsv
    Length of the user password is mandatory. Recommended 22 chars, anything less than that will require confirmation
    for local users csv file header and format should be as follows (if not script won't parse the data)
        'honey_user
        -----
        user1
        user2
         ...

    .Parameter ConfirmHoneyUserCreation
    Use this switch to confirm the honey user creation on the local system

    .Example
    TODO
    #>
}

function Remove-LocalHoneyUsers{
    param (
    [switch]$ConfirmHoneyUserDeletion,
    [Parameter(Mandatory = $true)]
    [string]$HoneyUserNameCsv
    )

    if ((Test-Path $HoneyUserNameCsv) -eq "True"){

        $csv_data = Import-Csv $HoneyUserNameCsv

        $honey_users = $csv_data | Select-Object -Property honey_user
        
        if ($honey_users.Count -eq 0){
            Write-Host "Please provide the honey username in the correct format"
            Write-Host """
            # for local users csv file header and format should be as follows
            #'honey_user
            #-----
            #user1
            #user2
            # ..."""

            exit 0
        }

        if (!$ConfirmHoneyUserDeletion) {
            Write-Host "Script will delete $($honey_users.Length) user from the local system" -ForegroundColor Red
            $confirm_string = Read-Host "Confirm Honey User Deletion by Typing(case sensitive): Confirm" 
            
            if (!$confirm_string -eq "Confirm"){
                Write-Host "Given input is not \"Confirm\" Hence exiting the program" -ForegroundColor Red
                exit 0
            }
    
        }

        foreach ($csv_user in $honey_users){
	    $user_name = $csv_user.honey_user
            try {
                Remove-LocalUser -Name $user_name -ErrorAction Stop
                Write-Host "Deleted " $user_name " honey user accounts from the local system"
            }
            catch {
                Write-Host "Failed to remove the Honey User " $user_name " from the Local System." -ForegroundColor Red
		        Write-Host "Please refer the error message and manually delete if from the local system"  -ForegroundColor Red
                Write-Host $_.Exception.Message  -ForegroundColor Red
                Write-Host ""
            }
            
        }
    }
    else{
        Write-Host "Given file is not exists or readable"
    }

    <# 
    .Synopsis
    Delete set of honey users in the local system..

    .Description
    Delete set of honey users in the local system..

    .Parameter HoneyUserNameCsv
    Length of the user password is mandatory. Recommended 22 chars, anything less than that will require confirmation
    for local users csv file header and format should be as follows (if not script won't parse the data)
        'honey_user
        -----
        user1
        user2
         ...

    .Parameter ConfirmHoneyUserDeletion
    Use this switch to confirm the honey users deletion from the local system

    .Example
    TODO
    #>
}
