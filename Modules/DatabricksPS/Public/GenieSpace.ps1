<#
.SYNOPSIS
    Retrieves one or all Genie Spaces.

.DESCRIPTION
    Calls the Databricks Genie REST API to retrieve metadata for a specific
    Genie Space or all Genie Spaces in the workspace.

.PARAMETER SpaceId
    Optional. The ID of the Genie Space to retrieve. If omitted, all spaces
    are returned.

.EXAMPLE
    Get-DatabricksGenieSpace

.EXAMPLE
    Get-DatabricksGenieSpace -SpaceId "abcd-1234"

.NOTES
    Requires an active Databricks connection created using Connect-Databricks.
#>
function Get-DatabricksGenieSpace {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string] $SpaceId
    )

    try {
        if ($SpaceId) {
            $Endpoint = "/api/2.0/genie/spaces/$SpaceId"
        }
        else {
            $Endpoint = "/api/2.0/genie/spaces"
        }

        $Url     = Get-DatabricksAPIUrl -Endpoint $Endpoint
        $Headers = Get-DatabricksAPIHeaders

        Invoke-DatabricksApiRequest -Method GET -Url $Url -Headers $Headers
    }
    catch {
        throw $_
    }
}

<#
.SYNOPSIS
    Exports a Genie Space to a JSON file.

.DESCRIPTION
    Calls the Databricks Genie REST API to export the full definition of a
    Genie Space and writes it to a JSON file for backup or migration.

.PARAMETER SpaceId
    The ID of the Genie Space to export.

.PARAMETER OutputPath
    The file path where the exported JSON should be saved.

.EXAMPLE
    Export-DatabricksGenieSpace -SpaceId "abcd-1234" -OutputPath "C:\temp\space.json"

.NOTES
    The output file contains the full Genie Space definition.
#>
function Export-DatabricksGenieSpace {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $SpaceId,

        [Parameter(Mandatory = $true)]
        [string] $OutputPath
    )

    try {
        $Endpoint = "/api/2.0/genie/spaces/$SpaceId/export"
        $Url     = Get-DatabricksAPIUrl -Endpoint $Endpoint
        $Headers = Get-DatabricksAPIHeaders

        $Response = Invoke-DatabricksApiRequest -Method GET -Url $Url -Headers $Headers

        $Response | ConvertTo-Json -Depth 20 | Out-File -FilePath $OutputPath -Encoding utf8
        Write-Output "Exported Genie Space [$SpaceId] to $OutputPath"
    }
    catch {
        throw $_
    }
}

<#
.SYNOPSIS
    Imports a Genie Space from a JSON file.

.DESCRIPTION
    Calls the Databricks Genie REST API to import a Genie Space definition
    from a JSON file previously exported using Export-DatabricksGenieSpace.

.PARAMETER InputPath
    The path to the JSON file containing the Genie Space definition.

.EXAMPLE
    Import-DatabricksGenieSpace -InputPath "C:\temp\space.json"

.NOTES
    The imported Genie Space will be created in the connected workspace.
#>
function Import-DatabricksGenieSpace {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $InputPath
    )

    try {
        if (-not (Test-Path $InputPath)) {
            throw "Input file not found: $InputPath"
        }

        $Body = Get-Content -Path $InputPath -Raw

        $Endpoint = "/api/2.0/genie/spaces/import"
        $Url     = Get-DatabricksAPIUrl -Endpoint $Endpoint
        $Headers = Get-DatabricksAPIHeaders

        Invoke-DatabricksApiRequest -Method POST -Url $Url -Headers $Headers -Body $Body
    }
    catch {
        throw $_
    }
}

<#
.SYNOPSIS
    Deletes a Genie Space.

.DESCRIPTION
    Calls the Databricks Genie REST API to delete a Genie Space by ID.

.PARAMETER SpaceId
    The ID of the Genie Space to delete.

.EXAMPLE
    Remove-DatabricksGenieSpace -SpaceId "abcd-1234"

.NOTES
    This action is irreversible. Use with caution.
#>
function Remove-DatabricksGenieSpace {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string] $SpaceId
    )

    try {
        $Endpoint = "/api/2.0/genie/spaces/$SpaceId"
        $Url     = Get-DatabricksAPIUrl -Endpoint $Endpoint
        $Headers = Get-DatabricksAPIHeaders

        if ($PSCmdlet.ShouldProcess("Genie Space [$SpaceId]", "Delete")) {
            Invoke-DatabricksApiRequest -Method DELETE -Url $Url -Headers $Headers
            Write-Output "Deleted Genie Space [$SpaceId]"
        }
    }
    catch {
        throw $_
    }
}
