# Check for Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Restarting script as Administrator..."
    $script = $MyInvocation.MyCommand.Definition
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$script`"" -Verb RunAs
    exit
}
# ...existing code...

# Define menu options
$menuOptions = @(
    "Document the system",
    "Enable updates",
    "User Auditing",
    "Exit"
)
# Define functions for each option
function Document-System {
    Write-Host "`n--- Starting: Document the system ---`n"
}

function Enable-Updates {
    Write-Host "`n--- Starting: Enable updates ---`n"
}

function User-Auditing {
    Write-Host "`n--- Starting: User Auditing ---`n"
    Write-Host "Debug Test"
    # Loop through all users
    foreach ($user in $users) {
    $username = $user.Name
    # Prompt for authorization, default is Y
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
        "4" { Write-Host "`nExiting..."; break menu }  # leave the do{} loop
        default { Write-Host "`nInvalid selection. Please try again." }
    }
} while ($true)




