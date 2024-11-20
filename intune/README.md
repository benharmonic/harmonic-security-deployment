# Microsoft Intune Deployment Resources

> ⚠️ Make sure you edit scripts to include all applicable API keys and customer IDs.

This repository contains scripts and other resources required to support the deployment of the Harmonic Security browser extension via Microsoft Intune.

The browser extension requires configuration to be placed in the Windows Registry. Because of this, there are two scripts that need to run on end-user devices.

## User Script
The user script runs as the logged-in user, and collects the required configuration data - the user's UserPrincipalName - and places it in a text file in `C:/ProgramData/Harmonic Security`.

## Administrator Script
The administrator script runs as an administrator, and waits for the temporary text file to become available. Once it is, it reads the content of that file into the Registry. The content of the file is checked to ensure it is a valid email address before being read into the Registry.
