Function Get-AdvancedInstaller {
    <#
        .SYNOPSIS
            Get the current version and download URL for 7zip.

        .NOTES
            Site: 
            Author: 
            Twitter: 
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-AdvancedInstaller

            Description:
            Returns the current version and download URLs for AdvancedInstaller.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Get latest version and download latest release via SourceForge API
    $iwcParams = @{
        Uri         = $res.Get.Uri
    }
    $Content = Invoke-WebContent @iwcParams



    # Convert the returned release data into a useable object with Version, URI etc.
    $params = @{
        Content      = $Content
        Download     = $res.Get.Download
        MatchVersion = $res.Get.MatchVersion
        # DatePattern  = $res.Get.DatePattern
    }

    # Only proceed if content is present
    if ($null -ne $params.Content) {
        $Version = $params.Content | Select-String -Pattern $res.Get.MatchVersion | 
                                Select-Object -ExpandProperty 'Matches' | 
                                    Select-Object -ExpandProperty 'Groups' | 
                                        Select-Object -ExpandProperty 'Value' -First 1 -Skip 1

        # No need to go on if version is not present
        if ([string]::IsNullOrEmpty($Version)) {
            throw "Failed to match version in content."
        }

        # Create the object
        $PSObject = [PSCustomObject] @{
            Version      = $Version
            Architecture = 'x64'
            Platform     = "Windows"
            Date         = ""
            Size         = ""
            Language     = "en"
            URI          = $res.Get.DownloadUri
        }

        $RDate = $params.Content | Select-String -Pattern $res.Get.DatePattern | 
            Select-Object -ExpandProperty 'Matches' | 
                Select-Object -ExpandProperty 'Groups' | 
                    Select-Object -ExpandProperty 'Value' -Last 1
        
        # If a date is found, try to parse it. If found, add it to $PSObject
        if (-not [string]::IsNullOrEmpty($RDate)) {
            try {
                $ReleaseDate = [DateTime]::Parse(($RDate -replace 'nd' -replace 'th'), ([System.Globalization.CultureInfo]::InvariantCulture))
                $PSObject.Add('Date',$ReleaseDate.ToShortDateString())
            } catch {
                Write-Verbose "Failed to match release date."
            }
        }

        Write-Output $PSObject
    }
}