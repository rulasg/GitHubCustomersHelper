Set-MyInvokeCommandAlias -Alias FindProjectByCreator -Command 'Find-Project -owner {owner} -pattern creator:{handle}'


function Get-GcProjects {
    [CmdletBinding()]
    param(
        [parameter()][switch]$IncludeClosed
    )

    $me = Get-MyHandle
    $owner = 'githubcustomers'

    $params = @{
        owner = $owner
        handle = $me
    }

    $result = Invoke-MyCommand -Command FindProjectByCreator -Parameters $params

    # Filter closed projects
    # TODO: this filter is not working. Ignore the filter for the moment
    # $filtered  = $result | Where-Object {$null -ne $_.closedAt}
    $filtered = $result

    # Select attributes to return
    $ret = @{}
    
    foreach($p in $filtered) {
        $name = $p.title -replace '[^a-zA-Z0-9]', '_'
        $n = [pscustomobject]@{
            Title = $p.title
            Owner = $owner
            ProjectNumber = $p.number
            Url = $p.url
        }

        $ret.$name= $n
    }
    
    return $ret

} Export-ModuleMember -Function Get-GcProjects