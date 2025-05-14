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
  2. PowerShell 5.0 and 5.1 will not work. Microsoft has completed a lot of work to update PowerShell to compete with bash, zsh, Python scripting, etc...\
     Those changes were introduced in PowerShell 6 and 7. I've no idea if PowerShell 6 will work as I've not tested it. Just update to 7.5.X. They've made vast improvements to it!\
     **Why won't PowerShell 5.0/5.1 work?** Unfortunately, it is unable to process portions of the script correctly. That's it!\
     Microsoft has chosen not to package the latest PowerShell versions with Windows as its not needed for most end users running Windows.
     If your an IT admin or someone at all technically-inclined running PowerShell, you seriously ***should*** be running 7.X.X by now...
  4. If you're executing on Windows, you will need OpenSSL binaries to run this script
  5. Once the script obtains the certificates from Microsoft, it will convert them using OpenSSL and place them on your system's desktop.

### OpenSSL on Windows (Skip if executing on MacOS or Linux)
Unfortunately, Microsoft does not package OpenSSL with Windows. The script will attempt to download and install the OpenSSL binaries for you.
* The script will identify x86, x86-64, and ARM64 systems and download the respective OpenSSL binaries installer MSI
* If you have already installed OpenSSL on your system, the script will attempt to locate openssl.exe from the respective Program Files directory, depending on your system architecture.
* You can modify the value of $OpenSSLpath within the script such that it uses your existing openssl binary.

### PowerShell on MacOS
The best way to install PowerShell on MacOS is with Homebrew
* Microsoft explains the process [here](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos?view=powershell-7.5#install-the-latest-stable-release-of-powershell), but there's not much to it.\
  1. Run `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` from a terminal
  2. Then run `brew install --cask powershell`
  3. Finally, run `pwsh` to enter the PowerShell session on MacOS.\
     You may need to open a new terminal Window for the command to be recognized as your session's $PATH will not have been updated during the install

### PowerShell on Linux
There's a couple different processes to follow depending on your flavor of Linux\
See Microsoft's [Install PowerShell on Linux](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux) documentation

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
