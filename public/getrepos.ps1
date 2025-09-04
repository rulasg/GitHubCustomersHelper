<#
.SYNOPSIS
Gets the GitHubCustomers repository owned by a particular SolutionEngineer
.DESCRIPTION
Gets the GitHubCustomers repository owned by a particular SolutionEngineer

.PARAMETER Handle
The GitHub handle of the SolutionEngineer Custom Property value of the repository owner
#>
function Get-GCRepo {
    param (
        [Parameter(Mandatory,Position=0)][string]$PropertyValue,
        [Parameter()][string]$PropertyName = 'SolutionEngineer'
    )
    $SearchString = "org:githubcustomers props.{property}:{value}"

    $SearchString = $SearchString -replace '{value}', $PropertyValue
    $SearchString = $SearchString -replace '{property}', $PropertyName

    $SearchString | Write-Verbose

    $ret = Search-Repo -SearchString $SearchString 

    return $ret

} Export-ModuleMember -Function Get-GCRepo