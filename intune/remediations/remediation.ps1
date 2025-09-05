<#
.DESCRIPTION
    Creates scheduled tasks
#>
# User-space task to get the user's UPN every login
$taskName = "HarmonicSecurityExtension-IdentifyUser";
$taskStatus = Get-ScheduledTask | Where-Object { $_.taskName -eq $taskName }
$upnFileLocation = "C:\ProgramData\Harmonic Security\UPN.txt"

if (-not (Test-Path $upnFileLocation)) {
    New-Item -Path $upnFileLocation -ItemType File -Force
}

# Use the well-known SID for the "Everyone" group, as it isn't called "Everyone" in non-English
# installations of Windows
$sid = New-Object System.Security.Principal.SecurityIdentifier("S-1-1-0")
$everyone = $sid.Translate([System.Security.Principal.NTAccount])
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($everyone, "Write", "Allow")
$fileSecurity = Get-Acl $upnFileLocation
$fileSecurity.AddAccessRule($accessRule)
Set-Acl -Path $upnFileLocation -AclObject $fileSecurity

if (!$taskStatus) {
    try {
        Write-Output "$taskName task does not exist. Creating task"

        $taskAction = New-ScheduledTaskAction -Execute "cmd" -Argument "/c whoami /upn > ""$upnFileLocation"""
        $tastSettingsSet = New-ScheduledTaskSettingsSet
        
        # Use the well-known SID for the "Users" group, as it isn't called "Users" in non-English
        # installations of Windows
        $usersSID = "S-1-5-32-545"
        $taskUser = New-ScheduledTaskPrincipal -GroupId $usersSID
        
        Register-ScheduledTask -TaskName $taskName -TaskPath "\" -Action $taskAction -Settings $tastSettingsSet -Principal $taskUser
    } catch {
        Write-Output "Error creating $taskName"
    }
}

# SYSTEM task to update the registry
$taskName = "HarmonicSecurityExtension-ConfigureRegistry";
$taskStatus = Get-ScheduledTask | Where-Object { $_.taskName -eq $taskName }
$scriptLocation = "C:\ProgramData\Harmonic Security\ConfigureRegistry.ps1"

if (!$taskStatus) {
    try {
        Write-Output "$taskName task does not exist. Creating task"

@'
# Make sure these values are correct
$company_api_key = "changeme"
$company_id = "changeme"
$extension_identifier = "nmgdkbiadhkdekcolccalbcmnmgjeioa" 

$NOW = Get-Date -Format "yyyyMMdd-hhmmss"
$LogPath = "$ENV:PROGRAMDATA\Harmonic Security\HarmonicSecurity-$NOW.log"

Start-Transcript -path $LogPath | Out-Null

# Execute user-space script and wait for it
$taskName = "HarmonicSecurityExtension-IdentifyUser"

Start-ScheduledTask -TaskName $taskName
Write-Output "Waiting for user-space task to finish collecting UPN"

while ((Get-ScheduledTask -TaskName $taskName).State -ne "Ready") {
   Start-Sleep -Seconds 5
}

function Configure-FirefoxExtension {
    Param(
        [Parameter()][String] $UPN,
        [Parameter()][String] $API_Key,
        [Parameter()][String] $Company_ID
    )
    if ($company_api_key -eq "changeme") {
        Write-Error "You must set the company API key to be able to run this script" -Category OperationStopped
        Stop-Transcript | Out-Null
        exit -1
    } elseif ($company_id -eq "changeme") {
        Write-Error "You must set the company API key to be able to run this script" -Category OperationStopped
        Stop-Transcript | Out-Null
        exit -1
    }

    $registry_path_firefox = "HKLM:\SOFTWARE\Policies\Mozilla\Firefox\3rdparty\Extensions\firefox-extension@harmonic.security"

    # Create Firefox policy path for Harmonic Security browser extension if it does not exist
    if (!(Test-Path $registry_path_firefox)) {
        New-Item -Path $registry_path_firefox -Force -ItemType Directory | Out-Null
    }

    # Set the Registry keys
    try {
        Write-Host "Attempting to set companyApiKey for Firefox..."
        Set-ItemProperty -Path $registry_path_firefox -Name "companyApiKey" -Value $API_Key -ErrorAction Stop
        Write-Host "Attempting to set companyId for Firefox..."
        Set-ItemProperty -Path $registry_path_firefox -Name "companyId" -Value $Company_ID -ErrorAction Stop
        Write-Host "Attempting to set userEmail for Firefox..."
        Set-ItemProperty -Path $registry_path_firefox -Name "userEmail" -Value $UPN -ErrorAction Stop
        Write-Host "Attempting to set companyRegion for Firefox..."
        Set-ItemProperty -Path $registry_path_firefox -Name "companyRegion" -Value "eu" -ErrorAction Stop

        if ($?) {
            Write-Host "Harmonic Security extension configured successfully for Firefox!"
        }
    } catch {
        Write-Error -Message "Failed to set registry value: $_" -Category OperationStopped
        $errorDetails = $_.Exception
        Write-Error -Message "Error details: $errorDetails" -Category OperationStopped
        Stop-Transcript | Out-Null
        exit -1
    }
}

function Configure-ChromeExtension {
    Param(
        [Parameter()][String] $UPN,
        [Parameter()][String] $API_Key,
        [Parameter()][String] $Company_ID
    )
    if ($company_api_key -eq "changeme") {
        Write-Error "You must set the company API key to be able to run this script" -Category OperationStopped
        Stop-Transcript | Out-Null
        exit -1
    } elseif ($company_id -eq "changeme") {
        Write-Error "You must set the company API key to be able to run this script" -Category OperationStopped
        Stop-Transcript | Out-Null
        exit -1
    }

    $registry_path_chrome = "HKLM:\SOFTWARE\Policies\Google\Chrome\3rdparty\extensions\$extension_identifier\policy"
    $parent_path_chrome = Split-Path -Path $registry_path_chrome

    # Create Chrome policy path for Harmonic Security browser extension if it does not exist
    if (!(Test-Path $parent_path_chrome)) {
        New-Item -Path $parent_path_chrome -Force -ItemType Directory | Out-Null
    }

    if (!(Test-Path $parent_path_chrome\policy)) {
        New-Item -Path ("$parent_path_chrome\policy") -Force -ItemType Directory | Out-Null
    }

    # Set the Registry keys
    try {
        Write-Host "Attempting to set companyApiKey for Google Chrome..."
        Set-ItemProperty -Path $registry_path_chrome -Name "companyApiKey" -Value $API_Key -ErrorAction Stop
        Write-Host "Attempting to set companyId for Google Chrome..."
        Set-ItemProperty -Path $registry_path_chrome -Name "companyId" -Value $Company_ID -ErrorAction Stop
        Write-Host "Attempting to set userEmail for Google Chrome..."
        Set-ItemProperty -Path $registry_path_chrome -Name "userEmail" -Value $UPN -ErrorAction Stop
        Write-Host "Attempting to set companyRegion for Google Chrome..."
        Set-ItemProperty -Path $registry_path_chrome -Name "companyRegion" -Value "eu" -ErrorAction Stop

        if ($?) {
            Write-Host "Harmonic Security extension configured successfully for Chrome!"
        }
    } catch {
        Write-Error -Message "Failed to set registry value: $_" -Category OperationStopped
        $errorDetails = $_.Exception
        Write-Error -Message "Error details: $errorDetails" -Category OperationStopped
        exit -1
    }
}

function Configure-EdgeExtension {
    Param(
        [Parameter()][String] $UPN,
        [Parameter()][String] $API_Key,
        [Parameter()][String] $Company_ID
    )
    if ($company_api_key -eq "changeme") {
        Write-Error "You must set the company API key to be able to run this script" -Category OperationStopped
        Stop-Transcript | Out-Null
        exit -1
    } elseif ($company_id -eq "changeme") {
        Write-Error "You must set the company API key to be able to run this script" -Category OperationStopped
        Stop-Transcript | Out-Null
        exit -1
    }

    $registry_path_edge = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\3rdparty\extensions\$extension_identifier\policy"
    $parent_path_edge = Split-Path -Path $registry_path_edge

    # Create Edge policy path for Harmonic Security browser extension if it does not exist
    if (!(Test-Path $parent_path_edge)) {
        New-Item -Path $parent_path_edge -Force -ItemType Directory | Out-Null
    }

    if (!(Test-Path $parent_path_edge\policy)) {
        New-Item -Path ("$parent_path_edge\policy") -Force -ItemType Directory | Out-Null
    }

    # Set the Registry keys
    try {
        Write-Host "Attempting to set companyApiKey for Edge..."
        Set-ItemProperty -Path $registry_path_edge -Name "companyApiKey" -Value $API_Key -ErrorAction Stop
        Write-Host "Attempting to set companyId for Edge..."
        Set-ItemProperty -Path $registry_path_edge -Name "companyId" -Value $Company_ID -ErrorAction Stop
        Write-Host "Attempting to set userEmail for Edge..."
        Set-ItemProperty -Path $registry_path_edge -Name "userEmail" -Value $UPN -ErrorAction Stop
        Write-Host "Attempting to set companyRegion for Edge..."
        Set-ItemProperty -Path $registry_path_edge -Name "companyRegion" -Value "eu" -ErrorAction Stop

        if ($?) {
            Write-Host "Harmonic Security extension configured successfully for Edge!"
        }
    } catch {
        Write-Error -Message "Failed to set registry value: $_" -Category OperationStopped
        $errorDetails = $_.Exception
        Write-Error -Message "Error details: $errorDetails" -Category OperationStopped
        Stop-Transcript | Out-Null
        exit -1
    }
}


$upnFileLocation = "C:\ProgramData\Harmonic Security\UPN.txt"
$UPN = Get-Content $upnFileLocation

if (-not($UPN -eq $null)) {
    Configure-ChromeExtension -UPN $UPN -API_Key $company_api_key -Company_ID $company_id
    Configure-EdgeExtension -UPN $UPN -API_Key $company_api_key -Company_ID $company_id
    Configure-FirefoxExtension -UPN $UPN -API_Key $company_api_key -Company_ID $company_id
    Configre-IslandExtension -UPN $UPN -API_Key $company_api_key -Company_ID $company_id
    Stop-Transcript | Out-Null
    exit 0
} else {
    Write-Error -Message "No UserPrincipalName found in UPN.txt" -Category OperationStopped
    Stop-Transcript | Out-Null
    exit 1
}

Stop-Transcript | Out-Null
exit 0
'@ > $scriptLocation

        $taskAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-executionpolicy bypass -file ""$scriptLocation"""
        $taskTrigger = New-ScheduledTaskTrigger -AtLogOn
        $tastSettingsSet = New-ScheduledTaskSettingsSet
        $taskUser = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -RunLevel Highest
        
        Register-ScheduledTask -TaskName $taskName -TaskPath "\" -Action $taskAction -Settings $tastSettingsSet -Trigger $taskTrigger -Principal $taskUser

        Start-ScheduledTask -TaskName $taskName
    } catch {
        Write-Output "Error creating $taskName"
    }
}

# Finally, add a version number in case the scripts need to be changed
$versionFileLocation = "C:\ProgramData\Harmonic Security\DeploymentScriptVersion.txt"
@'
2.0
'@ > $versionFileLocation