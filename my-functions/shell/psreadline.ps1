Function Set-PSReadLineDefaults {

    # Make inline prediction actually readable
    # Set mode "3" (aka italic), then use "set RGB color" (38;2;r;g;b) to set color, and end with 'm' to indicate that the sequence is over
    Set-PSReadLineOption -Colors @{ InlinePrediction = "`e[3;38;2;109;127;170m" }

    # `ForwardChar` accepts the entire suggestion text when the cursor is at the end of the line.
    # This custom binding makes `RightArrow` behave similarly - accepting the next word instead of the entire suggestion text.
    Set-PSReadLineKeyHandler -Key RightArrow `
                            -BriefDescription ForwardCharAndAcceptNextSuggestionWord `
                            -LongDescription "Move cursor one character to the right in the current editing line and accept the next word in suggestion when it's at the end of current editing line" `
                            -ScriptBlock {
        param($key, $arg)

        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

        if ($cursor -lt $line.Length) {
            [Microsoft.PowerShell.PSConsoleReadLine]::ForwardChar($key, $arg)
        } else {
            [Microsoft.PowerShell.PSConsoleReadLine]::AcceptNextSuggestionWord($key, $arg)
        }
    }

    # Allow us to use Ctrl+RightArrow to accept an entire prediction
    Set-PSReadLineKeyHandler -Chord Ctrl+RightArrow `
                            -BriefDescription ForwardCharAndAcceptNextSuggestion `
                            -LongDescription "Move cursor one word to the right in the current editing line and accept the entire suggestion when it's at the end of current editing line" `
                            -ScriptBlock {
        param($key, $arg)

        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

        if ($cursor -lt $line.Length) {
            [Microsoft.PowerShell.PSConsoleReadLine]::ForwardWord($key, $arg)
        } else {
            [Microsoft.PowerShell.PSConsoleReadLine]::AcceptSuggestion($key, $arg)
        }
    }
}