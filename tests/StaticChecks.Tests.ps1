# Requires Pester 5+
Describe 'PowerShell automation scripts' {
    $scripts = @(Get-ChildItem -Path (Join-Path $PSScriptRoot '../scripts') -Filter '*.ps1')
    It 'includes scripts to validate' {
        $scripts.Count | Should -BeGreaterThan 0
    }
    It 'parses <_> without syntax errors' -ForEach $scripts {
        $tokens = $null
        $parseErrors = $null
        [void][System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$tokens, [ref]$parseErrors)
        $parseErrors.Count | Should -Be 0
    }
}
