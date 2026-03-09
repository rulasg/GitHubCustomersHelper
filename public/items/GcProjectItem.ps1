function Get-GcProjectItem {
    [CmdletBinding()]
    [Alias ("gcpi")]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName, ValueFromPipeline, Position = 0)][Alias("id")][string]$ItemId
    )

    $all = Get-AllItems

    if([string]::IsNullOrEmpty($ItemId)){
        return $all
    } else {
        $item = $all.$ItemId

        if(-Not $item){
            throw ("Item not found: "+$ItemId)
        }

        return $item
    }

} Export-ModuleMember -Function Get-GcProjectItem -Alias gcpi