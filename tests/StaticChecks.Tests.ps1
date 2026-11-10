
# Requires Pester 5+

BeforeAll {
    $script:ScriptsPath = Join-Path $PSScriptRoot '../scripts'
}

Describe 'PowerShell automation scripts' {

    It 'includes scripts to validate' {
        $scripts = @(Get-ChildItem -Path $script:ScriptsPath -Filter '*.ps1' -File)
        $scripts.Count | Should -BeGreaterThan 0
    }

    It 'parses without syntax errors' {
        $scripts = @(Get-ChildItem -Path $script:ScriptsPath -Filter '*.ps1' -File)

        foreach ($file in $scripts) {
            $tokens = $null
            $parseErrors = $null

            [void][System.Management.Automation.Language.Parser]::ParseFile(
                $file.FullName,
                [ref]$tokens,
                [ref]$parseErrors
            )

            $parseErrors.Count | Should -Be 0
        }
    }
}
