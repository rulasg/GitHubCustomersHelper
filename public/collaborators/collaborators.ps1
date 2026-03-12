class ValidRepoNames : System.Management.Automation.IValidateSetValuesGenerator { [String[]] GetValidValues() { return GetValidRepoNames}}

# https://github.com/githubcustomers/bbva/edit/main/.github/collaborators.yml

function Get-GcRepoCollaboratorsUrl{
    [cmdletbinding()]
    param(
        [Parameter()][ValidateSet([ValidRepoNames])][string]$RepositoryName
    )

    $repo = Get-GcRepo -RepositoryName $RepositoryName

    $url = $repo.url + "/edit/main/.github/collaborators.yml"

    return $url

} Export-ModuleMember -Function Get-GcRepoCollaboratorsUrl