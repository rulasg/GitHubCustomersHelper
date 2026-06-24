
Set-MyInvokeCommandAlias -Alias UpdateProject -Command 'ProjectHelper\Update-Project -owner {owner} -projectNumber {projectnumber}'

class ValidProjectNames : System.Management.Automation.IValidateSetValuesGenerator { [String[]] GetValidValues() { return GetValidProjectNames}}
class ValidRepoNames : System.Management.Automation.IValidateSetValuesGenerator { [String[]] GetValidValues() { return GetValidRepoNames}}

function Update-GcProject{
    [CmdletBinding()]
    [Alias("ugp")]
    param(
        [Parameter()][switch]$IncludeDone,
        [Parameter()][switch]$Force,
        
        [Parameter()][string]$ProjectNumber,
        
        [Parameter()][ValidateSet([ValidRepoNames])][Alias("R")][string]$RepositoryName,
        [Parameter()][ValidateSet([ValidProjectNames])][Alias("P")][string]$ProjectName
    )

    ">>>" | Write-MyDebug -Section "Update-GcProject"

    $gcp = getGcProject

    # Sync single project if specified
    $plist = $gcp.$ProjectName ?? $gcp.Values

    foreach($project in $plist){

        $params = @{
            owner=$project.Owner
            projectnumber=$project.ProjectNumber
        }

        $result = Invoke-MyCommand -Command UpdateProject -Parameters $params

        if(-not $result){
            "Failed to update project [$($project.ProjectName)]." | Write-MyError
        }
    }
} Export-ModuleMember -Function Update-GcProject -Alias ugp

function Get-GcProjectItems{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)] [string[]]$Filter,
        [Parameter(Position = 1)][string[]]$Attributes,
        [Parameter()][switch]$IncludeDone,
        [Parameter()][switch]$Force,
        [Parameter()][switch]$PassThru,
        # [Parameter()][string]$FieldName,
        # [Parameter()][switch]$AnyField,
        # [Parameter()][switch]$Exact
        
        [Parameter()][string]$ProjectNumber,
        
        [Parameter()][ValidateSet([ValidRepoNames])][Alias("R")][string]$RepositoryName,
        [Parameter()][ValidateSet([ValidProjectNames])][Alias("P")][string]$ProjectName
    )

    $found = @((Get-AllItems -Force:$Force -ProjectName:$ProjectName).Values)


    # Owner and ProjectNumber filtering
    if(-Not [string]::IsNullOrEmpty($ProjectNumber)){
        $found = @($found | Where-Object {$_.projectNumber -eq $ProjectNumber})
    }

    # ProjectName 
    if(-Not [string]::IsNullOrEmpty($ProjectName)){
        $projectnumber = (getGcProject -ProjectName $ProjectName).Values.ProjectNumber
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
} Export-ModuleMember -Function Get-GcProjectItems

function Search-GcProjectItems{
    [CmdletBinding()]
    [Alias ("scpi")]
    param(
        [Parameter(Position = 0)] [string[]]$Filter,
        [Parameter(Position = 1)][string[]]$Attributes,
        [Parameter()][switch]$IncludeDone,
        [Parameter()][switch]$Force,
        [Parameter()][switch]$PassThru,
        # [Parameter()][string]$FieldName,
        # [Parameter()][switch]$AnyField,
        # [Parameter()][switch]$Exact
        
        [Parameter()][string]$ProjectNumber,
        
        [Parameter()][ValidateSet([ValidRepoNames])][Alias("R")][string]$RepositoryName,
        [Parameter()][ValidateSet([ValidProjectNames])][Alias("P")][string]$ProjectName
    )

    $defaultAttributes = @("id","RepositoryName","Title","Url")
    $attr = $defaultAttributes + $Attributes | Select-Object -Unique

    $params = @{
        Filter = $Filter
        Attributes = $attr
        IncludeDone = $IncludeDone
        Force = $Force.IsPresent
        PassThru = $PassThru.IsPresent
        ProjectNumber = $ProjectNumber
        ProjectName = $ProjectName
    }

    if(-Not [string]::IsNullOrWhiteSpace($RepositoryName)){
        $params.RepositoryName = $RepositoryName
    }

    $list =  Get-GcProjectItems @params

    return $list
} Export-ModuleMember -Function Search-GcProjectItems -Alias scpi