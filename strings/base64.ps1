<#
.SYNOPSIS
Enccode base-64 string(s).

.DESCRIPTION
PowerShell will print them to the console by default.
Usage:
    PS> ConvertTo-Base64 hello
    aGVsbG8=

    PS> ConvertTo-Base64 "hello world"
    aGVsbG8gd29ybGQ=

    PS> Get-Content -Raw some_file.txt | ConvertTo-Base64
    ZGVjb2RlZCBjb250ZW50
#>
Function ConvertTo-Base64 {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline)]
        $plainText
    )
    process {
        [System.Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($plainText));
    }
}

<#
.SYNOPSIS
Decode base-64 string(s).

.DESCRIPTION
Usage:
    PS> ConvertFrom-Base64 aGVsbG8=
    hello

    PS> Get-Content -Raw some_file.encoded.txt | ConvertFrom-Base64
    decoded content
#>
Function ConvertFrom-Base64 {
    # https://powershell.one/powershell-internals/scriptblocks/support-pipeline
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline)]
        $base64Text
    )
    process {
        [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($base64Text));
    }
}