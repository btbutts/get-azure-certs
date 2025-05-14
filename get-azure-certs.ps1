# Windows Users Only, you can add the full path to openssl.exe on your system
# to skip checking for, and/or installing OpenSSL on your system. Enter the full
# path within the quotes after $OpenSSLpath in the 'param' declarative below
param (
    [string]$OpenSSLpath = "" 
)
# Yes No Prompt Function
function SelectYesNo {
    param (
        [string]$QueryUser,
        [string]$ContinueMsg,
        [string]$ExitMsg,
        [string]$ExitScript
    )
    $proceedQA = Read-Host "$QueryUser (y/n)`nChoosing No will exit the script!`n"
    while ($proceedQA -notmatch "^[yn]$") {
        Write-Host "Invalid input detected. Please enter 'y' or 'n'."
        $proceedQA = Read-Host "Would you like to Continue? (y/n)"
    }
    if ($proceedQA -eq "y") {
        # Code to execute if the answer is yes
        if ($ContinueMsg) {
            Write-Host $ContinueMsg
        } else {
            Write-Host "Continuing..."
        }
        return $true
    } else {
        # Code to execute if the answer is no
        #exit
        if ($ExitMsg) {
            Write-Host $ExitMsg
        } else {
            Write-Host "Exiting..."
        }
        return $false
        if ($ExitScript -eq $true) {
            exit 1
        }
    }
}
# Check Webpage
function Test-HTMLpage {
    param(
        [string]$URL
    )
    try {
        $request = Invoke-WebRequest -Uri $URL -Method Head -ErrorAction Stop
        if ($request.StatusCode -eq 200) {
            return $true
        } else {
            return $false
        }
    } catch {
        return $false
    }
}
# Select first active path, else fail
function CheckOpenSSLurl {
    if (Test-HTMLpage -URL "https://raw.githubusercontent.com/slproweb/opensslhashes/refs/heads/master/win32_openssl_hashes.json") {
        # Get the msi installer
        Write-Output "Will obtain OpenSSL Windows Installer from primary source"
        $script:OpenSSLSources = "https://raw.githubusercontent.com/slproweb/opensslhashes/refs/heads/master/win32_openssl_hashes.json"
    } elseif (Test-HTMLpage -URL "https://raw.githubusercontent.com/slproweb/opensslhashes/master/win32_openssl_hashes.json") {
        Write-Output "Will obtain OpenSSL Windows Installer from backup source"
        $script:OpenSSLSources = "https://raw.githubusercontent.com/slproweb/opensslhashes/master/win32_openssl_hashes.json"
    } else {
        Write-Error "Could not retrieve OpenSSL Windows Installer from any known source"
        Write-Output "Please try to download and install OpenSSL from the following URL to continue with this script:"
        Write-Output "https://slproweb.com/products/Win32OpenSSL.html"
        Throw "Execution Failed"
        exit 1
    }
}
# Function to Identify OS and set script variables
function SetSysArchVariables {
    $SysArch = (Get-CimInstance Win32_operatingsystem).OSArchitecture
    if ($SysArch -eq "ARM 64-bit Processor") {
        Write-Output "System is Windows on ARM64 OS. Retrieving required OpenSSL installer."
        $script:RegexMatch = "Win64A[A-Za-z]+_Light-([A-Za-z0-9]+(_[A-Za-z0-9]+)+)\.msi"
        #DownloadOpenSSL -Sources $OpenSSLSources -FileMatch $RegexMatch
        $script:OpenSSLpath = "C:\Program Files\OpenSSL-Win64-ARM\bin\openssl.exe"
    } elseif ($SysArch = "64-bit") {
        Write-Output "System is Windows 64-bit OS. Retrieving required OpenSSL installer."
        $script:RegexMatch = "Win64O[A-Za-z]+_Light-([A-Za-z0-9]+(_[A-Za-z0-9]+)+)\.msi"
        #DownloadOpenSSL -Sources $OpenSSLSources -FileMatch $RegexMatch
        $script:OpenSSLpath = "C:\Program Files\OpenSSL-Win64\bin\openssl.exe"
    } elseif ($SysArch = "32-bit") {
        Write-Output "System is Windows 32-bit OS. Retrieving required OpenSSL installer."
        $script:RegexMatch = "Win32O[A-Za-z]+_Light-([A-Za-z0-9]+(_[A-Za-z0-9]+)+)\.msi"
        #DownloadOpenSSL -Sources $OpenSSLSources -FileMatch $RegexMatch
        $script:OpenSSLpath = "C:\Program Files (x86)\OpenSSL-Win32\bin\openssl.exe"
    } else {
        Write-Error "Could not identify this Windows system's architecture!`nPlease download the respective OpenSSL installer for your system from:`nhttps://slproweb.com/products/Win32OpenSSL.html"
        exit 1
    }
}
# Function to identify newest OpenSSL installer
function DownloadOpenSSL {
    param (
        [string]$FileMatch,
        [string]$Sources
    )
    $OpenSSLSources = $Sources
    $responseJSON = (Invoke-WebRequest -Uri $OpenSSLSources).Content | ConvertFrom-Json
    $OpenSSLInstallers = $responseJSON.files
    $script:SelectInstallFile = ($OpenSSLInstallers.psobject.Members.Name | Select-String -Pattern $FileMatch | Sort-Object -Descending)[0].ToString()
    $script:DownloadPath = "$env:USERPROFILE\Downloads\$SelectInstallFile"
    $DownloadURL = $responseJSON.psobject.Properties.Value.$SelectInstallFile.url
    if (Test-Path $DownloadPath) {
        if (($responseJSON.psobject.Properties.Value.$SelectInstallFile.sha256) -ne ((Get-FileHash -Algorithm SHA256 $DownloadPath).Hash)) {
            Write-Output "`nOpenSSL installer already exists on this system but file verification failed!`n...Redownloading the OpenSSL installer!"
            (New-Object Net.WebClient).DownloadFile($DownloadURL, $DownloadPath)
        } else {
            Write-Output "Found and verified existing OpenSSL installer in User: $env:USERNAME`'s Download directory! No need to download again."
        }
    } elseif (!(Test-Path $DownloadPath)) { 
        (New-Object Net.WebClient).DownloadFile($DownloadURL, $DownloadPath)
        if (($responseJSON.psobject.Properties.Value.$SelectInstallFile.sha256) -eq ((Get-FileHash -Algorithm SHA256 $DownloadPath).Hash)) {
            Write-Output "Successfully downloaded the OpenSSL installer!"
        }
    } else {
        Write-Output "File already downloaded. No need to download again."
    }
}
# Determine OS and System Architecture to set PATH
if (($IsWindows -or (Test-Path "C:\Windows\")) -and (!(Test-Path $OpenSSLpath))) {
    $InstalledApps = Get-WmiObject -class win32_Product
    if (!($InstalledApps.Name | Where-Object { $_ -like "OpenSSL Light*" })) {
        # Define Variables
        $DownloadPath = ""
        $SelectInstallFile = ""
        $OpenSSLSources = ""
        $RegexMatch = ""
        #$responseJSON = ""
        #$DownloadURL = ""
        # Prompt user about OpenSSL requirement
        $QueryUser = "This script requires OpenSSL binaries to function on Windows systems, which are not included by Microsoft.`
        `b`b`b`b`b`b`b`bWill now attempt to download the newest OpenSSL binaries from Shining Light Productions.`
        `b`b`b`b`b`b`b`bWould you like to continue?"
        $ContinueMsg = "Detected affirmative response so continuing..."
        $ExitMsg = "You`'ve chosen to exit but OpenSSL binaries were not found on this system! Script will now exit."
        $UserContinue = SelectYesNo -QueryUser $QueryUser -ContinueMsg $ContinueMsg -ExitMsg $ExitMsg -ExitScript $true
        if ($UserContinue -eq $true) {
            CheckOpenSSLurl
        } elseif ($UserContinue -eq $false) {
            Write-Output "User selected no so we`'re exiting the script..."
            exit 1
        }
        SetSysArchVariables
        DownloadOpenSSL -Sources $OpenSSLSources -FileMatch $RegexMatch
        $QueryUser = "The script will now install the OpenSSL Binary. You may need to accept a UAC (User Account Control) prompt to continue.`
        `b`b`b`b`b`b`b`bPlease enter yes 'y' to continue."
        $ContinueMsg = "Installing OpenSSL from $DownloadPath to local system!"
        $ExitMsg = "User selected no so we`'re exiting the script..."
        $UserContinue = SelectYesNo -QueryUser $QueryUser -ContinueMsg $ContinueMsg -ExitMsg $ExitMsg -ExitScript $true
        if ($UserContinue -eq $true) {
            Start-Process msiexec.exe -Verb RunAs -ArgumentList "/I $DownloadPath /qb" -Wait
            if ($? -eq $true) {
                Write-Output "OpenSSL binaries Installed"
            } else {
                Write-Output "OpenSSL Installation Failed!"
                exit 1
            }
        }
    } else {
        SetSysArchVariables
        Write-Output "Found existing OpenSSL Light installation. This script will use the following executable for certificate conversions:"
        Write-Output $OpenSSLpath
    }
} else {
    Write-Output "Skipping OpenSSL installer verification and installation because`
    `b`b`b`buser has supplied existing binary located at:`
    `b`b`b`b$OpenSSLpath"
}

# Final OpenSSL Check
if (($IsWindows -or (Test-Path C:\Windows)) -and (Test-Path $OpenSSLpath)) {
    Write-Output "Found OpenSSL installed on this system. Continuing..."
} elseif ($IsMacOS -or $IsLinux) {
    Write-Host "OpenSSL already exists on this system. Will continue with script generation!"
} else {
    Write-Host "Could not find OpenSSL installed on this Windows system. Script will now exit!"
    exit 1
}
# Set PowerShell alias for openssl
if ((($IsWindows -or (Test-Path C:\Windows)) -or (Test-Path C:\Windows)) -and !(Get-Alias -Name openssl -ErrorAction SilentlyContinue)) {
    #Set-Alias -Name openssl -Value "C:\Program Files\OpenSSL-Win64\bin\openssl.exe"
    Set-Alias -Name openssl -Value $OpenSSLpath
}
# Create directory for saved certs
if ($IsMacOS -or $IsLinux) {
    $CertDir = "$env:HOME/Desktop/EntraCerts"
    if (!(Test-Path $env:HOME/Desktop/EntraCerts)) { New-Item -ItemType Directory -Path $CertDir } 
} elseif ($IsWindows -or (Test-Path C:\Windows)) {
    $CertDir = "$env:USERPROFILE\Desktop\EntraCerts"
    if (!(Test-Path $env:USERPROFILE\Desktop\EntraCerts)) { New-Item -ItemType Directory -Path $CertDir }
}
# This function adds a line break every 64 characters to any string passed to it
# Use syntax: LineBreakRSA -SourceVar $VariableName
function LineBreakRSA {

    param (
        [string]$SourceVar
    )
    #$SourceVarLength = $SourceVar.Length
    $i = 0
    while ($i -lt $SourceVar.Length) {
        $Block64out += $SourceVar.Substring($i, [System.Math]::Min(64, $SourceVar.Length - $i)) + "`n"
        $i += 64
    }
    $Block64out.TrimEnd("`n`n")
}
#Retreive Entra (AzureAD) Public Certs and place in array
$response = Invoke-WebRequest -Uri "https://login.microsoftonline.com/common/discovery/keys"
$EntraPKIjsonSource = $response.Content
$EntraPKIjsonData = $EntraPKIjsonSource | Out-String | ConvertFrom-Json
$Entrax5cArray = $EntraPKIjsonData.keys | Select-Object "x5c"
#Begin formatting the certs array
$EntraPKIblock = @()
for ($i = 0; $i -lt $Entrax5cArray.Count; $i++) {
    $EntraPKIblock += LineBreakRSA -SourceVar $Entrax5cArray.x5c[$i]
    $EntraPKIblock[$i] = "-----BEGIN CERTIFICATE-----`n" + $EntraPKIblock[$i] + "`n-----END CERTIFICATE-----"
    $EntraPKIblock[$i] | Out-File -FilePath "$CertDir/EntraPubKey_original_$i.pem"
    if ($IsMacOS) {
        zsh -c "openssl x509 -pubkey -noout -in $CertDir/EntraPubKey_original_$i.pem > $CertDir/EntraRSA_PubKey_$i.pem"
    } elseif ($IsLinux) {
        bash -c "openssl x509 -pubkey -noout -in $CertDir/EntraPubKey_original_$i.pem > $CertDir/EntraRSA_PubKey_$i.pem"
    } elseif ($IsWindows -or (Test-Path C:\Windows)) {
        openssl x509 -pubkey -noout -in "$CertDir\EntraPubKey_original_$i.pem" > "$CertDir\EntraRSA_PubKey_$i.pem"
    }
}
$QueryUser = "Entra certificates retrieved and converted. See .\Desktop\EntraCerts for the pem files: $([char]27)[1mEntraRSA_PubKey_X.pem$([char]27)[0m`
Would you like to display their contents on screen?" 
$UserContinue = SelectYesNo -QueryUser $QueryUser -ContinueMsg "Displaying converted certificates...`n"
if ($UserContinue -eq $false) {
    exit 1
} else {
    for ($i = 0; $i -lt $Entrax5cArray.Count; $i++) {
        Write-Output "Contents of: $([char]27)[1mEntraRSA_PubKey_$i.pem$([char]27)[0m`n"
        Get-Content -Path "$CertDir/EntraRSA_PubKey_$i.pem"
        Write-Output "`n`n"
    }
}
#EOF
exit
