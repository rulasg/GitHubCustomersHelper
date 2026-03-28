Set-MyInvokeCommandAlias -Alias FindProjectByCreator -Command 'Find-Project -owner {owner} -pattern "{pattern}"'

class ValidProjectNames : System.Management.Automation.IValidateSetValuesGenerator { [String[]] GetValidValues() { return GetValidProjectNames}}

function Get-GcProject {
    [CmdletBinding()]
    [Alias("gcp")]
    param(
        [Parameter(Position = 0)][ValidateSet([ValidProjectNames])][string]$ProjectName,
        [parameter()][switch]$IncludeClosed,
        [parameter()][switch]$All,
        [parameter()][switch]$Force
    )
    
    $result = getGcProject -ProjectName $ProjectName -IncludeClosed:$IncludeClosed -All:$All -Force:$Force

    $ret = @()
    $result.Values | ForEach-Object {
        $ret += [pscustomobject]$_
    }
    return $ret
} Export-ModuleMember -Function Get-GcProject -Alias gcp


function getGcProject {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$ProjectName,
        [parameter()][switch]$IncludeClosed,
        [parameter()][switch]$All,
        [parameter()][switch]$Force
    )

    $owner = Get-OrgName
    $me = Get-MyHandle
    $pattern = $All ? "" : "creator:$me"

    $list = Get-GcDatabaseProjects -Owner $owner -Handle $me

    $ret = @{}
    
    if($Force -or ! $list){

        # Find projects
        $result = Invoke-MyCommand -Command FindProjectByCreator -Parameters @{ owner = $owner ; pattern = $pattern }
        
        # Filter closed projects
        # TODO: this filter is not working. Ignore the filter for the moment
        # $filtered  = $result | Where-Object {$null -ne $_.closedAt}
        $filtered = $result

        # Select attributes to return
        $list = @{}

        foreach($p in $filtered) {
            $key = $p.title -replace '[^a-zA-Z0-9]', '_'
            $n = [pscustomobject]@{
                Title = $p.title
                Owner = $owner
                ProjectNumber = $p.number
                Url = $p.url
                Repos = $p.repositories.nodes.url
            }

            $list.$key= $n
        }

        # Save to cache
        Save-GcDatabaseProjects -Owner $owner -Handle $me -Value $list

        $list = Get-GcDatabaseProjects -Owner $owner -Handle $me
    }

    if(-Not [string]::IsNullOrEmpty($ProjectName)){
        $pn = $list.$ProjectName
        if($null -eq $pn){
            throw "Project '$ProjectName' not found."
        }
        $ret.$ProjectName = $pn
    } else {
        $ret += $list
    }

    return $ret

} Export-ModuleMember -Function getGcProject -Alias gcp

function GetValidProjectNames{
    $projects = getGcProject
    $ret = $projects.keys

    $ret += ""

    return $ret
}

function Show-GcProjects{
    [CmdletBinding()]
    [Alias("scp")]
    param()

    $projects = getGcProject

    $projects.Values | Select-Object Title,ProjectNumber,Owner,Url

} Export-ModuleMember -Function Show-GcProjects -Alias scp