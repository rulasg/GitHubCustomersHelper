function Show-GCProjectItem {
    [CmdletBinding()]
    [Alias("cshpi")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline, Position = 0)][Alias("id")][string]$ItemId,
        [Parameter()][Alias("A")][switch]$AllComments,
        [Parameter()][Alias("E")][switch]$OpenInEditor,
        [Parameter()][Alias("W")][switch]$OpenInBrowser,
        [Parameter()][Alias("C")][switch]$ClearScreen
    )

    process {

        $item = Get-GcProjectItem -Id $ItemId
        $owner = $item.projectOwner
        $projectNumber = $item.projectNumber

        # Get notification by URL. Donot use UrlContent to avoid sending emtpy url with Drafts and getting more than one notification back
        $notification = Get-Notification -Url $item.url

        # $statusColor = getStatusColor -Status $item.Status

        $fieldsToShow = @()
        $hideNotifications  = $true

        # notifiations line
        $fieldsToShow += @(
            @{Name = "Icon"         ; Value = $($notification.Id ? "🔔" : "")  ; Color = ""        ; Prefix = "" ; HideIfEmpty = $hideNotifications }
            @{Name = "n_Id"         ; Value = $notification.id                 ; Color = "Yellow"  ; Prefix = "" ; HideIfEmpty = $hideNotifications }
            @{Name = "n_Reason"     ; Value = $notification.Reason             ; Color = "Yellow"  ; Prefix = "" ; HideIfEmpty = $hideNotifications }
        )

        # Fields line
        $fields = @(
            @{Name = "projectTitle" ; Color = "DarkBlue"; Prefix = "" ; BetweenBrackets = $true ; HideIfEmpty = $false }

            # @{Name = "MyType" }
            # @{Name = "Topic" }
            # NGZPS
            @{Name = "Status"         ; Value = $item.Status                                                       }
            # @{Name = "NextUp"         ; Value = $item.NextUp          ; Color = "Magenta"     ; Prefix = "NextUp:" ; HideIfEmpty = $true }
            # @{Name = $GTD_FIELD_NAME  ; Value = $item.$GTD_FIELD_NAME  ; Color = "Cyan"       ; Prefix = "GTD:"                          }
            # @{Name = "Size"           ; Value = $item.Size            ; Color = "DarkGreen"   ; Prefix = "Z:"                            }
            # @{Name = "Priority"       ; Value = $item.Priority        ; Color = "Red"         ; Prefix = "P:"                            }
            # @{Name = "Severity"       ; Value = $item.Severity        ; Color = "DarkYellow"  ; Prefix = "S:"                            }
            # @{NAME = $S_STATUS_NAME   ; Value = $item.$S_STATUS_NAME   ; Color = "White"      ; Prefix = "$($S_STATUS_NAME):"            }
            
            # @{Name = "NCC"      ; Value = $item.NCC     ; Color = "DarkGray" } 
        )


        #Empty line
        $fieldsToShow += @(
            @{Name = "" ; Color = "White"; Prefix = "" ; BetweenBrackets = $true; HideIfEmpty = $true }
        )

        $fieldsToShow += @(
            @{Name = "PendingOn"  ; Color = "DarkGreen"; Prefix = "> PO: " ; BetweenQuotes = $false ; HideIfEmpty = $true }
        )

        $fieldsToShow += @(
            @{Name = "Comment"  ; Color = "White"; Prefix = "> CM: " ; BetweenQuotes = $false ; HideIfEmpty = $true }
        )

        # $fieldsToShow += @(
        #     # Use DefaultValue as a space to hide the label when no value is present
        #     @{Name = "IM_Link"  ; Color = "White"; Prefix = "> IM: " ; BetweenQuotes = $false ; HideIfEmpty = $true }
        # )

        $fieldsToShow += @(
            @{Name = "NotesLink"  ; Color = "White"; Prefix = "> Notes: " ; BetweenQuotes = $false ; HideIfEmpty = $true }
        )

        $fieldsToShow += @(
            @{Name = "SupportLink"  ; Color = "White"; Prefix = "> Support: " ; BetweenQuotes = $false ; HideIfEmpty = $true }
        )

        # Clear screen before showing item
        # TODO: remove this when we add this switch in Show-ProjectItem
        if($ClearScreen){
            Clear-Host
        }

        $params=@{
            Owner = $owner
            ProjectNumber = $projectNumber
            ItemId = $ItemId
            AllComments = $AllComments
            OpenInEditor = $OpenInEditor
            OpenInBrowser = $OpenInBrowser
            ClearScreen = $ClearScreen
            FieldsToShow = $fields,$fieldsToShow
        }

        ProjectHelper\Show-ProjectItem @params

    }
} Export-ModuleMember -Function Show-GcProjectItem -Alias("cshpi")