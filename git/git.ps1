# Sends current branch up to remote, then opens github page to create new PR.
function New-PR([switch]$SuppressBrowser, [string]$TargetBranch = "master") {    

    if ($null -eq (Get-Command "git" -ErrorAction SilentlyContinue)) { 
        Write-Error "Cannot find 'git' in the currently-loaded PATH.";
        return;
    }

    $currentBranchName = Invoke-Command -ScriptBlock {
        git rev-parse --abbrev-ref HEAD 
    };

    git push --set-upstream origin $currentBranchName;

    if (-Not ($SuppressBrowser)) {
        $gitRemoteUrl = Invoke-Command -ScriptBlock { git config --get remote.origin.url };
        $atSymbolIndex = $gitRemoteUrl.IndexOf("@");
        
        # GitHub
        #$httpRemoteUrl = $gitRemoteUrl.Substring($atSymbolIndex + 1).Replace(":", "/").Replace(".git", "");
        #$httpRemoteUrl = "https://www." + $httpRemoteUrl + "/compare/$($TargetBranch)...$($currentBranchName)?expand=1";

        # Bitbucket
        $urlSegments = $gitRemoteUrl.Substring($atSymbolIndex + 1).Replace(".git", "").Split("/");
        $base = $urlSegments[0];
        $teamName = $urlSegments[1];
        $projectName = $urlSegments[2];
        $encodedTargetBranch = [System.Web.HTTPUtility]::UrlEncode("refs/heads/$TargetBranch");
        $encodedSourceBranch = [System.Web.HTTPUTility]::UrlEncode("refs/heads/$currentBranchName");
        $httpRemoteUrl = "https://$($base)/projects/$($teamName)/repos/$($projectName)/pull-requests?create&targetBranch=$($encodedTargetBranch)&sourceBranch=$($encodedSourceBranch)";
        
        Write-Host "Opening browser to: $httpRemoteUrl";
        if ($PSVersionTable.Platform -eq "Unix") {
            if ($PSVersionTable.OS.Contains("microsoft-standard") -or 
                $PSVersionTable.OS.Contains("Microsoft")) {
                # We're on WSL and probably not running a graphical environment. 
                # Instead of trying to launch the browser, copy the URL to the clipboard
                Write-Host "No browser found, copying URL to clipboard instead.";
                $httpRemoteUrl | clip.exe
                Set-Clipboard $httpRemoteUrl;
            }
            else {
                Start-Process nohup $httpRemoteUrl
            }
        } else {
            Start-Process $httpRemoteUrl;
        }
    }
}

# Tab-completion for branch name for the $TargetBranch argument.
Register-ArgumentCompleter -CommandName New-PR -ParameterName TargetBranch -ScriptBlock {
    param($commandName, $parameterName, $userString)        
    git branch --list "$($userString)*" --no-color --no-column | ForEach-Object { 
        $_.Replace('*', '').Trim(); # Remove current branch indicator and indentation        
    }
};

function Remove-Goners([switch]$Force) {
    git fetch --prune
    $gonerBranches = git branch -vv | Select-String "gone"; 
    foreach ($branch in $gonerBranches) {
        $branchName = $branch.Line.TrimStart().Split(' ')[0];
        if ($Force) { 
            git branch -D $branchName;
        }
        else {
            git branch -d $branchName;
        }
    }
}