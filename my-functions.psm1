#Import child .ps1 files and dot-source them
$pathFunctions = @(Get-ChildItem -Path $PSScriptRoot/path/*.ps1);
$gitFunctions = @(Get-ChildItem -Path $PSScriptRoot/git/*.ps1);
$rustupFunctions = @(Get-ChildItem -Path $PSScriptRoot/rustup/*.ps1);
$networkFunctions = @(Get-ChildItem -Path $PSScriptRoot/network/*.ps1);
$dotnetFunctions = @(Get-ChildItem -Path $PSScriptRoot/dotnet/*.ps1);
$workFunctions = @(Get-ChildItem -Path $PSScriptRoot/work/*.ps1);
$shellFunctions = @(Get-ChildItem -Path $PSScriptRoot/shell/*.ps1);
foreach ($child in 
            $pathFunctions + 
            $gitFunctions + 
            $rustupFunctions + 
            $networkFunctions + 
            $dotnetFunctions +
            $workFunctions +
            $shellFunctions) {
    try {
        . $child.fullname
    }
    catch {
        Write-Error -Message "Failed to import function $($child.fullname): $_";
    }
}

function Start-Csi([string]$file) {
    $vswherePaths = & "${Env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\csi.exe;
    if (-Not($vswherePaths)) {
        throw "Unable to find any installed csi.exe.";
    }

    $csiExePath = $vswherePaths | Select-Object -First 1;
    & $csiExePath $file;
}

function Edit-Profile {
    code "$((Get-Item $Profile).Directory.FullName)";
}

# Relies on on the $SharedWslDir environment variable to already exist. It should be created manually
function Edit-SharedScripts {
    code "$env:SharedWslDir/.powershell/modules"
}

# Deals with insane powershell string-escaping requirements when invoking native applications.
# (i.e., the interior quotes must be backslash-escaped)
function Get-EscapedString {
    param( [Parameter(ValueFromPipeline = $true)] $stringToEscape ) 

    Begin {}

    Process {
        $stringToEscape -replace '([\\]*)"', '$1$1\"'
    }

    End {}
}
