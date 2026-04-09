function Update-ProjectItem{
    [CmdletBinding()]
    [Alias("ucpi")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline, Position = 0)][Alias("id")][string]$ItemId
    )

    process{
        $item = Get-GcProjectItem -ItemId $ItemId

        $owner = $item.projectOwner
        $projectNumber = $item.projectNumber

        $response = ProjectHelper\Update-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $ItemId

        return $response
    }
} Export-ModuleMember -Function Update-ProjectItem -Alias("ucpi")