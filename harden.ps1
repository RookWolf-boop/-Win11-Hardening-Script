# Check for Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Restarting script as Administrator..."
    $script = $MyInvocation.MyCommand.Definition
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$script`"" -Verb RunAs
    exit
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
        "8" { Write-Host "`nExiting..."; break menu }
        default { Write-Host "`nInvalid selection. Please try again." }
    }
} while ($true)