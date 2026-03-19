Set-MyInvokeCommandAlias -Alias FindProjectByCreator -Command 'Find-Project -owner {owner} -pattern creator:{handle}'

class ValidProjectNames : System.Management.Automation.IValidateSetValuesGenerator { [String[]] GetValidValues() { return GetValidProjectNames}}

function Get-GcProjects {
    [CmdletBinding()]
    [Alias("gcp")]
    param(
        [Parameter(Position = 0)][ValidateSet([ValidProjectNames])][string]$ProjectName,
        [parameter()][switch]$IncludeClosed,
        [parameter()][switch]$Force
    )

    $me = Get-MyHandle
    $owner = Get-OrgName

    $params = @{
        owner = $owner
        handle = $me
    }

    $list = Get-GcDatabaseProjects -Owner $owner -Handle $me
    
    if($Force -or ! $list){

        
        $result = Invoke-MyCommand -Command FindProjectByCreator -Parameters $params
        
        # Filter closed projects
        # TODO: this filter is not working. Ignore the filter for the moment
        # $filtered  = $result | Where-Object {$null -ne $_.closedAt}
        $filtered = $result

        # Select attributes to return
        $list = @{}

        foreach($p in $filtered) {
            $name = $p.title -replace '[^a-zA-Z0-9]', '_'
            $n = [pscustomobject]@{
                Title = $p.title
                Owner = $owner
                ProjectNumber = $p.number
                Url = $p.url
            }

            $list.$name= $n
        }

        # Save to cache
        Save-GcDatabaseProjects -Owner $owner -Handle $me -Value $list

        $list = Get-GcDatabaseProjects -Owner $owner -Handle $me
    }

    if(-Not [string]::IsNullOrEmpty($ProjectName)){
        $ret = $list.$ProjectName
    } else {
        $ret = $list
    }

    return $ret

} Export-ModuleMember -Function Get-GcProjects -Alias gcps

function Get-GcProject{
    [CmdletBinding()]
    [Alias("gcp")]
    param(
        [Parameter(Mandatory,Position = 0)][ValidateSet([ValidProjectNames])][string]$ProjectName
    )

    $projects = Get-GcProjects

    return $projects.$ProjectName
} Export-ModuleMember -Function Get-GcProject -Alias gcp

function GetValidProjectNames{
    $projects = Get-GcProjects
    return $projects.keys
} 