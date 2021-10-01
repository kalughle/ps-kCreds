# kCreds
This is a PowerShell module used for storing encrypted credentials as text strings in files on your local workstation.

## How it Works
XX

## Installation
To install this module run the `install.ps1` script provided in the root directory. This will automatically select your user specific powershell module directory and will validate that the path to it exists in your `PSModulePath` environment variable. It then validates the module files exist before copying them to the selected directory.
```powershell
C:> .\install.ps1
```

Additionally, you can use the `-InstallForSystem` switch and the script will install th module to the systems module directory.
```powershell
C:> .\install.ps1 -InstallForSystem
```

Fianlly, the `-InstallAtCustomPath` parameter can be used to specify a custom install path as a string.
```powershell
PS C:> .\install.ps1 -InstallAtCustomPath "C:\MyModuleDirectory"
```

### Manual Installation (Optional)
To install this module manually, copy the `.\kCreds` directory and it's files to your preferred PowerShell Module folder. Make sure that the directory you choose has been added to your `PSModulePath` directory. Common install directories in Windows are:

- User: `C:\Users\<username>\Documents\WindowsPowerShell\Modules`
- System: `C:\Program Files\WindowsPowerShell\Modules`

## Usage
XX

### `Set-kCred`
Creates a new credential file containing the sername and password provided encrypted with the current users token, then sends the output to a file.

**Example #1:** *Create a new credential file using the name and password provided*
```powershell
PS> Set-kCred -Username "User01" -Password "AW0nderfu11P@ssw0rd" -FilePath "C:\Users\<username>\.kcreds\myCredential.kcred"
```

**Example #2:** *Same as Example #1, but change the delimiter to a semicolon (;)*
```powershell
PS> Set-kCred -Username "User01" -Password "AW0nderfu11P@ssw0rd" -FilePath "C:\Users\<username>\.kcreds\myCredential.kcred" -Delimiter ";"
```

### `Read-kCred`
Reads the credential from the file provided, decrypting it using the current users token.

**Example #1:** *Return a `PSCustomObject` with 2 properties. Username as a String, and Password as a SecureString*
```powershell
PS> Read-kCred -FilePath "C:\Users\<username>\.kcreds\myCredential.kcred"
```

**Example #2:** *Return a `PSCustomObject` with 2 properties. Username as a String, and Password as a String*
```powershell
PS> Read-kCred -FilePath "C:\Users\<username>\.kcreds\myCredential.kcred" -PasswordAsString
```

**Example #3:** *Return a `System.Security.SecureString` object containing the password only*
```powershell
PS> Read-kCred -FilePath "C:\Users\<username>\.kcreds\myCredential.kcred" -PasswordOnly
```

**Example #4:** *Return a `System.String` object containing the password only*
```powershell
PS> Read-kCred -FilePath "C:\Users\<username>\.kcreds\myCredential.kcred" -PasswordOnly -PasswordAsString
```

**Example #5:** *Return a `System.String` object containing the username only*
```powershell
PS> Read-kCred -FilePath "C:\Users\<username>\.kcreds\myCredential.kcred" -UsernameOnly
```