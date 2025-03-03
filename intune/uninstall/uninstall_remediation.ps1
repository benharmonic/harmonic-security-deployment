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
    Unregister-ScheduledTask -TaskName $userTaskName -Confirm:$false
}

if ($systemTaskStatus) {
    Unregister-ScheduledTask -TaskName $systemTaskName -Confirm:$false
}

if (Test-Path $upnFileLocation) {
    Remove-Item -Path $upnFileLocation -Force
}

if (Test-Path $scriptLocation) {
    Remove-Item -Path $scriptLocation -Force
}

function Remove-ExtensionConfiguration {
    Param(
        [Parameter()][String] $configurationPath
    )

    if (Test-Path $configurationPath) {
        Remove-Item -Path $registryPath -Recurse -Force
    }
}

Remove-ExtensionConfiguration("HKLM:\SOFTWARE\Policies\Google\Chrome\3rdparty\extensions\nmgdkbiadhkdekcolccalbcmnmgjeioa")
Remove-ExtensionConfiguration("HKLM:\SOFTWARE\Policies\Mozilla\Firefox\3rdparty\Extensions\firefox-extension@harmonic.security")
Remove-ExtensionConfiguration("HKLM:\SOFTWARE\Policies\Microsoft\Edge\3rdparty\extensions\nmgdkbiadhkdekcolccalbcmnmgjeioa")