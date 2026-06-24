


class ValidRepoNames : System.Management.Automation.IValidateSetValuesGenerator { [String[]] GetValidValues() { return GetValidRepoNames}}

function Get-GcRepoAccess{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][ValidateSet([ValidRepoNames])][string]$Name
    )

    $owner = "githubcustomers"

    $ret = RepoHelper\Get-RepoAccess -Owner $owner -Repo $Name -Role write

    return $ret

} Export-ModuleMember -Function Get-GcRepoAccess