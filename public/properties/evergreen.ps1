function Set-GcRepoEvergreenProperty {
    param(
        [string]$Repo,
        [switch]$evergreen_exempt_from_archive,
        [switch]$evergreen_exempt_from_access_review
    )
    if ($evergreen_exempt_from_access_review) {
        Set-RepoProperty -Owner githubcustomers -name evergreen_exempt_from_access_review -Value true -Repo $Repo
    }

    if ($evergreen_exempt_from_archive) {
        Set-RepoProperty -Owner githubcustomers -name evergreen_exempt_from_archive -Value true -Repo $Repo
    }
} export-ModuleMember -Function Set-GcRepoEvergreenProperty


function Get-GcRepoProperties {
    param(
        [string]$Repo
    )
    $properties = Get-RepoProperties -Owner githubcustomers -Repo $Repo
    return $properties
} export-ModuleMember -Function Get-GcRepoProperties