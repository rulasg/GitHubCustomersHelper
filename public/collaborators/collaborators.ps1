
# ######################

# how to Addd a new memver
<#
ipmol HubbersHelper
$repo = "bit21"
$handle = "oanamariadinca"
$c = Get-GcRepoCollaborators $repo
$user = Get-Hubber $handle | Get-RepoUserCobotEntry -Timezone CET | ConvertFrom-Yaml
$user | h2o | Add-GcRepoCollaborator $c -Team github -Timezone CET
$prUrl = Set-GcRepoCollaborators -Collaborators $c -Repo $repo
open $prUrl
#>

# how to remove a new memver
<#
ipmol HubbersHelper
$repo = "bit21"
$handle = "oanamariadinca"
$c = Get-GcRepoCollaborators $repo
$user = Get-Hubber $handle | Get-RepoUserCobotEntry -Timezone CET | ConvertFrom-Yaml
$user | h2o | Add-GcRepoCollaborator $c -Team github -Timezone CET
$prUrl = Set-GcRepoCollaborators -Collaborators $c -Repo $repo
open $prUrl
#>



class ValidRepoNames : System.Management.Automation.IValidateSetValuesGenerator { [String[]] GetValidValues() { return GetValidRepoNames}}

# https://github.com/githubcustomers/bbva/edit/main/.github/collaborators.yml

function Get-GcRepoCollaboratorsUrl{
    [cmdletbinding()]
    param(
        [Parameter()][ValidateSet([ValidRepoNames])][string]$Name
    )

    $repo = Get-GcRepo -Name $Name

    $url = $repo.url + "/edit/main/.github/collaborators.yml"

    return $url

} Export-ModuleMember -Function Get-GcRepoCollaboratorsUrl

function Get-GcRepoCollaboratorsYaml{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][ValidateSet([ValidRepoNames])][string]$Repo
    )

    $owner  = "githubcustomers"

    $yml = gh api "repos/$owner/$Repo/contents/.github/collaborators.yml" --jq .content | base64 -d

    return $yml | out-string

} Export-ModuleMember -Function Get-GcRepoCollaboratorsYaml

function Set-GcRepoCollaboratorsYaml{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][ValidateSet([ValidRepoNames])][string]$Repo,
        [Parameter(Mandatory,ValueFromPipeline)][string]$Yaml
    )
    $Content = $Yaml
    $owner = "githubcustomers"
    $path = ".github/collaborators.yml"
    $branch = "update-collaborators-$(Get-Date -Format yyyyMMddHHmmss)"

    # Get default branch in repo
    $defaultBranch = gh repo view "$owner/$Repo" --json defaultBranchRef --jq '.defaultBranchRef.name'

    # 1) Get default branch and its latest commit SHA
    # 2) Create new branch from default branch tip
    New-RepoBranch -owner $owner -Repo $Repo -NewBranch $branch -baseBranch $defaultBranch

    # 3) Prepare base64 content
    # 4) If file exists, get SHA (required for update)
    # 5) Create/update file in that branch
    Set-RepoFile -Owner $owner -Repo $Repo -Content $Content -path $path -branch $branch

    # 6) Create a pull request for the new branch
    gh pr create --repo "$owner/$Repo" --base "$defaultBranch" --head "$branch" --title "Update $path" --body "Automated update via gh api."

} Export-ModuleMember -Function Set-GcRepoCollaboratorsYaml

function Get-RepoBranches{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][ValidateSet([ValidRepoNames])][string]$Repo,
        [parameter()][switch]$IncludeDefaultBranch
    )

    $owner = "githubcustomers"

    $branches = gh api "repos/$owner/$Repo/branches" --jq '.[].name'

    if($IncludeDefaultBranch){
        $ret = $branches
    } else {
        $defaultBranch = gh repo view "$owner/$Repo" --json defaultBranchRef --jq '.defaultBranchRef.name'
        $ret = $branches | Where-Object {$_ -ne $defaultBranch}

    }

    return $ret

} Export-ModuleMember -Function Get-RepoBranches

function New-RepoBranch{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][ValidateSet([ValidRepoNames])][string]$Repo,
        [Parameter()][string]$owner = "githubcustomers",
        [Parameter(Mandatory)][string]$NewBranch,
        [Parameter()][string]$BaseBranch
    )

    if(-not $BaseBranch){
        $defaultBranch = gh repo view "$owner/$Repo" --json defaultBranchRef --jq '.defaultBranchRef.name'
        $BaseBranch = $defaultBranch
    }

    $baseSha = gh api "repos/$owner/$Repo/git/ref/heads/$BaseBranch" --jq '.object.sha'

    gh api -X POST "repos/$owner/$Repo/git/refs" `
        -f ref="refs/heads/$NewBranch" `
        -f sha="$baseSha"

} Export-ModuleMember -Function New-RepoBranch

function Remove-RepoBranch{
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][ValidateSet([ValidRepoNames])][string]$Repo,
        [Parameter(Mandatory,ValueFromPipeline)][string]$Branch
    )

    process{
        $owner = "githubcustomers"
        if($PSCmdlet.ShouldProcess("$owner/$Repo/$Branch","Remove branch")){
            gh api -X DELETE "repos/$owner/$Repo/git/refs/heads/$Branch"
        }
    }
} Export-ModuleMember -Function Remove-RepoBranch

function Set-RepoFile{
    param(
        [Parameter()][string]$Owner,
        [Parameter(Mandatory)][ValidateSet([ValidRepoNames])][string]$Repo,
        [Parameter(Mandatory)][string]$Content,
        [Parameter()][string]$path,
        [Parameter()][string]$branch
    )

    # Defaults
    $Owner = [string]::IsNullOrEmpty($Owner) ? "githubcustomers" : $Owner
    $path = [string]::IsNullOrEmpty($path) ? ".github/collaborators.yml" : $path
    $branch = [string]::IsNullOrEmpty($branch) ? "update-collaborators-$(Get-Date -Format yyyyMMddHHmmss)" : $branch

    "Ended Set-RepoFile for [$Owner/$Repo/$path] on branch [$branch] <<<" | Write-MyDebug -section "repofile"

    # 3) Prepare base64 content
    $b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Content))

    "Content to Base64: $b64" | Write-MyDebug -section "repofile"

    $urlpath = "repos/$Owner/$Repo/contents/$($path)"
    $fullUrlPath =  "$urlpath"+"?ref=$branch"

    # 4) If file exists, get SHA (required for update)
    $fileSha = $null
    try {
        "Getting SHA for file [$urlpath] in branch [$branch]" | Write-MyDebug -section "repofile"
        $fileSha = gh api "$fullUrlPath" --jq .sha 2>$null
    } catch {}

    "Sha: $fileSha" | Write-MyDebug -section "repofile"

    # 5) Create/update file in that branch
    if ($fileSha) {
        "Updating existing file [$urlpath] in branch [$branch]" | Write-MyDebug -section "repofile"
        gh api -X PUT "$urlpath" `
        -f message="Update $path" `
        -f content="$b64" `
        -f branch="$branch" `
        -f sha="$fileSha"
    } else {
        "Adding  file [$urlpath] in branch [$branch]" | Write-MyDebug -section "repofile"
        gh api -X PUT "$urlpath" `
            -f message="Add $path" `
            -f content="$b64" `
            -f branch="$branch"
    }

    "Ended Set-RepoFile for [$urlpath] on branch [$branch] <<<" | Write-MyDebug -section "repofile"

} Export-ModuleMember -Function Set-RepoFile

function ConvertTo-GcRepoCollaborators{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)][string]$Yaml
    )

    $hash = $Yaml | ConvertFrom-Yaml

    $ret = @{}

    foreach($team in $hash){
        $teamName = $team.team
        $ret.$teamName = @{}

        foreach($member in $team.members){
            $handle = $member.username
            $m = [PsCustomObject]@{
                username = $handle
                name = $member.name
                role = $member.role
                email = $member.email
                timezone = $member.timezone
                location = $member.location
                team = $teamName
            }
            $ret.$teamName.$handle = $m
        }
    }

    return $ret

} Export-ModuleMember -Function ConvertTo-GcRepoCollaborators

# convert a hashtable of collaborators to a yaml string
function ConvertFrom-GcRepoCollaborators{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)][hashtable]$Collaborators
    )

    $ret = @()
    $tag = "  " # Two spaces tab
    $2tab = $tag + $tag


    foreach($team in $Collaborators.Keys){
        $ret += "- team: $team"
        $ret += "  members:"
        
        foreach($member in $Collaborators.$team.Values){
            $ret += $2tab + "- username: $($member.username)"
            $ret += $2tab + "  name: $($member.name)"
            $ret += $2tab + "  email: $($member.email)"
            $ret += $2tab + "  role: $($member.role)"
            $ret += $2tab + "  location: $($member.location)"
            $ret += $2tab + "  timezone: $($member.timezone)"
            $ret += ""
        }
    }

    return $ret | out-string

} Export-ModuleMember -Function ConvertFrom-GcRepoCollaborators

function Add-GcRepoCollaborator{
    [cmdletbinding()]
    param(
        [parameter(Mandatory,Position=0)][object]$Collaborators,
        [Parameter(Mandatory,Position=1)][string]$Team,
        [Parameter(Mandatory,Position=2,ValueFromPipelineByPropertyName)][Alias("github_login")][string]$Username,
        [Parameter(ValueFromPipelineByPropertyName)][string]$Name,
        [Parameter(ValueFromPipelineByPropertyName)][string]$Email,
        [Parameter(ValueFromPipelineByPropertyName)][Alias("title")][string]$Role ,
        [Parameter(ValueFromPipelineByPropertyName)][Alias("country")][string]$Location,
        [Parameter(ValueFromPipelineByPropertyName)][string]$Timezone,

        # force
        [Parameter()][switch]$Force
    )

    $collaborators = $Collaborators ?? @{}
    $collaborators.$Team = $collaborators.$Team ?? @{}

    # Sanity check
    $actual = $collaborators.$Team.$Username
    if($actual){
        Write-Warning "Updating existing collaborator $Username in team $Team"
    } else {
        Write-Verbose "Adding new collaborator $Username to team $Team"
    }

    $m = [PsCustomObject]@{
        username = $Username
        name = $Name
        role = $Role
        email = $Email
        timezone = $Timezone
        location = $Location
    }

    $collaborators.$Team.$Username = $m

    return $collaborators

} Export-ModuleMember -Function Add-GcRepoCollaborator

function Remove-GcRepoCollaborator{
    [cmdletbinding()]
    param(
        [parameter(Position=0,Mandatory)][object]$Collaborators,
        [Parameter(Position=1,Mandatory,ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("github_login")][string]$Username
    )

    $user = $collaborators.values.$Username

    if(-Not $user){
        "User $Username not found in collaborators" | Write-MyError
        return
    }

    $collaborators.$($user.team).Remove($Username)

    return $collaborators

} Export-ModuleMember -Function Remove-GcRepoCollaborator

function Get-GcRepoCollaborators{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][ValidateSet([ValidRepoNames])][string]$Repo
    )

    $yml = Get-GcRepoCollaboratorsYaml -Repo $Repo

    $collaborators = ConvertTo-GcRepoCollaborators -Yaml $yml

    return $collaborators

} Export-ModuleMember -Function Get-GcRepoCollaborators

function Set-GcRepoCollaborators{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][ValidateSet([ValidRepoNames])][string]$Repo,
        [Parameter(Mandatory,ValueFromPipeline)][hashtable]$Collaborators
    )

    $yml = ConvertFrom-GcRepoCollaborators -Collaborators $Collaborators

    Set-GcRepoCollaboratorsYaml -Repo $Repo -Yaml $yml

} Export-ModuleMember -Function Set-GcRepoCollaborators