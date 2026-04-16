class ValidRepoNames : System.Management.Automation.IValidateSetValuesGenerator { [String[]] GetValidValues() { return GetValidRepoNames}}

function New-GcProjectItemIssue{
     [CmdletBinding()]
    [Alias("ncpi")]
    param(
        #ProjectOwner
        [Parameter(Mandatory,Position = 0)][ValidateSet([ValidRepoNames])][Alias("R")][string]$RepositoryName,
        [Parameter(Mandatory, Position = 1)][Alias("T")][string]$Title,
        [Parameter(Position = 2)][Alias("B")][string]$Body,
        [Parameter()][switch]$OpenOnCreation
    )

    $org = Get-OrgName

    # Create Issue
    $url = ProjectHelper\New-ProjectIssueDirect -RepoOwner $org -RepoName $RepositoryName -Title $Title -Body $Body

    if(! $url ){
        "Issue could not be created" | Write-MyError
        return $null
    }

    # TODO: Need to add the item to the proper project
    # for this we need link project with repo

    if( $OpenOnCreation ) {
        Open-Url $url
    }

    return $url
} Export-ModuleMember -Function New-GcProjectItemIssue -Alias ncpi