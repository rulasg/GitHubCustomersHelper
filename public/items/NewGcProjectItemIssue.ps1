class ValidRepoNames : System.Management.Automation.IValidateSetValuesGenerator { [String[]] GetValidValues() { return GetValidRepoNames}}

function New-GcProjectItemIssue{
     [CmdletBinding()]
    [Alias("ncpi")]
    param(
        #ProjectOwner
        [Parameter()][ValidateSet([ValidRepoNames])][string]$RepositoryName,

        [Parameter(Mandatory, Position = 3)][string]$Title,
        [Parameter(Position = 4)][string]$Body,
        [Parameter()][switch]$OpenOnCreation
    )

    $org = Get-OrgName

    # Create Issue
    $url = ProjectHelper\New-ProjectIssueDirect -RepoOwner $org -RepoName $RepositoryName -Title $Title -Body $Body

    if(! $url ){
        "Issue could not be created" | Write-MyError
        return $null
    }

    if( $OpenOnCreation ) {
        Open-Url $url
    }

    return $url
} Export-ModuleMember -Function New-GcProjectItemIssue -Alias ncpi