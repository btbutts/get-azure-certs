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
  1. Ensure you've installed PowerShell 7.X.X or newer. I've tested this script on PowerShell 7.5.0 and 7.5.1 on MacOS and Windows
  2. If you're executing on Windows, you will need OpenSSL binaries to run this script
  3. Once the script obtains the certificates from Microsoft, it will convert them using OpenSSL and place them on your system's desktop.

### OpenSSL on Windows (Skip if executing on MacOS or Linux)
Unfortunately, Microsoft does not package OpenSSL with Windows. The script will attempt to download and install the OpenSSL binaries for you.
* The script will identify x86, x86-64, and ARM64 systems and download the respective OpenSSL binaries installer MSI
* If you have already installed OpenSSL on your system, the script will attempt to locate openssl.exe from the respective Program Files directory, depending on your system architecture.
* You can modify the value of $OpenSSLpath within the script such that it uses your existing openssl binary.

## Disclaimer!
This script is provided completely as-is without any express or implied warranty. I am not responsible if the certificates obtained through this script stop working. That's expected and is the entire reason this script has been written. If installing PowerShell 7 or OpenSSL breaks your system in some unforseen way, I am not responsible. That is entirely on you to address. If you break your system after running this script, that is also entirely your responsibility and fault to remedy at your own expense. Really though, if you manage to break your system using this script, then you probably have no business managing IT, and definately not security products! 🙄





...Anyways, that's it. Buy me a coffee! ☕️

# Credits
1. This script uses software developed by the [OpenSSL Project](https://openssl-library.org/) for use in the OpenSSL Toolkit\
   &emsp;&emsp;It is distributed with an [Apache v2.0 License](https://opensource.org/license/apache-2-0)\
   &emsp;&emsp;See: https://openssl-library.org/
2. The OpenSSL installer used in this script has been packaged by [Shining Light Productions](https://slproweb.com/index.html) independently of the OpenSSL Project, using their source code\
   &emsp;&emsp;Although their software is free to use, show your appreciation by making a donation to them to reward them for their work\
   &emsp;&emsp;There's a link at the bottom of their OpenSSL Product Page to make a one time or reoccurring donation to show your support!\
   &emsp;&emsp;See: https://slproweb.com/products/Win32OpenSSL.html
