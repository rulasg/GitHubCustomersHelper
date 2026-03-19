function Get-GcNotificationsProjectItemValueEditParameters {
    [CmdletBinding()]
    [Alias ("gcn")]
    param ()
     
    $items = Get-GcProjectItems -Attributes id,url,projectUrl
    
    $parameters = $items | Get-NotificationsProjectItemValueEditParameters -FieldName "Comment" -Value "🔔 {{Comment}}"

    return $parameters

} Export-ModuleMember -Function Get-GcNotificationsProjectItemValueEditParameters -Alias gcn