function Get-EvergreenLatestVersions {
    Get-Evergreen | ForEach-Object  {
        try {
            Write-Debug $_
            $VersionInfo = Invoke-Expression -Command $_.Cmdlet
            $_ | Add-Member VersionInfo $VersionInfo
            $_
        } catch {
            $_ | Add-Member VersionInfo @{
                Language = ""
                Version = ""
                Architecture = ""
                Platform = ""
                Size = ""
                URI = ""
            }
        }
    }
}