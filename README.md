# get-azure-certs
**A simple PowerShell script that obtains Microsoft's current public keys used globally for OIDC authentication**
* The script converts each retreived certificate to the correct x509 PEM format required for most Entra ID (formerly known as Azure) OIDC configurations
* The script may be executed on Windows, MacOS, or Linux
* The script will obtain the certificates directly from Microsoft located [here](https://login.microsoftonline.com/common/discovery/keys)

## Why is this necessary?
* Microsoft frequenty rolls their public keys used for OIDC authentication
* Unfortunately, not all SP (Service Providers) that support Entra ID (formerly known as Azure) OIDC authentication will either automatically, or even quickly enough, update the public keys in their systems to successfully support OIDC authentication via Entra, leading to authentication failure
* Currently, it is up to the user to manually download each of the certs (there can be 4 to 7 of them, depending on your tenant), convert each one of them, and then test them with your OIDC configuration
* This script addresses all but the last step, actually trying the converted certificate in your OIDC config

## How do I use this script?
* There's not a lot of prerequisites to use this PowerShell script. 


can be executed on Windows, MacOS, or Linux to obtain Microsoft's Public Certificates and convert them for use with Azure (Entra ID) OIDC Authenticaiton Setups


A simple PowerShell script that can be executed on Windows, MacOS, or Linux to 
obtain Microsoft's Public Certificates and convert them for use with Azure (Entra ID) OIDC Authenticaiton Setups

