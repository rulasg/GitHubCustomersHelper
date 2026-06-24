function Get-GcProjectItemNotInProject{
    [CmdletBinding()]
    [Alias('ggnip')]
    param(
        #owner
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        # reponmae
        [Parameter()][string]$RepoName,
        [Parameter()][switch]$Force
    )

    if([string]::IsNullOrEmpty($RepoName)){
        $l = Get-GcProjectItems -PassThru -Force:$Force
    } else {
        $l = Get-GcProjectItems -PassThru -RepositoryName $RepoName -Force:$Force
    }

    "Found $($l.Count) items in the project $Owner/$ProjectNumber" | Write-MyDebug -section "GcProjectItemNotInProject"

    $ret = @()

    $l | ForEach-Object{
        $i = ProjectHelper\Get-ProjectItemByUrl -Url $_.Url -Owner $Owner -ProjectNumber $ProjectNumber
         if( $null -eq $i){
            "Item $($_.Url) ✅" | Write-MyDebug -section "GcProjectItemNotInProject"
            $ret += [pscustomobject] $_
        } else {
            "Item $($_.Url) ❌" | Write-MyDebug -section "GcProjectItemNotInProject"
        }
    }

    return $ret

} export-ModuleMember -Function Get-GcProjectItemNotInProject -Alias ggnip