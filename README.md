# kCreds
This is a PowerShell module used for storing encrypted credentials as text strings in files on your local workstation.

<!-- HOWITWORKS -->
## How it Works
This module uses the native encryption within PowerShell's `ConvertTo-SecureString` and `ConvertFrom-SecureString` commands to encrypt strings using the currently logged in user's token. This prevents any user other than the user that encrypted the password from decrypting it.

<!-- INSTALLATION -->
## Installation
To install this module run the `install.ps1` script provided in the root directory. This will automatically select your user specific powershell module directory and will validate that the path to it exists in your `PSModulePath` environment variable. It then validates the module files exist before copying them to the selected directory.
1. Change to your repos directory
```powershell
PS> cd C:\Users\Joe\Repos
```
1. Clone the repository
```powershell
PS> git clone "git@github.com:kalughle/ps-kCreds.git"
```
1. Change to the new directory
```
PS> cd .\kCreds
```
1. Install the module
```powershell
PS> .\install.ps1
```

Additionally, you can use the `-InstallForSystem` switch and the script will install th module to the systems module directory.
- *Note: You must be in an elevated prompt to perform this action*
```powershell
PS> .\install.ps1 -InstallForSystem
```

Fianlly, the `-InstallAtCustomPath` parameter can be used to specify a custom install path as a string.
- *Note: You may need to be in an elevated prompt to perform this action*
```powershell
PS> .\install.ps1 -InstallAtCustomPath "C:\MyModuleDirectory"
```

### Manual Installation (Optional)
To install this module manually, copy the `.\kCreds` directory and it's files to your preferred PowerShell Module folder. Make sure that the directory you choose has been added to your `PSModulePath` environment variable. Common install directories in Windows are:

- User: `C:\Users\<username>\Documents\WindowsPowerShell\Modules`
- System: `C:\Program Files\WindowsPowerShell\Modules`

<!-- EXAMPLES -->
## Usage
This module currently outputs two (2) functions, `Set-kCred` and `Read-kCred`.

### `Set-kCred`
Creates a new credential file containing the username and password provided, encrypted with the current users token. Then sends the output to a file.

**Example #1:** *Writes the file to `$env:USERPROFILE/.kcreds/$Username.kcred`*
```powershell
PS> Set-kCred -Username "User01" -Password "AW0nderfu11P@ssw0rd"
```

**Example #2:** *Writes the file to a path specified by the user*
```powershell
PS> Set-kCred -Username "User01" -Password "AW0nderfu11P@ssw0rd" -FilePath "C:\Users\<username>\.kcreds\myCredential.kcred"
```

**Example #3:** *Same as Example #2, but change the delimiter to a semicolon (;)*
```powershell
PS> Set-kCred -Username "User01" -Password "AW0nderfu11P@ssw0rd" -FilePath "C:\Users\<username>\.kcreds\myCredential.kcred" -Delimiter ";"
```

**Example #4:** *Writes the hash to the pipeline. Good for if you intend to store it somewhere else*
```powershell
PS> Set-kCred -Username "User01" -Password "AW0nderfu11P@ssw0rd" -OutputHash
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

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.

<!-- CONTACT -->
## Contact

Joseph Waddington (*Kalughle*) - kalughle@gmail.com

Project Link: [https://github.com/kalughle/ps-kCreds](https://github.com/kalughle/ps-kCreds)