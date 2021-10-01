# kCreds

This is a PowerShell module used for storing encrypted credentials as text strings in files on your local workstation.

## Installation

To install this module run the `install.ps1` script provided in the root directory. This will automatically select your user specific powershell module directory and will validate that the path to it exists in your `PSModulePath` environment variable. It then validates the module files exist before copying them to the selected directory.
```powershell
C:> ./install.ps1
```

Additionally, you can use the `-InstallForSystem` switch and the script will install th module to the systems module directory.
```powershell
C:> ./install.ps1 -InstallForSystem
```

Fianlly, the `-InstallAtCustomPath` parameter can be used to specify a custom install path as a string.
```powershell
C:> ./install.ps1 -InstallAtCustomPath "C:\MyModuleDirectory"
```

### Manual Installation (Optional)

To install this module manually, copy the `.\kCreds` directory and it's files to your preferred PowerShell Module folder. Make sure that the directory you choose has been added to your `PSModulePath` directory. Common install directories in Windows are:

- User: `C:\Users\<username>\Documents\WindowsPowerShell\Modules`
- System: `C:\Program Files\WindowsPowerShell\Modules`

## Scripted Installation

Alternatively, you can install this module using the `./install.ps1` script provided. This script performs basic validations before copying the module

### Install in User Directory
```powershell
C:> ./install.ps1
```

## Usage

XX

