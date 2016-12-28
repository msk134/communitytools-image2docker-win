﻿function Discover_IIS {
<#
.SYNOPSIS
Scans for presence of the Internet Information Services (IIS) Web Server 

.PARAMETER MountPath
The path where the Windows image was mounted to.

.PARAMETER OutputPath
The filesystem path where the discovery manifest will be emitted.

.PARAMETER ArtifactParam
Optional - one or more Website names to include in the output.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess",'')]
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string] $MountPath,

    [Parameter(Mandatory = $true)]
    [string] $OutputPath,

    [Parameter(Mandatory = $false)]
    [string[]] $ArtifactParam
)

$ArtifactName = Split-Path -Path $PSScriptRoot -Leaf
Write-Verbose -Message ('Started discovering {0} artifact' -f $ArtifactName)

### Path to the manifest
$Manifest = '{0}\{1}.json' -f $OutputPath, $ArtifactName

### Create a HashTable to store the results (this will get persisted to JSON)
$ManifestResult = @{
    FeatureName = ''
    Status = ''
}

try {
    $WindowsFeatures = Get-WindowsOptionalFeature -Path $MountPath
    $ManifestResult = GetManifestFromApplicationHost -OutputPath $OutputPath -MountPath $Mount.Path -ArtifactParam $ArtifactParam
}
catch {    
    $ManifestResult = GetManifestFromMetabase -OutputPath $OutputPath -MountPath $Mount.Path -ArtifactParam $ArtifactParam
}

if ($ManifestResult.Status -eq 'Present'){
    Write-Verbose -Message 'IIS service is present on the system'  
    if ($ManifestResult.AspNetStatus -eq 'Present'){
       Write-Verbose -Message 'ASP.NET is present on the system'
    }
    else {
        Write-Verbose -Message 'ASP.NET is NOT present on the system'
    }
}
else {
    Write-Verbose -Message 'IIS service is NOT present on the system'  
}

### Write the result to the manifest file
$ManifestResult | ConvertTo-Json -Depth 3 | Set-Content -Path $Manifest

Write-Verbose -Message ('Finished discovering {0} artifact' -f $ArtifactName)
}