function Get-GcProjectItem {
    [CmdletBinding()]
    [Alias ("gcpi")]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName, ValueFromPipeline, Position = 0)][Alias("id")][string]$ItemId
    )

    begin{
        $all = Get-AllItems
    }

    process{

        if([string]::IsNullOrEmpty($ItemId)){
            return $all
        } else {
            $item = $all.$ItemId
            
            if(-Not $item){
                throw ("Item not found: "+$ItemId)
            }
            
            return $item
        }
    }

} Export-ModuleMember -Function Get-GcProjectItem -Alias gcpi

function Get-GcProjectItemByUrl {
    [CmdletBinding()]
    [Alias ("gcpiu")]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName, ValueFromPipeline, Position = 0)][string]$Url
    )

    begin{
        $all = Get-AllItems
    }

    process{

        $item = $all.Values | Where-Object {$_.Url -eq $Url}

        # Not found
        if(-Not $item){
            return
        }

        return $item
    }

} Export-ModuleMember -Function Get-GcProjectItemByUrl -Alias gcpiu