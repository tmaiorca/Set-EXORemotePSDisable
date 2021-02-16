<#............................................................................................................................................................................................
Purpose: Disables Remote PowerShell for all Exchange Online users that have their 'RemotePowerShellEnabled' value set to 'TRUE'. Optional ability to exclude specific users in lines 40 & 41.
Developed By: Maiorca, Troy
Last Updated: 1/25/21
............................................................................................................................................................................................#>

#Module prerequisite check & download using PSGallery
$modules = "ExchangeOnlineManagement"

Write-Host 'Checking for prerequisite module...' -ForegroundColor Yellow
$modules | ForEach-Object {
if (Get-Module -ListAvailable -Name $_) {
    Write-Host `n"$_ - installed" -ForegroundColor Green 
}

else {
    Set-PSRepository PSGallery -InstallationPolicy Trusted
    $PSGalleryCheck = Find-Module $_
    Write-Host `n"$_ - not installed" -ForegroundColor Red        
    Write-Host "Downloading $_ from PSGallery..." -ForegroundColor Yellow -NoNewline
        
    $PSGalleryCheck | Install-Module
        if (Get-Module -ListAvailable $_) {
            Write-Host `n"$_ module installed successfully!" -ForegroundColor Green
            Get-Module -ListAvailable $_ | Select-Object Name, Version, ModuleType, Path
            Set-PSRepository PSGallery -InstallationPolicy Untrusted
        }
        else {
            Write-Host `n"$_ module installation failed. Please install module and re-run."
            Exit
        }
    }           
}

#Connecting to Exchange Online | Getting list of PowerShell Enabled Users | Disable Remote PowerShell
Connect-ExchangeOnline

#Retrieving list of all users with Remote PowerShell currently enabled | Set the retrieved users Remote PowerShell to disabled
#For users to be excluded, uncomment below variables and add them in the $users variable
$userExclude1 = ""
$userExclude2 = ""
$users = Get-User -Filter {(RemotePowerShellEnabled -eq $true) -and (UserPrincipalName -ne "$userExclude1" -and UserPrincipalName -ne "$userExclude2")} -ResultSize Unlimited
$users | ForEach-Object {
    $name = $_.UserPrincipalName
    Set-User $name -RemotePowerShellEnabled:$false
}

#Exporting list of users that had PowerShell disabled
$exportCSV = "C:\temp\Set-EXORemotePSDisable-$(Get-Date -f yyy-MM-dd).csv"
$users | ForEach-Object {
    $user = Get-User $_.UserPrincipalName | Select-Object Name,DisplayName,UserPrincipalName,RemotePowerShellEnabled
    $PSobj = [PSCustomObject]@{
        'Name' = $user.Name
        'DisplayName' = $user.DisplayName
        'UserPrincipalName' = $user.UserPrincipalName
        'RemotePowerShellEnabled' = $user.RemotePowerShellEnabled
    }
    $PSobj
} | Export-CSV $exportCSV -NoTypeInformation

#Disconnect Exchange Online
Disconnect-ExchangeOnline -Confirm:$False