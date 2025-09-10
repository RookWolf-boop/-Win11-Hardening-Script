# Create a new local user
$NewUsername = Read-Host "Enter the username for the new user"
$NewPassword = Read-Host "Enter the password for the new user" -AsSecureString

try {
    New-LocalUser -Name $NewUsername -Password $NewPassword -FullName $NewUsername -Description "Created by hardening script"
    Write-Host "User '$NewUsername' has been created successfully."
} catch {
    Write-Host "Failed to create user '$NewUsername': $_" 
}

