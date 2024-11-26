<#
.DESCRIPTION
    Checks for the presence of the required scheduled tasks,
    PowerShell script, or UPN text file. If any of these are
    not found, run the remediation.
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

if (-not($userTaskStatus)) {
    Write-Output "Not all required items are present. Remediation required"
    Exit 1
}

if (-not($systemTaskStatus)) {
    Write-Output "Not all required items are present. Remediation required"
    Exit 1
}

if (-not(Test-Path $upnFileLocation)) {
    Write-Output "Not all required items are present. Remediation required"
    Exit 1
}

if (-not(Test-Path $scriptLocation)) {
    Write-Output "Not all required items are present. Remediation required"
    Exit 1
}

Write-Output "All required items are present. No action required"
Exit 0