Set-MyInvokeCommandAlias -Alias "Gc_GetNotifications" -Command 'Get-Notification -Force:${force}'

function Show-GcNotifications{
    [cmdletbinding()]
    [Alias("scn")]
    param(
        [Parameter(Position=0)][int]$Ordinal = -1,

        [Parameter()][string[]]$AttributesExtra,


        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        
        [Parameter()][string]$Title,
        [Parameter()][ValidateSet("Issue","Discussion","PullRequest","Release")][string]$Type,

        [Parameter()][ValidateSet(
            "assign",
            "subscribed",
            "comment",
            "author",
            "team_mention",
            "mention",
            "state_change",
            "manual"
        )][string]$Reason,

        [Parameter()][switch]$IncludeUnRead,
        [Parameter()][string]$RepoName,
        [Parameter()][string]$RepoOwner,
        [Parameter()][switch]$Force,

        [Parameter()][Alias("w")][switch]$OpenInBrowser,
        [Parameter()][Alias("p")][switch]$Passthru,
        [Parameter()][Alias("c")][switch]$ClearScreen

    )

    # Attributes to show
    $attribsToSortBy = @("n_Updated")
    $attribsToSelect = @("n_Id","n_UnRead","n_Reason","Id","state","Title","n_Updated")
    $attribs = $attribsToSelect + $AttributesExtra | Select-Object -Unique

    # Get notifications
    $n_list_all = Invoke-Mycommand -Command 'Gc_GetNotifications' -Parameters @{ force = $($Force.IsPresent)}
    "Retrieved $($n_list_all.Count) notifications" | Write-MyDebug -Section "Show-GcNotifications"

    $params = @{
        Title = $Title
        Type = $Type
        Reason = $Reason
        IncludeUnRead = $IncludeUnRead
        RepoName = $RepoName
        RepoOwner = $RepoOwner
        Force = $Force.IsPresent
    }

    # Filter notifications based on parameters
    $n_list = $n_list_all | Select-Notification @params

    # Get items that match noticiations
    $list = $n_list | Get-GcProjectItemWithNotification -Owner $RepoOwner -ProjectNumber $ProjectNumber -Force:$Force.IsPresent

    # Sort
    # To sort properly $list has to contains the required fields for sorting
    $sorted = $list | Sort-Object $attribsToSortBy

    # Select fields to display - This list has to come from $list
    $selected = $sorted | Select-Object -Property $attribs

    # Use Order
    $params2 = @{
        Ordinal = $Ordinal
        OpenInBrowser = $OpenInBrowser
        PassThru = $Passthru
        ClearScreen = $ClearScreen
        ShowProjectItemScriptBlock = { param($parameters) Show-SalesProjectItem @parameters }
    }

    # show all items together
    Use-Order @params2 -List $selected
    
} Export-ModuleMember -Function Show-SalesNotifications -Alias "ssn"