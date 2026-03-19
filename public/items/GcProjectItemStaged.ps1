Set-MyInvokeCommandAlias -Alias GetProjectItemStaged -Command 'Get-ProjectItemStaged -owner {owner} -ProjectNumber {projectnumber}'
Set-MyInvokeCommandAlias -Alias ShowProjectItemStaged -Command 'Show-ProjectItemStaged -owner {owner} -ProjectNumber {projectnumber}'
Set-MyInvokeCommandAlias -Alias ShowProjectItemStagedWithItemId -Command 'Show-ProjectItemStaged -owner {owner} -ProjectNumber {projectnumber} -Id {itemid}'
Set-MyInvokeCommandAlias -Alias ResetProjectItemStaged -Command 'Reset-ProjectItemStaged -owner {owner} -ProjectNumber {projectnumber}'
Set-MyInvokeCommandAlias -Alias ResetProjectItemStagedWithItem -Command 'Reset-ProjectItemStaged -owner {owner} -ProjectNumber {projectnumber} -Id {itemid}'


function Get-GcProjectItemStaged{
    [cmdletbinding()]
    [Alias("gcpis")]
    param()

    $gcp = Get-GcProject


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

    $gcp = Get-GcProject

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

    $gcp = Get-GcProject

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
