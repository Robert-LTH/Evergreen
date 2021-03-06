Function Get-MicrosoftWvdRtcService {
    <#
        .SYNOPSIS
            Get the current version and download URL for the Microsoft Remote Desktop WebRTC Redirector service.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-MicrosoftWvdRtcService

            Description:
            Returns the current version and download URL for the Microsoft Remote Desktop WebRTC Redirector service.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Grab the download link headers to find the file name
    try {
        #TODO: turn this into a function
        $params = @{
            Uri             = $res.Get.Uri
            Method          = "Head"
            UseBasicParsing = $True
            ErrorAction     = $script:resourceStrings.Preferences.ErrorAction
        }
        $Headers = (Invoke-WebRequest @params).Headers
    }
    catch [System.Net.WebException] {
        Write-Warning -Message "$($MyInvocation.MyCommand): Error at: $res.Get.Uri."
        Throw ([string]::Format("Error : {0}", $_.Exception.StatusCode))
    }
    catch {
        Write-Warning -Message "$($MyInvocation.MyCommand): Error at: $res.Get.Uri."
        Throw ([string]::Format("Error : {0}", $_.Exception.StatusCode))
    }

    If ($Headers) {
        # Match filename
        $Filename = [RegEx]::Match($Headers['Content-Disposition'], $res.Get.MatchFilename).Captures.Groups[1].Value

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version      = [RegEx]::Match($Headers['Content-Disposition'], $res.Get.MatchVersion).Captures.Value
            Architecture = Get-Architecture -String $Filename
            Date         = $Headers['Last-Modified'] | Select-Object -First 1
            Size         = $Headers['Content-Length'] | Select-Object -First 1
            Filename     = $Filename
            URI          = $res.Get.Uri
        }
        Write-Output -InputObject $PSObject
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to return a header from $($res.Get.Uri)."
    }
}
