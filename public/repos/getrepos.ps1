
Set-MyInvokeCommandAlias -Alias SearchRepos -Command 'Invoke-SearchRepo -SearchString "{searchstring}"'

class ValidRepoNames : System.Management.Automation.IValidateSetValuesGenerator { [String[]] GetValidValues() { return GetValidRepoNames}}


function Get-GcRepo{
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][ValidateSet([ValidRepoNames])][string]$Name,
        [Parameter(Position=1)][string]$Handle,
        [Parameter()][switch]$Force
    )

    $Handle = [string]::IsNullOrEmpty($Handle) ? $(Get-MyHandle) : $Handle

    $list = Get-GcReposByProperty -PropertyValue $Handle -Force:$Force

    if(-Not [string]::IsNullOrEmpty($Name)){
        return $list.$Name
    } else {
        return $list
    }

} Export-ModuleMember -Function Get-GcRepo

function Show-GcRepos{
    [CmdletBinding()]
    [Alias("scr")]
    param(
        [Parameter(Position=0)][string]$Handle,
        [Parameter()][switch]$Force
    )

    $list = Get-GcRepo -Handle $Handle -Force:$Force

    $list | format-table
    
} Export-ModuleMember -Function Show-GcRepos -Alias scr

function Update-GcRepoList{
    [CmdletBinding()]
    [Alias("ucr")]
    param(
        [Parameter(Position=0)][string]$Handle
    )

    if([string]::IsNullOrEmpty($Handle)){
        $Handle = Get-MyHandle
    }

    $reuslt = Get-GcReposByProperty -PropertyValue $Handle -Force:$true

    "Updated Gc Repos for handle [$Handle]. Found $($reuslt.Count) repos." | Write-MyHost

} Export-ModuleMember -Function Update-GcRepoList -Alias ucr

<#
.SYNOPSIS
Gets the GitHubCustomers repository owned by a particular SolutionEngineer
.DESCRIPTION
Gets the GitHubCustomers repository owned by a particular SolutionEngineer

.PARAMETER Handle
The GitHub handle of the SolutionEngineer Custom Property value of the repository owner
#>
function Get-GcReposByProperty {
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

} Export-ModuleMember -Function Get-GcReposByProperty

function Open-GcRepo{
    [CmdletBinding()]
    [Alias("ocr")]
    param(
        [Parameter(Mandatory,Position=0)][ValidateSet([ValidRepoNames])][string]$Name
    )

    $repo = Get-GcRepo -Name $Name

    $repo.url | Open-MyUrl

} Export-ModuleMember -Function Open-GcRepo -Alias ocr

function Invoke-SearchRepo{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$SearchString
    )
    
    $attributes = 'name,url'

    $command = 'gh search repos {searchstring} --json {attributes}'
    
    $command = $command -replace "{searchstring}", "$($SearchString)"
    $command = $command -replace "{attributes}", "$($attributes)"

    "Calling >>> : " | Write-MyDebug -Object $command -Section "Invoke-SearchRepo"

    $response = Invoke-Expression $Command

    "Response <<< : " | Write-MyDebug -object $response -Section "Invoke-SearchRepo"

    $ret = $response | ConvertFrom-Json

    return $ret
} Export-ModuleMember -Function Invoke-SearchRepo

function GetValidRepoNames{

    $repos = Get-GcRepo
    return $repos.keys
} 