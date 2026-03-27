Set-MyInvokeCommandAlias -Alias GetProjectItems -Command 'Get-ProjectItems -owner {owner} -projectNumber {ProjectNumber} -IncludeDone'
Set-MyInvokeCommandAlias -Alias GetProjectItemsForce -Command 'Get-ProjectItems -owner {owner} -projectNumber {ProjectNumber} -IncludeDone -Force'

function Get-AllItems{
    [CmdletBinding()]
    param(
        # force
        [Parameter()][switch]$IncludeDone,
        [Parameter()][switch]$Force
    )

    ">>>" | Write-MyDebug -Section "Get-AllItems"

    $gcp = Get-GcProject

    $itemlist = @{}

    foreach($project in $gcp.Values){

        $params = @{owner=$project.Owner; ProjectNumber=$project.ProjectNumber}

        if($Force){
            $items = Invoke-MyCommand -Command GetProjectItemsForce -Parameters $params
        } else {
            $items = Invoke-MyCommand -Command GetProjectItems -Parameters $params
        }

        foreach($item in $items){
            $id = $item.id
            
            $itemlist.$id = @{
                Id = $id
                databaseId = $item.databaseId
                projectNumber = $project.ProjectNumber
                projectOwner = $project.Owner
                RepositoryName = $item.RepositoryName
                RepositoryOwner = $item.RepositoryOwner
                projectUrl = $project.Url
                Status = $item.status
                Title = $item.title
                State = $item.state
                Url = $item.url
            }
        }
    }

    "<<<" | Write-MyDebug -Section "Get-AllItems"

    return $itemlist

}