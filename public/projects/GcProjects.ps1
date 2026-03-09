Set-MyInvokeCommandAlias -Alias FindProjectByCreator -Command 'Find-Project -owner {owner} -pattern creator:{handle}'

class ValidProjectNames : System.Management.Automation.IValidateSetValuesGenerator { [String[]] GetValidValues() { return GetValidProjectNames}}

$script:projectlist = $null
 
function Get-GcProjects {
    [CmdletBinding()]
    param(
        [parameter()][switch]$IncludeClosed,
        [parameter()][switch]$Force
    )

    if(! $Force -and $null -ne $script:projectlist){
        return $script:projectlist
    }

    $me = Get-MyHandle
    $owner = 'githubcustomers'

    $params = @{
        owner = $owner
        handle = $me
    }

    $result = Invoke-MyCommand -Command FindProjectByCreator -Parameters $params

    # Filter closed projects
    # TODO: this filter is not working. Ignore the filter for the moment
    # $filtered  = $result | Where-Object {$null -ne $_.closedAt}
    $filtered = $result

    # Select attributes to return
    $ret = @{}
    
    foreach($p in $filtered) {
        $name = $p.title -replace '[^a-zA-Z0-9]', '_'
        $n = [pscustomobject]@{
            Title = $p.title
            Owner = $owner
            ProjectNumber = $p.number
            Url = $p.url
        }

        $ret.$name= $n
    }

    $script:projectlist = $ret
    
    return $ret

} Export-ModuleMember -Function Get-GcProjects

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