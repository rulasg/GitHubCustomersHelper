
Set-MyInvokeCommandAlias -Alias SearchRepos -Command 'Invoke-SearchRepo -SearchString "{searchstring}"'

class ValidRepoNames : System.Management.Automation.IValidateSetValuesGenerator { [String[]] GetValidValues() { return GetValidRepoNames}}

$script:repoList = @{}

function Get-GcReposMy{
    [CmdletBinding()]
    param(
        [Parameter()][switch]$Force
    )

    $handle = Get-MyHandle

    if($null -ne $script:repoList.$handle -and -not $Force){
        return $script:repoList.$handle
    }

    $ret = Get-GcRepos -PropertyValue $handle -Force:$Force
    
    $script:repoList.$handle = $ret
    
    return $ret

} Export-ModuleMember -Function Get-GcReposMy

<#
.SYNOPSIS
Gets the GitHubCustomers repository owned by a particular SolutionEngineer
.DESCRIPTION
Gets the GitHubCustomers repository owned by a particular SolutionEngineer

.PARAMETER Handle
The GitHub handle of the SolutionEngineer Custom Property value of the repository owner
#>
function Get-GcRepos {
    param (
        [Parameter(Mandatory,Position=0)][string]$PropertyValue,
        [Parameter()][string]$PropertyName = 'SolutionEngineer',
        [Parameter()][switch]$Force
    )

    $org = Get-OrgName

    $SearchString = "org:{org} props.{property}:{value}"

    $SearchString = $SearchString -replace '{org}', $org
    $SearchString = $SearchString -replace '{value}', $PropertyValue
    $SearchString = $SearchString -replace '{property}', $PropertyName

    $SearchString | Write-Verbose

    $response = Invoke-MyCommand -Command SearchRepos -Parameters @{searchstring=$SearchString}

    $ret = @{}
    foreach($r in $response){
        $n = [pscustomobject]@{
            name = $r.name
            url = $r.url
        }
        $ret.$($r.name) = $n
    }

    return $ret

} Export-ModuleMember -Function Get-GcRepos

function Get-GcRepo{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][ValidateSet([ValidRepoNames])][string]$RepositoryName
    )

    $repos = Get-GcReposMy
    return $repos.$RepositoryName
} Export-ModuleMember -Function Get-GcRepo

function Invoke-SearchRepo{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$SearchString
    )
    
    $attributes = 'name,url'

    $command = 'gh search repos {searchstring} --json {attributes}'
    
    $command = $command -replace "{searchstring}", "$($SearchString)"
    $command = $command -replace "{attributes}", "$($attributes)"

    $command | Write-Verbose

    $ret = Invoke-Expression $Command | ConvertFrom-Json

    return $ret
} Export-ModuleMember -Function Invoke-SearchRepo

function GetValidRepoNames{

    $repos = Get-GcReposMy
    return $repos.keys
} 