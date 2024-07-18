#Some future todo:
# Make this only export the functions I actually want to be public, instead of literally every function in the whole module

#Import child .ps1 files and dot-source them
$pathFunctions = @(Get-ChildItem -Path $PSScriptRoot/path/*.ps1);
$gitFunctions = @(Get-ChildItem -Path $PSScriptRoot/git/*.ps1);
$rustupFunctions = @(Get-ChildItem -Path $PSScriptRoot/rustup/*.ps1);
$networkFunctions = @(Get-ChildItem -Path $PSScriptRoot/network/*.ps1);
$dotnetFunctions = @(Get-ChildItem -Path $PSScriptRoot/dotnet/*.ps1);
$workFunctions = @(Get-ChildItem -Path $PSScriptRoot/work/*.ps1);
$shellFunctions = @(Get-ChildItem -Path $PSScriptRoot/shell/*.ps1);
$stringsFunctions = @(Get-ChildItem -Path $PSScriptRoot/strings/*.ps1);
$azureFunctions = @(Get-ChildItem -Path $PSScriptRoot/azure/*.ps1);
foreach ($child in 
    $pathFunctions + 
    $gitFunctions + 
    $rustupFunctions + 
    $networkFunctions + 
    $dotnetFunctions +
    $workFunctions +
    $shellFunctions + 
    $stringsFunctions +
    $azureFunctions) {
    try {
        . $child.fullname
    }
    catch {
        Write-Error -Message "Failed to import function $($child.fullname): $_";
    }
}

# Remove the 'where' alias for Where-Object, so I can use where.exe without always typing the .exe
# Do it twice, because there appear to somehow be leftovers if it's only called once.
# Maybe it's a scope thing?
Remove-Alias where -Force -Scope Global;
Remove-Alias where -Force -Scope Global;

function Start-Csi([string]$file = $null) {
    $vswherePaths = & "${Env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\csi.exe;
    if (-Not($vswherePaths)) {
        throw "Unable to find any installed csi.exe.";
    }

    $csiExePath = $vswherePaths | Select-Object -First 1;
    if ($file) {
        & $csiExePath $file;
    }
    else {
        & $csiExePath;
    }
}

function Edit-Profile {
    code "$((Get-Item $Profile).Directory.FullName)";
}

function Edit-SharedScripts {
    code $PSScriptRoot;
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
