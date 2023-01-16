###################################################################################################
# PRIMARY: Set-kCred                                                                              #
###################################################################################################
function Set-kCred {
    <#
    .SYNOPSIS
    Creates a new credential file containing the username and password provided, encrypted with the current users token. Then sends the output to a file.

    .DESCRIPTION
    Creates a new credential file containing the username and password provided, encrypted with the current users token. Then sends the output to a file.

    .PARAMETER Username
    Provide the case sensitive username you would like to use for this credential.

    .PARAMETER Password
    Provide the password you wish to use for this credntial.

    .PARAMETER FilePath
    Provide the file path you wish to store this credential to.

    .PARAMETER OutputHash
    If selected, will output the encrypyerd hash directly to the pipeline rather than writing a file

    .PARAMETER Delimiter
    The character to be used to seperate the username and password in the credential. May not be a character contained in the Username or Password

    .INPUTS
    None. You cannot pipe objects to Set-kCred.

    .OUTPUTS
    System.String
        A string value of the credential file path is output

    .EXAMPLE
    PS> Set-kCred -Username "User01" -Password "AW0nderfu11P@ssw0rd"
    Creates a new credential file containing the username and password provided, encrypted with the current users token. Then sends the output to a file located at "$env:USERPROFILE\.kcreds\$Username.kcred"

    .EXAMPLE
    PS> Set-kCred -Username "User01" -Password "AW0nderfu11P@ssw0rd" -FilePath $env:USERPROFILE/.kcreds/myCredential.kcred
    Same as Example #1, but sends the output to a file location you designate

    .EXAMPLE
    PS> Set-kCred -Username "User01" -Password "AW0nderfu11P@ssw0rd" -FilePath $env:USERPROFILE/.kcreds/myCredential.kcred -Delimiter ";"
    Same as Example #2, but change the delimiter to a semicolon (;)

    .EXAMPLE
    PS> Set-kCred -Username "User01" -Password "AW0nderfu11P@ssw0rd" -OutputHash
    Writes the hash to the pipeline. Good for if you intend to store it somewhere else

    .LINK
    https://github.com/kalughle/ps-kcreds
    #>

    param (
        [Parameter(Mandatory=$true,HelpMessage="Provide the case sensitive username you would like to use for this credential.")]
        [string]$Username,

        [Parameter(Mandatory=$true,HelpMessage="Provide the password you wish to use for this credential.")]
        [string]$Password,

        [Parameter(HelpMessage="Provide the file path you wish to store this credential to.")]
        [string]$FilePath,

        [Parameter()]
        [switch]$OutputHash,

        [Parameter(HelpMessage="Provide a single character to use as the delimiter")]
        [ValidateLength(1,1)]
        [string]$Delimiter = ':'
    )

    # Check to make sure the Username or Password does not contain the delimiter
    if ($Username -like "*$Delimiter*" -or $Password -like "*$Delimiter*") {
        Write-Error "Username or Password contains the delimiter character ($Delimiter). Please select a different delimiter."
        break
    }

    # Join the username and password in to one string using the selected delimiter
    # Prepend the string with the delimiter used to allow the read function to separate them
    $joinedCred = $Delimiter + $Username + $Delimiter + $Password

    # Convert the combined string in to a SecureString
    $secureCred = ConvertTo-SecureString -String $joinedCred -AsPlainText -Force

    # Create a credential object using the whole SecureString as the password. This encrypts the
    # string using the current user's token
    $credObject = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'empty', $secureCred

    # If OutputHash selected, write the hash of the credential to the pipeline
    if ($FilePath) {
        # Replace any forward slashes with back slashes
        $cleanPath = $FilePath.Replace("/", "\")

        # Verify that the directory provided exists, and create it if not
        verifyDirectory -pathToFile $cleanPath -create | Out-Null

        # Verify that the file provided exists, and create it if not
        $kCredsFileOk = verifyFile -pathToFile $cleanPath -create

        $credObject.Password | ConvertFrom-SecureString | Out-File $kCredsFileOk
        Write-Output $kCredsFileOk
    }
    elseif ($OutputHash) {
        $credObject.Password | ConvertFrom-SecureString | Write-Output
    }
    else {
        # Replace any forward slashes with back slashes
        $filePath = "$env:USERPROFILE\.kcreds\$Username.kcred"

        # Verify that the directory provided exists, and create it if not
        verifyDirectory -pathToFile $filePath -create | Out-Null

        # Verify that the file provided exists, and create it if not
        $kCredsFileOk = verifyFile -pathToFile $filePath -create

        $credObject.Password | ConvertFrom-SecureString | Out-File $kCredsFileOk
        Write-Output $kCredsFileOk
    }
}

###################################################################################################
# PRIMARY: Read-kCred                                                                             #
###################################################################################################
function Read-kCred {
    <#
    .SYNOPSIS
    Reads the credential from the file provided using the current users token.

    .DESCRIPTION
    Reads the credential from the file provided using the current users token.

    .PARAMETER FilePath
    Provide the file path you wish to read this credential from.

    .PARAMETER FileHash
    Provide the hashed credential as output from Set-kCred -.

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
    User01   AW0nderfu11P@ssw0rd

    .EXAMPLE
    Read-kCred -FilePath $env:USERPROFILE/.kcreds/myCredential.kcred -PasswordOnly
    Returns a System.Security.SecureString object containing the password only

    System.Security.SecureString

    .EXAMPLE
    Read-kCred -FilePath $env:USERPROFILE/.kcreds/myCredential.kcred -PasswordOnly -PasswordAsString
    Return a System.String object containing the password only

    AW0nderfu11P@ssw0rd

    .EXAMPLE
    Read-kCred -FilePath $env:USERPROFILE/.kcreds/myCredential.kcred -UsernameOnly
    Return a System.String object containing the username only

    User01

    .LINK
    https://github.com/kalughle/ps-kcreds
    #>

    param (
        [Parameter()]
        [string]$FilePath,

        [Parameter()]
        [string]$FileHash,

        [switch]$UsernameOnly,

        [switch]$PasswordOnly,

        [switch]$PasswordAsString
    )

    if ($FilePath -ne "") {
        # Replace any forward slashes with back slashes and pull the content
        $cleanPath = $FilePath.Replace("/", "\")
        $encryptedContent = Get-Content $cleanPath
    }
    elseif ($FileHash -eq "") {
        $encryptedContent = $FileHash
    }
    else {
        Write-Error "Both FilePath and FileHash are empty. You must provide one of these values"
        break
    }

    # Pull the string out of the file and convert it to a secure string using the local users credential
    try {
        $secureCred = $encryptedContent | ConvertTo-SecureString -ErrorAction Stop
    }
    catch [System.Security.Cryptography.CryptographicException] {
        if ($PSItem.Exception.Message.Trim() -eq "Key not valid for use in specified state.") {
            Write-Warning "Invalid user token. This user is not authoried to decrypt this data."
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

###################################################################################################
# HELPER FUNCTIONS                                                                                #
###################################################################################################
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