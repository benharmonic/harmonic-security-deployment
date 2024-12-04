# Configure Harmonic extension(s) via Intune Remediation Scripts
You can use these scripts to ensure that the Harmonic extension is configured via Intune's Remediation Scripts.

> [!IMPORTANT]
> You must have deployed the Harmonic extension(s) for them to appear in the browser. These scripts will only configure the extensions by setting the appropriate values in the Windows Registry and will not add the extensions to browsers.

## How do these scripts work?
There are two scheduled tasks that get configured:
1. A task that runs on demand as the logged-in user and pipes the output of `whoami.exe /upn` to a text file at `C:\ProgramData\Harmonic Security\UPN.txt`
2. A task that runs on login as `SYSTEM` that runs the user-space task, waits for it to complete, then adds the relevant pieces of configuration data to the registry via a PowerShell script

Intune's Remediation Scripts automatically configure the tasks if they do not exist, as well as creating the UPN text file (with the correct permissions) and the PowerShell script.

For security reasons, the PowerShell script run by the `SYSTEM` task is locked down by ACLs and cannot be edited or executed by non-administrators. Its default location is `C:\ProgramData\Harmonic Security\ConfigureRegistry.ps1`.

## How do I configure these scripts?
> [!WARNING]
> Ensure that you edit lines 44 and 45 of `remediation.ps1` to include the correct API key and customer ID for your Harmonic tenant. If you do not do this, the script will not work.

Create a new Remediation Script in Intune.

* Use the `detection.ps1` script as the Detection Script.
* Use the `remediation.ps1` script as the Remediation Script.

Use the following settings:
* Run this script using the logged-on credentials: No
* Enforce script signature check: No
* Run script in 64-bit PowerShell: No

You should now be able to select a device in Intune and manually run the remediation. This will create and run the scheduled tasks, and configure the Harmonic extension(s) for the active user.