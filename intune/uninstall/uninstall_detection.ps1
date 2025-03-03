<#
    HARMONIC SECURITY EXTENSION UNINSTALL - DETECTION SCRIPT

.DESCRIPTION
    Checks for the presence of the required scheduled tasks,
    PowerShell script, or UPN text file. If any of these are
    found, run the remediation.
#>
# User-space task to get the user's UPN every login
$userTaskName = "HarmonicSecurityExtension-IdentifyUser";
$userTaskStatus = Get-ScheduledTask | Where-Object { $_.taskName -eq $userTaskName }

# SYSTEM task to update the registry
$systemTaskName = "HarmonicSecurityExtension-ConfigureRegistry";
$systemTaskStatus = Get-ScheduledTask | Where-Object { $_.taskName -eq $systemTaskName }

# UPN file location
$upnFileLocation = "C:\ProgramData\Harmonic Security\UPN.txt"

# PowerShell script location
$scriptLocation = "C:\ProgramData\Harmonic Security\ConfigureRegistry.ps1"

if ($userTaskStatus) {
    Write-Output "User task present. Remediation required"
    Exit 1
}

if ($systemTaskStatus) {
    Write-Output "System task present. Remediation required"
    Exit 1
}

if (Test-Path $upnFileLocation) {
    Write-Output "UPN file present. Remediation required"
    Exit 1
}

if (Test-Path $scriptLocation) {
    Write-Output "Script present. Remediation required"
    Exit 1
}

function Check-ExtensionConfiguration {
    Param(
        [Parameter()][String] $configurationPath
    )

    if (Test-Path $configurationPath) {
        Write-Output "Extension configuration present. Remediation required"
        Exit 1
    }
}

Check-ExtensionConfiguration("HKLM:\SOFTWARE\Policies\Google\Chrome\3rdparty\extensions\nmgdkbiadhkdekcolccalbcmnmgjeioa")
Check-ExtensionConfiguration("HKLM:\SOFTWARE\Policies\Mozilla\Firefox\3rdparty\Extensions\firefox-extension@harmonic.security")
Check-ExtensionConfiguration("HKLM:\SOFTWARE\Policies\Microsoft\Edge\3rdparty\extensions\nmgdkbiadhkdekcolccalbcmnmgjeioa")

Exit 0