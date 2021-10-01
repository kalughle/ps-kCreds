function Set-kCred {
    <#
    .SYNOPSIS
    Creates a new credential file containing the sername and password provided encrypted with the current users token, then sends the output to a file.

    .DESCRIPTION
    Creates a new credential containing the encrypted username and password provided, then sends the output to a file or the pipeline.

    .PARAMETER Username
    Provide the case sensitive username you would like to use for this credential.

    .PARAMETER Password
    Provide the password you wish to use for this credntial.

    .PARAMETER FilePath
    Provide the file path you wish to store this credential to.

    .PARAMETER Delimiter
    The character to be used to seperate the username and password in the credential. May not be a character contained in the Username or Password

    .INPUTS
    None. You cannot pipe objects to Set-kCred.

    .OUTPUTS
    System.String
        A string value of the credential file path is output

    .EXAMPLE
    PS> Set-kCred -Username "User01" -Password "AFanta$ticPa$$w0rd" -FilePath $env:USERPROFILE/.kcreds/myCredential.kcred

    .LINK
    https://github.com/kalughle/ps-kcreds
    #>

    param (
        [Parameter(Mandatory=$true,HelpMessage="Provide the case sensitive username you would like to use for this credential.")]
        [string]$Username,

        [Parameter(Mandatory=$true,HelpMessage="Provide the password you wish to use for this credntial.")]
        [string]$Password,

        [Parameter(Mandatory=$true,HelpMessage="Provide the file path you wish to store this credential to.")]
        [string]$FilePath,

        [Parameter(HelpMessage="Provide a single character to use as the delimiter")]
        [ValidateLength(1,1)]
        [string]$Delimiter = ':'
    )

    # Check to make sure the Username or Password does not contain the delimiter
    if ($Username -like "*$Delimiter*" -or $Password -like "*$Delimiter*") {
        Write-Error "Username or Password contains the delimiter character ($Delimiter). Please select a different delimiter."
    }

    # Replace any forward slashes with back slashes
    $cleanPath = $FilePath.Replace("/", "\")

    # Verify that the directory provided exists, and create it if not
    verifyDirectory -pathToFile $cleanPath -create | Out-Null

    # Verify that the file provided exists, and create it if not
    $kCredsFileOk = verifyFile -pathToFile $cleanPath -create

    # Join the username and password in to one string using the selected delimiter
    # Prepend the string with the delimiter used to allow the read function to separate them
    $joinedCred = $Delimiter + $Username + $Delimiter + $Password

    # Convert the combined string in to a SecureString
    $secureCred = ConvertTo-SecureString -String $joinedCred -AsPlainText -Force

    # Create a credential object using the whole SecureString as the password. This encrypts the
    # string using the current user's token
    $credObject = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'empty', $secureCred

    # Convert the now encrypted password back to a standard string and store it in the designated file
    $credObject.Password | ConvertFrom-SecureString | Out-File $kCredsFileOk

    # Write the path of the creds file to the pipeline
    Write-Output $kCredsFileOk
}

function Read-kCred {
    <#
    .SYNOPSIS
    Reads the credential from the file provided using the current users token.

    .DESCRIPTION
    Reads the credential from the file provided using the current users token.

    .PARAMETER FilePath
    Provide the file path you wish to read this credential from.

    .PARAMETER UsernameOnly
    Output only the username of the credential in System.String format

    .PARAMETER PasswordOnly
    Output only the password of the credential in System.Security.SecureString format

    .PARAMETER PasswordAsString
    In all cases, converts the System.Security.SecureString format of the password to System.String

    .INPUTS
    None. You cannot pipe objects to Read-kCred.

    .OUTPUTS
    System.Management.Automation.PSCustomObject
        By default, outputs a custom object containing the username and password

    System.Security.SecureString
        By default, the password is output as a secure string. If PasswordOnly is selected, only the secure string is output

    System.String
        If UsernameOnly, or PasswordOnly with the PasswordAsString are selected the function outputs a string.

    .EXAMPLE
    Read-kCred -FilePath $env:USERPROFILE/.kcreds/myCredential.kcred
    Returns a PSCustomObject with 2 properties. Username as a String, and Password as a SecureString

    Username                     Password
    --------                     --------
    User01   System.Security.SecureString

    .EXAMPLE
    Read-kCred -FilePath $env:USERPROFILE/.kcreds/myCredential.kcred -PasswordAsString
    Return a PSCustomObject with 2 properties. Username as a String, and Password as a String

    Username           Password
    --------           --------
    User01   AFanta$ticPa$$w0rd

    .EXAMPLE
    Read-kCred -FilePath $env:USERPROFILE/.kcreds/myCredential.kcred -PasswordOnly
    Returns a System.Security.SecureString object containing the password only

    System.Security.SecureString

    .EXAMPLE
    Read-kCred -FilePath $env:USERPROFILE/.kcreds/myCredential.kcred -PasswordOnly -PasswordAsString
    Return a System.String object containing the password only

    AFanta$ticPa$$w0rd

    .EXAMPLE
    Read-kCred -FilePath $env:USERPROFILE/.kcreds/myCredential.kcred -UsernameOnly
    Return a System.String object containing the username only

    User01

    .LINK
    https://github.com/kalughle/ps-kcreds
    #>

    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]$FilePath,

        [switch]$UsernameOnly,

        [switch]$PasswordOnly,

        [switch]$PasswordAsString
    )

    PROCESS {
        # Replace any forward slashes with back slashes
        $cleanPath = $FilePath.Replace("/", "\")

        # Pull the string out of the file and convert it to a secure string using the local users credential
        try {
            $secureCred = Get-Content $cleanPath | ConvertTo-SecureString -ErrorAction Stop
        }
        catch [System.Security.Cryptography.CryptographicException] {
            if ($PSItem.Exception.Message.Trim() -eq "Key not valid for use in specified state.") {
                Write-Warning "Invalid user credential!! This user is not authoried to access this file."
                return
            }
            Write-Host "An Unknown Cryptographic error has occured"
            Write-Error $PSItem
            return
        }
        catch {
            Write-Host "An Unknown error has occured"
            $PSItem | Write-Output
            return
        }

        # Using the current users token, create a credential object using the secure string provided
        $credObject = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'empty', $secureCred

        # The first character of the string is the delimiter, so extract that
        $delimiter  = $credObject.GetNetworkCredential().password.Substring(0,1)

        # Using the local users credentials, extract the password from the credential object and provide it to the pipeline in the format requested
        if ($UsernameOnly) {
            $credObject.GetNetworkCredential().password.Substring(1).Split($delimiter)[0] | Write-Output
        }
        elseif ($PasswordOnly) {
            if ($PasswordAsString) {
                $credObject.GetNetworkCredential().password.Substring(1).Split($delimiter)[1] | Write-Output
            }
            else {
                $credObject.GetNetworkCredential().password.Substring(1).Split($delimiter)[1] | ConvertTo-SecureString -AsPlainText -Force | Write-Output
            }
        }
        else {
            [PSCustomObject]@{
                Username = $credObject.GetNetworkCredential().password.Substring(1).Split($delimiter)[0]
                Password =  if ($PasswordAsString) {
                                $credObject.GetNetworkCredential().password.Substring(1).Split($delimiter)[1]
                            }
                            else {
                                $credObject.GetNetworkCredential().password.Substring(1).Split($delimiter)[1] | ConvertTo-SecureString -AsPlainText -Force
                            }
            } | Write-Output
        }
    }
}

function verifyDirectory {
    param (
        [string]$pathToFile,
        [switch]$create
    )

    $pathToDir = $pathToFile.Substring(0,$pathToFile.LastIndexOf('\') + 1)


    if(Test-Path $pathToDir) {
        (Get-Item $pathToDir).FullName | Write-Output
    }
    elseif ($create) {
        (New-Item -Path $pathToDir -ItemType "directory").FullName | Write-Output
    }
    else {
        Write-Output $false
    }
}

function verifyFile {
    param (
        [string]$pathToFile,
        [switch]$create
    )

    if(Test-Path $pathToFile) {
        (Get-Item $pathToFile).FullName | Write-Output
    }
    elseif ($create) {
        (New-Item -Path $pathToFile -ItemType "file").FullName | Write-Output
    }
    else {
        Write-Output $false
    }
}