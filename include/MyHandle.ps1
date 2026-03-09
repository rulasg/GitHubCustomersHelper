Set-MyInvokeCommandAlias -Alias GetGhHandle -Command 'gh api user --jq ".login"'

$Script:myHandle = $null

function Get-MyHandle{
    [CmdletBinding()]
    param()

    if($null -ne $Script:myHandle){
        return $Script:myHandle
    }
    
    $user = Invoke-MyCommand -Command GetGhHandle

    $Script:myHandle = $user
    
    return $user
}