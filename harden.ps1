# Create a new local user
$NewUsername = Read-Host "Enter the username for the new user"
$NewPassword = Read-Host "Enter the password for the new user" -AsSecureString

try {
    New-LocalUser -Name $NewUsername -Password $NewPassword -FullName $NewUsername -Description "Created by hardening script"
    Write-Host "User '$NewUsername' has been created successfully."
} catch {
    Write-Host "Failed to create user '$NewUsername': $_" 
}

# Check for Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Restarting script as Administrator..."
    $script = $MyInvocation.MyCommand.Definition
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$script`"" -Verb RunAs
    exit
}
# ...existing code...# Get all local user accounts
$users = Get-LocalUser

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