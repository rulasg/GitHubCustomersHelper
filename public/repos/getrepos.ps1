
Set-MyInvokeCommandAlias -Alias SearchRepos -Command 'Invoke-SearchRepo -SearchString "{searchstring}"'

class ValidRepoNames : System.Management.Automation.IValidateSetValuesGenerator { [String[]] GetValidValues() { return GetValidRepoNames}}

function Get-GcReposMy{
    [CmdletBinding()]
    param(
        [Parameter()][switch]$Force
    )

    $handle = Get-MyHandle

    $ret = Get-GcRepos -PropertyValue $handle -Force:$Force

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

    $Owner = Get-OrgName

    # Get cache
    $cache = Get-GcDatabaseRepos -Owner $Owner -PropertyName $PropertyName -Handle $PropertyValue

    # check if empty
    if($Force -or ! $cache){

        $SearchString = "org:{org} props.{property}:{value}"

        $SearchString = $SearchString -replace '{org}', $Owner
        $SearchString = $SearchString -replace '{value}', $PropertyValue
        $SearchString = $SearchString -replace '{property}', $PropertyName

        $SearchString | Write-Verbose

        $response = Invoke-MyCommand -Command SearchRepos -Parameters @{searchstring=$SearchString}

        $list = @{}
        foreach($r in $response){
            $n = [pscustomobject]@{
                name = $r.name
                url = $r.url
            }
            $list.$($r.name) = $n
        }

        # Save to cache
        Save-GcDatabaseRepos -Owner $Owner -PropertyName $PropertyName -Handle $PropertyValue -Value $list

        $cache = Get-GcDatabaseRepos -Owner $Owner -PropertyName $PropertyName -Handle $PropertyValue
    }

    #return cache
    return $cache

} Export-ModuleMember -Function Get-GcRepos

function Get-GcRepo{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][ValidateSet([ValidRepoNames])][string]$Name
    )

    $repos = Get-GcReposMy
    return $repos.$Name
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