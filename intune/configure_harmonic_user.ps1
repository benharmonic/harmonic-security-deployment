<#
    .SYNOPSIS
        This script runs as the logged-in user.
        It collects the user's UserPrincipalName and places it in a text file
        in the %TEMP% directory.
        
        This is then used to configure Harmonic extensions.
    .NOTES
        AUTHOR:     ben.smith@harmonic.security
        LASTEDIT:   2024-11-20
#>

# Set up logging
$NOW = Get-Date -Format "yyyyMMdd-hhmmss"
$LogPath = "$ENV:PROGRAMDATA\Harmonic Security\HarmonicSecurity-UserScript-$NOW.log"

# Set up temporary file
$tempFilePath = "$ENV:PROGRAMDATA\Harmonic Security\HarmonicSecurity-UPN.txt"

Start-Transcript -path $LogPath | Out-Null

function Collect-UserPrincipalName {
    $UPN = $null
    $attempts = 0

    Write-Output "Attempting to identify UserPrincipalName..."
    # Loop until we are able to get the UserPrincipalName of the logged-in user
    while ($UPN -eq $null -and $attempts -lt 5) {
        $username = whoami -UPN
        if ($username -ne $null) {
            Write-Output "UserPrincipalName found using whoami -UPN"
            $UPN = $username
            continue
        } else {
            Write-Output "UserPrincipalName not available using whoami -UPN"
        }

        $username = Get-CimInstance Win32_Process -Filter 'name = "explorer.exe"' | Invoke-CimMethod -MethodName getowner | select -ExpandProperty User
        if ($username -is [array]) {
            $username = $username[0]
        }

        $username = $username -replace ' ', '.'

        # If we have a username, query directory services to translate to a UserPrincipalName
        if ($username -ne $null) {
            $strFilter = "(&(objectCategory=User)(SAMAccountName=$($username)))"
            $objDomain = New-Object System.DirectoryServices.DirectoryEntry
            $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
            $objSearcher.SearchRoot = $objDomain
            $objSearcher.PageSize = 1
            $objSearcher.Filter = $strFilter
            $objSearcher.SearchScope = "Subtree"
            $objSearcher.PropertiesToLoad.Add("userprincipalname") | Out-Null
            $colResults = $objSearcher.FindAll()
            [String]$UPN = $colResults[0].Properties.userprincipalname

            Write-Output "UserPrincipalName found using Directory Services"
        }

        $attempts++
        Start-Sleep -Seconds 5
    }

    if ($UPN -eq $null) {
        Write-Error -Message "Error configuring Harmonic Security extension - UserPrincipalName not found. Contact your Harmonic Security representative for assistance" -Category OperationStopped
        Stop-Transcript | Out-Null
        exit -1
    } else {
        $UPN | Out-File $tempFilePath
    }
}

Collect-UserPrincipalName

Stop-Transcript | Out-Null
exit 0