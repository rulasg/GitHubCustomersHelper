
function Format-ProjectItem{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)][object]$Item,
        [Parameter(Position = 1)][string[]]$Attributes
    )

    begin {
        if([string]::IsNullOrWhiteSpace($Attributes)){
            $Attributes = @("id","Title","RepositoryName")
        }
    }

    process{

        $ret = [pscustomobject]::new()

        foreach($a in $Attributes){
            # just in case attribute has an empty name
            if( [string]::IsNullOrWhiteSpace($a) ){
                continue
            }

            # Add value even if it't empty value
            $value = $Item.$a ?? ""

            $ret | Add-Member -MemberType NoteProperty -Name $a -Value $value -force
        }

        return $ret
    }
}