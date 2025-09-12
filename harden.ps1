$users = Get-LocalUser
foreach ($user in $users) {
    $username = $user.Name
    $response = Read-Host "Promote '$username' to Administrator? (Y/n) [Default: n]"
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
$adminGroup = Get-LocalGroupMember -Group "Administrators"
foreach ($member in $adminGroup) {
    # Only process local users (not built-in accounts or domain users)
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