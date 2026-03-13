function Get-GcDatabaseRepos{
    [CmdletBinding()]
    param(

        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][string]$PropertyName,
        [Parameter(Mandatory)][string]$Handle
    )

    $key = getrepokey -Owner $Owner -PropertyName $PropertyName -Handle $Handle

    $db = Get-DatabaseKey -Key $key -AsHashtable

    return $db
}

function Save-GcDatabaseRepos{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][string]$PropertyName,
        [Parameter(Mandatory)][string]$Handle,
        [Parameter(Mandatory)][Object]$Value
    )

    $key = getrepokey -Owner $Owner -PropertyName $PropertyName -Handle $Handle

    Save-DatabaseKey -Key $key -Value $Value
}

function getrepokey{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)][string]$Owner,
        [Parameter(Mandatory, Position = 1)][string]$PropertyName,
        [Parameter(Mandatory, Position = 2)][string]$Handle
    )

    $key = "gcrepos_{0}_{1}_{2}" -f $Owner, $PropertyName, $Handle

    return $key
}