function Add-ToGlobalPath([string] $newString, [string] $pathTarget="User") {  
  if ($pathTarget.ToUpperInvariant() -ne "MACHINE" -and $pathTarget.ToUpperInvariant() -ne "USER") {
    throw "The given pathTarget ($pathTarget) was invalid.";
  }

  $oldPath = [System.Environment]::GetEnvironmentVariable("PATH", $pathTarget);
  $newPath = "$oldPath;$newString"; # add new string, separated by a semicolon.
  [Environment]::SetEnvironmentVariable("PATH", $newPath, $pathTarget);
  
  # Update path for current process
  $machinePath = [System.Environment]::GetEnvironmentVariable("PATH", "MACHINE");
  $userPath = [System.Environment]::GetEnvironmentVariable("PATH", "USER");

  if ($machinePath.EndsWith(";") -eq $false) {
    $machinePath = $machinePath + ";";
  }

  $env:Path = $machinePath + $userPath;
}