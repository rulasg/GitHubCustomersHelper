function Get-GcDatabaseProjects{
    [CmdletBinding()]
    param(

        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][string]$Handle
    )

    $key = getprojectkey $Owner $Handle

    $db = Get-DatabaseKey -Key $key -AsHashtable

    return $db
}

function Save-GcDatabaseProjects{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][string]$Handle,
        [Parameter(Mandatory)][Object]$Value
    )

    $key = getprojectkey $Owner $Handle

    Save-DatabaseKey -Key $key -Value $Value
}

function getprojectkey{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)][string]$Owner,
        [Parameter(Mandatory, Position = 1)][string]$Handle
    )

    $key = "gcprojects_{0}_{1}" -f $Owner, $Handle

    return $key
}