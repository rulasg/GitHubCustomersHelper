
class ValidProjectNames : System.Management.Automation.IValidateSetValuesGenerator { [String[]] GetValidValues() { return GetValidProjectNames}}
class ValidRepoNames : System.Management.Automation.IValidateSetValuesGenerator { [String[]] GetValidValues() { return GetValidRepoNames}}


function Get-GcProjectItems{
    [CmdletBinding()]
    [Alias ("scpi")]
    param(
        [Parameter(Position = 0)] [string[]]$Filter,
        [Parameter(Position = 1)][string[]]$Attributes,
        [Parameter()][string]$ProjectOwner,
        [Parameter()][string]$ProjectNumber,
        [Parameter()][switch]$IncludeDone,
        [Parameter()][switch]$Force,
        [Parameter()][switch]$PassThru,
        # [Parameter()][string]$FieldName,
        # [Parameter()][switch]$AnyField,
        # [Parameter()][switch]$Exact
        
        [Parameter()][ValidateSet([ValidRepoNames])][string]$RepositoryName,
        [Parameter()][ValidateSet([ValidProjectNames])][string]$ProjectName
    )

    $found = @((Get-AllItems -Force:$Force).Values)


    # Owner and ProjectNumber filtering
    if(-Not [string]::IsNullOrEmpty($Owner)){
        $found = @($found | Where-Object {$_.projectOwner -eq $Owner})
    }

    # ProjectName 
    if(-Not [string]::IsNullOrEmpty($ProjectName)){
        $projectnumber = (getGcProject -ProjectName $ProjectName).ProjectNumber
    }

    # ProjectNumber filtering    if(-Not [string]::IsNullOrEmpty($ProjectNumber)){
    if(-Not [string]::IsNullOrEmpty($ProjectNumber)){
        $found = @($found | Where-Object {$_.projectNumber -eq $ProjectNumber})
    }

    #IncludeDone
    if($IncludeDone){
        $found = @($found)
    } else {
        $found = @($found | Where-Object {$_.Status -ne "Done"})
    }

    #RepositoryName
    if(-Not [string]::IsNullOrEmpty($RepositoryName)){
        $found = @($found | Where-Object {$_.RepositoryName -eq $RepositoryName})
    }

    #Filter
    if(-Not [string]::IsNullOrEmpty($Filter)){
        $found = @($found | Where-Object {$_.Title -match $Filter})
    }


    if($PassThru){
        $ret = $found
    } else {
        $ret = $found | Format-ProjectItem -Attributes $Attributes
    }

    return $ret
} Export-ModuleMember -Function Get-GcProjectItems -Alias scpi