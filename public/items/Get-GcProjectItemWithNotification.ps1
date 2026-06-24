function Get-GcProjectItemWithNotification {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)][object[]]$NotificationsList,
        [Parameter()][switch]$Force
    )

    begin {

        if($null -eq (Import-Dependency -Name NotificationHelper)){ throw "Failed to import dependencies" }

        $n_list = @()
    }

    process{
        if($NotificationsList){
            $n_list += $NotificationsList
        } else {
            return
        }
    }

    end{

        if($n_list.Length -eq 0){
            # get notifications
            "Gc_GetNotifications >>>" | Write-MyDebug -Section "Get-GcProjectItemWithNotification"
            $n_list = Invoke-Mycommand -Command 'Gc_GetNotifications' -Parameters @{ force = $($Force.IsPresent)}
            "Gc_GetNotifications <<<" | Write-MyDebug -Section "Get-GcProjectItemWithNotification"

            "Retrieved $($n_list.Count) notifications" | Write-MyDebug -Section "Get-GcProjectItemWithNotification"
        }

        $ret = @()
        
        foreach($noti in $n_list){
            $item = Get-GcProjectItemByUrl -Url $noti.Url
            # $item = $items | Where-Object { $_.urlContent -eq $noti.Url }
            
            if($item.count -ne 1){
                "Found $($item.count) items with url '$($noti.Url)' in project '$projectNumber' owned by '$owner'. Expected to find exactly 1. Skipping this notification." | Write-MyDebug -Section "Get-GcProjectItemWithNotification"
                continue
            }
            
            if($item){
                
                $item | Add-Member -MemberType NoteProperty -Name "n_Id" -Value $noti.id
                $item | Add-Member -MemberType NoteProperty -Name "n_Reason" -Value $noti.Reason
                $item | Add-Member -MemberType NoteProperty -Name "n_UnRead" -Value $noti.UnRead
                $item | Add-Member -MemberType NoteProperty -Name "n_Updated" -Value $noti.Updated
                
                $item | Add-Member -MemberType NoteProperty -Name "Notification" -Value ([pscustomobject]$noti)
                
                $ret += $item
            }
        }
        
        return $ret
    }

} Export-ModuleMember -Function Get-GcProjectItemWithNotification

function Test-Found ($item){
    
    if ($null -eq $item) {
        return $false
    }

}