function Open-GcProjectItem {
    [CmdletBinding()]
    [Alias("ocpi")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline, Position = 0)][Alias("id")][string]$ItemId
    )
    process {
        $item = Get-GcProjectItem -Id $ItemId

        if($null -ne $item)
        {
            Open-Url -Url $item.url
        }
        else
        {
            "Item with Id $ItemId not found." | Write-MyError
        }
    }
} Export-ModuleMember -Function Open-GcProjectItem -Alias("ocpi")