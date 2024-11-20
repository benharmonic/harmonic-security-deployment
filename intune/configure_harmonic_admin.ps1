<#
    .SYNOPSIS
        This script must be run as administrator.

        It collects the user's UserPrincipalName from the file in the %TEMP% directory
        and configures Harmonic extensions by inserting it and other values into the 
        Registry.
    .NOTES
        AUTHOR:     ben.smith@harmonic.security
        LASTEDIT:   2024-11-20
#>

# Set up logging
$NOW = Get-Date -Format "yyyyMMdd-hhmmss"
$LogPath = "$ENV:TEMP\HarmonicSecurity-AdminScript-$NOW.log"

# Make sure these values are correct
$company_api_key = "changeme"
$company_id = "changeme"
$extension_identifier = "nmgdkbiadhkdekcolccalbcmnmgjeioa" 

# Set up temporary file
$tempFilePath = "$ENV:TEMP\HarmonicSecurity-UPN.txt"

Start-Transcript -path $LogPath | Out-Null

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

$timeout = 15
$endTime = (Get-Date).AddMinutes($timeout)

while (-not (Test-Path $tempFilePath) -and (Get-Date) -lt $endTime) {
    Start-Sleep -Seconds 10
}

if (-not (Test-Path $tempFilePath)) {
    Write-Error -Message "Error configuring Harmonic Security extension - temporary UPN file not found. Contact your Harmonic Security representative for assistance" -Category OperationStopped
    Stop-Transcript | Out-Null
    exit -1
} else {
    Write-Host "Temporary UPN file found..."
    $UPN = Get-Content $tempFilePath

    Configure-ChromeExtension -UPN $UPN -API_Key $company_api_key -Company_ID $company_id
    Configure-EdgeExtension -UPN $UPN -API_Key $company_api_key -Company_ID $company_id
    Configure-FirefoxExtension -UPN $UPN -API_Key $company_api_key -Company_ID $company_id
}

Stop-Transcript | Out-Null
exit 0