
# Check for Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Restarting script as Administrator..."
    $script = $MyInvocation.MyCommand.Definition
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$script`"" -Verb RunAs
    exit
}

# Enable Windows Defender real-time protection at startup
try {
    Set-MpPreference -DisableRealtimeMonitoring $false
    Write-Host "Windows Defender real-time protection has been enabled (startup)."
} catch {
    Write-Host "Failed to enable real-time protection at startup: $_"
}

# Menu options
$menuOptions = @(
    "Document the system",
    "Enable updates",
    "User Auditing",
    "Account Policies",
    "Promote Users to Administrator",
    "Demote Administrators",
    "Disable Built-in Administrator Account",
    "Change Password For All Users",
    "Set Minimum Password Length",
    "Enable Audit Logon Failure",
    "Remove Take Ownership Privilege",
    "Disable CTRL+ALT+DEL Requirement",
    "Enable Windows Defender Real-Time Protection",
    "Disable File Sharing for C: Drive",
    "Exit"
)

# Functions for each menu option
function Document-System {
    Write-Host "`n--- Starting: Document the system ---`n"
}

function Enable-Updates {
    Write-Host "`n--- Starting: Enable updates ---`n"
}

function User-Auditing {
    Write-Host "`n--- Starting: User Auditing ---`n"
    $users = Get-LocalUser
    foreach ($user in $users) {
        $username = $user.Name
        $response = Read-Host "Is '$username' an Authorized User? (Y/n) [Default: Y]"
        if ($response -eq "") { $response = "Y" }
        if ($response -eq "n" -or $response -eq "N") {
            try {
                Remove-LocalUser -Name $username
                Write-Host "User '$username' has been deleted."
            } catch {
                Write-Host "Failed to delete user '$username': $_"
            }
        } else {
            Write-Host "User '$username' is authorized."
        }
    }
}

function Account-Policies {
    Write-Host "--- Starting: Account Policies ---"
    # ...add submenu or logic here if needed...
}

function Promote-Users-To-Administrator {
    $users = Get-LocalUser
    foreach ($user in $users) {
        $username = $user.Name
        $response = Read-Host "Do you want to make '$username' an Administrator? (Y/n) [Default: n]"
        if ($response -eq "") { $response = "n" }
        if ($response -eq "y" -or $response -eq "Y") {
            try {
                Add-LocalGroupMember -Group "Administrators" -Member $username
                Write-Host "User '$username' has been added to Administrators."
            } catch {
                Write-Host "Failed to add '$username' to Administrators: $_"
            }
        } else {
            Write-Host "User '$username' was not promoted."
        }
    }
}

function Demote-Administrators {
    $adminGroup = Get-LocalGroupMember -Group "Administrators"
    foreach ($member in $adminGroup) {
        if ($member.ObjectClass -eq "User") {
            $username = $member.Name
            $response = Read-Host "Remove '$username' from Administrators? (Y/n) [Default: n]"
            if ($response -eq "") { $response = "n" }
            if ($response -eq "y" -or $response -eq "Y") {
                try {
                    Remove-LocalGroupMember -Group "Administrators" -Member $username
                    Write-Host "User '$username' has been removed from Administrators."
                } catch {
                    Write-Host "Failed to remove '$username' from Administrators: $_"
                }
            } else {
                Write-Host "User '$username' was not removed."
            }
        }
    }
}

function Disable-Administrator-Account {
    try {
        Disable-LocalUser -Name "Administrator"
        Write-Host "Built-in Administrator account has been disabled."
    } catch {
        Write-Host "Failed to disable Administrator account: $_"
    }
}

function Change-Password-For-All-Users {
    $newPassword = Read-Host "Enter the new password for all users" -AsSecureString
    $users = Get-LocalUser
    foreach ($user in $users) {
        try {
            Set-LocalUser -Name $user.Name -Password $newPassword
            Write-Host "Password for '$($user.Name)' has been changed."
        } catch {
            Write-Host "Failed to change password for '$($user.Name)': $_"
        }
    }
}

function Set-Minimum-Password-Length {
    $minLength = Read-Host "Enter the minimum password length (e.g., 12)"
    try {
        net accounts /minpwlen:$minLength
        Write-Host "Minimum password length set to $minLength."
    } catch {
        Write-Host "Failed to set minimum password length: $_"
    }
}

function Enable-Audit-Logon-Failure {
    try {
        AuditPol.exe /set /subcategory:"Logon" /failure:enable
        Write-Host "Audit for logon failures has been enabled."
    } catch {
        Write-Host "Failed to enable audit for logon failures: $_"
    }
}

function Remove-TakeOwnership-Privilege {
    Write-Host "Removing 'Take ownership of files or other objects' privilege from all users except Administrators..."
    $tempPath = "C:\\Temp"
    if (!(Test-Path $tempPath)) { New-Item -Path $tempPath -ItemType Directory | Out-Null }
    $cfgFile = "$tempPath\\secpol.cfg"
    secedit /export /cfg $cfgFile
    $policy = Get-Content $cfgFile
    $newPolicy = $policy -replace '(SeTakeOwnershipPrivilege = .*)', 'SeTakeOwnershipPrivilege = *S-1-5-32-544'
    $newPolicy | Set-Content $cfgFile
    secedit /configure /db C:\\Windows\\Security\\Local.sdb /cfg $cfgFile /areas USER_RIGHTS
    Write-Host "Privilege removed. Only Administrators can take ownership now."
}

function Disable-CtrlAltDel-Requirement {
    try {
        Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System" -Name "DisableCAD" -Value 1
        Write-Host "CTRL+ALT+DEL requirement for logon has been disabled."
    } catch {
        Write-Host "Failed to disable CTRL+ALT+DEL requirement: $_"
    }
}

function Enable-WindowsDefender-RealTimeProtection {
    try {
        Set-MpPreference -DisableRealtimeMonitoring $false
        Write-Host "Windows Defender real-time protection has been enabled."
    } catch {
        Write-Host "Failed to enable real-time protection: $_"
    }
}

function Disable-C-Drive-FileSharing {
    try {
        Get-SmbShare | Where-Object { $_.Path -eq 'C:\\' } | ForEach-Object { Remove-SmbShare -Name $_.Name -Force }
        Write-Host "File sharing for C: drive has been disabled."
    } catch {
        Write-Host "Failed to disable file sharing for C: drive: $_"
    }
}

# Menu loop
:menu do {
    Write-Host "`nSelect an option:`n"
    for ($i = 0; $i -lt $menuOptions.Count; $i++) {
        Write-Host "$($i + 1). $($menuOptions[$i])"
    }
    $selection = Read-Host "`nEnter the number of your choice"
    switch ($selection) {
        "1" { Document-System }
        "2" { Enable-Updates }
        "3" { User-Auditing }
        "4" { Account-Policies }
        "5" { Promote-Users-To-Administrator }
        "6" { Demote-Administrators }
        "7" { Disable-Administrator-Account }
        "8" { Change-Password-For-All-Users }
        "9" { Set-Minimum-Password-Length }
        "10" { Enable-Audit-Logon-Failure }
        "11" { Remove-TakeOwnership-Privilege }
        "12" { Disable-CtrlAltDel-Requirement }
        "13" { Enable-WindowsDefender-RealTimeProtection }
        "14" { Disable-C-Drive-FileSharing }
        "15" { Write-Host "`nExiting..."; break menu }
        default { Write-Host "`nInvalid selection. Please try again." }
    }
} while ($true)
