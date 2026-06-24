Set-MyInvokeCommandAlias -Alias GetProjectItemStaged -Command 'Get-ProjectItemStaged -owner {owner} -ProjectNumber {projectnumber}'
Set-MyInvokeCommandAlias -Alias ShowProjectItemStaged -Command 'Show-ProjectItemStaged -owner {owner} -ProjectNumber {projectnumber}'
Set-MyInvokeCommandAlias -Alias ShowProjectItemStagedWithItemId -Command 'Show-ProjectItemStaged -owner {owner} -ProjectNumber {projectnumber} -Id {itemid}'
Set-MyInvokeCommandAlias -Alias ResetProjectItemStaged -Command 'Reset-ProjectItemStaged -owner {owner} -ProjectNumber {projectnumber}'
Set-MyInvokeCommandAlias -Alias ResetProjectItemStagedWithItem -Command 'Reset-ProjectItemStaged -owner {owner} -ProjectNumber {projectnumber} -Id {itemid}'
Set-MyInvokeCommandAlias -Alias SyncProjectItemStaged -Command 'Sync-ProjectItemStaged -owner {owner} -ProjectNumber {projectnumber}'

Set-MyInvokeCommandAlias -Alias TestProjectItemStaged -Command 'Test-ProjectItemStaged -owner {owner} -ProjectNumber {projectnumber}'


function Get-GcProjectItemStaged{
    [cmdletbinding()]
    [Alias("gcpis")]
    param()

    $gcp = getGcProject


    foreach($project in $gcp.Values){
        
        $params = @{owner=$project.Owner; projectnumber=$project.ProjectNumber}
        
        Invoke-MyCommand -Command GetProjectItemStaged -Parameters $params
    }

} Export-ModuleMember -Function Get-GcProjectItemStaged -Alias gcpis

function Show-GcProjectItemStaged{
    [cmdletbinding()]
    [Alias("scpis")]
    param(
        [Parameter(ValueFromPipelineByPropertyName)][Alias("id")][string]$ItemId
    )

    $gcp = getGcProject

    foreach($project in $gcp.Values){

        $params = @{owner=$project.Owner; projectnumber=$project.ProjectNumber}

        if(-Not [string]::IsNullOrEmpty($ItemId)){
            $params.itemid = $ItemId
            Invoke-MyCommand -Command ShowProjectItemStagedWithItemId -Parameters $params
        } else {
            Invoke-MyCommand -Command ShowProjectItemStaged -Parameters $params
        }
    }
} Export-ModuleMember -Function Show-GcProjectItemStaged -Alias scpis

function Reset-GcProjectItemStaged{
    [cmdletbinding()]
    [Alias("rcpis")]
    param(
        [Parameter(ValueFromPipelineByPropertyName)][Alias("id")][string]$ItemId
        )

    $gcp = getGcProject

    foreach($project in $gcp.Values){
        
        $params = @{owner=$project.Owner; projectnumber=$project.ProjectNumber}

        if(-Not [string]::IsNullOrEmpty($ItemId)){
            $params.itemid = $ItemId
            Invoke-MyCommand -Command ResetProjectItemStagedWithItem -Parameters $params
        } else {
            Invoke-MyCommand -Command ResetProjectItemStaged -Parameters $params
        }
    }

} Export-ModuleMember -Function Reset-GcProjectItemStaged -Alias rcpis

function Sync-GcProjectItemStaged{
    [cmdletbinding()]
    [Alias("ccommit","yyc")]
    param(
        [Parameter(ValueFromPipelineByPropertyName)][Alias("id")][string]$ItemId
        )

    $gcp = getGcProject

    foreach($project in $gcp.Values){
        
        $params = @{owner=$project.Owner; projectnumber=$project.ProjectNumber}

        $dirty = Invoke-MyCommand -Command TestProjectItemStaged -Parameters $params

        if($dirty){
            Invoke-MyCommand -Command SyncProjectItemStaged -Parameters $params
        }
    }

} Export-ModuleMember -Function Sync-GcProjectItemStaged -Alias ccommit,yyc