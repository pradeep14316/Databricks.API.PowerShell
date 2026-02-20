<#
.SYNOPSIS
    Databricks Genie Space API (modeled after DatabricksPS module structure)

.DESCRIPTION
    Implements Genie Space management using the Databricks REST API.
    This script follows the same structure as:
    Modules/DatabricksPS/Public/ClusterPoliciesAPI.ps1

    Functions included:
        - Get-DatabricksGenieSpace
        - Export-DatabricksGenieSpace
        - Import-DatabricksGenieSpace
        - Remove-DatabricksGenieSpace

    Requires:
        Connect-Databricks
        Invoke-DatabricksAPI
#>

# ---------------------------------------------------------------------
# GET GENIE SPACE(S)
# ---------------------------------------------------------------------
function Get-DatabricksGenieSpace {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string] $SpaceId
    )

    if ($SpaceId) {
        $Endpoint = "/api/2.0/genie/spaces/$SpaceId"
    }
    else {
        $Endpoint = "/api/2.0/genie/spaces"
    }

    try {
        Invoke-DatabricksAPI -Method GET -Endpoint $Endpoint
    }
    catch {
        throw "Failed to retrieve Genie Space information: $($_.Exception.Message)"
    }
}

# ---------------------------------------------------------------------
# EXPORT GENIE SPACE
# ---------------------------------------------------------------------
function Export-DatabricksGenieSpace {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $SpaceId,

        [Parameter(Mandatory = $true)]
        [string] $OutputPath
    )

    $Endpoint = "/api/2.0/genie/spaces/$SpaceId/export"

    try {
        $Response = Invoke-DatabricksAPI -Method GET -Endpoint $Endpoint

        $Directory = Split-Path -Path $OutputPath -Parent
        if (-not (Test-Path $Directory)) {
            New-Item -ItemType Directory -Path $Directory -Force | Out-Null
        }

        $Response | ConvertTo-Json -Depth 20 | Out-File -FilePath $OutputPath -Encoding utf8
        Write-Output "Genie Space [$SpaceId] exported to: $OutputPath"
    }
    catch {
        throw "Failed to export Genie Space [$SpaceId]: $($_.Exception.Message)"
    }
}

# ---------------------------------------------------------------------
# IMPORT GENIE SPACE
# ---------------------------------------------------------------------
function Import-DatabricksGenieSpace {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $InputPath
    )

    if (-not (Test-Path $InputPath)) {
        throw "Input file not found: $InputPath"
    }

    $Payload = Get-Content -Path $InputPath -Raw
    $Endpoint = "/api/2.0/genie/spaces/import"

    try {
        Invoke-DatabricksAPI -Method POST -Endpoint $Endpoint -Body $Payload
    }
    catch {
        throw "Failed to import Genie Space from [$InputPath]: $($_.Exception.Message)"
    }
}

# ---------------------------------------------------------------------
# DELETE GENIE SPACE
# ---------------------------------------------------------------------
function Remove-DatabricksGenieSpace {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true)]
        [string] $SpaceId
    )

    $Endpoint = "/api/2.0/genie/spaces/$SpaceId"

    if ($PSCmdlet.ShouldProcess("Genie Space [$SpaceId]", "Delete")) {
        try {
            Invoke-DatabricksAPI -Method DELETE -Endpoint $Endpoint
            Write-Output "Genie Space [$SpaceId] deleted."
        }
        catch {
            throw "Failed to delete Genie Space [$SpaceId]: $($_.Exception.Message)"
        }
    }
}
