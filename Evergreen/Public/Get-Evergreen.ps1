Function Get-Evergreen {
    param(
        $Application
    )
    $ListParameters = @{
        Filter = "*.json"
    }
    if (-not [string]::IsNullOrEmpty($Application)) {
        $ListParameters.Filter = "$($Application).json"
    }
    # List manifests contents
    # Name of manifest file should match the functions Get-Name
    #$Path = Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "Manifests"
    $ExcludedCommands = @(
        $MyInvocation.MyCommand.Name,
        'Get-Architecture'
    )
    try {
        Get-Command -Module 'Evergreen' -Verb 'Get' | Where-Object { $_.Commandtype -eq 'Function' -and  $_.Name -notin $ExcludedCommands } | ForEach-Object {
           # Get-ChildItem -Path $Path @ListParameters | ForEach-Object {
                #$AppManifest = $_.FullName
                Write-Debug $_.Name
                $AppManifestName = Get-FunctionResource -AppName ($_.Name -replace '^Get-') | Select-Object -ExpandProperty Name
                if ($AppManifestName) {
                    $PSObject = [PSCustomObject] @{
                        AppName = $AppManifestName
                        Cmdlet = $_.Name
                    }
                    Write-Output $PSObject
                }
            #}
        }
    }
    catch [System.Exception] {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to read from: $AppManifest."
        Throw $_.Exception.Message
    }
}