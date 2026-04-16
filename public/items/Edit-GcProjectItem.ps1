Set-MyInvokeCommandAlias -Alias "EditSalesProjectItem" -Command 'Invoke-EditSalesProjectItem -Json ''{json}'''

class ValidStatus : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() { 
        return @("Todo","In Progress","Done","Answered") } 
}

class ValidPendingOn : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() { 
        return @("None","Microsoft", "Client", "GitHub_Eng")
    } 
}


function Edit-GcProjectItem {
    [CmdletBinding()]
    [Alias("ecpi")]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)][string]$Id,

        [Parameter()][Alias("MM")][switch]$Commit,
        [Parameter()][Alias("F")][switch]$Force,
        [Parameter()][Alias("O")][switch]$OpenInBrowser,
        [Parameter()][Alias("BL")][switch]$BodyLongText,
        [Parameter()][Alias("CL")][switch]$AddCommentLongText,

        # Fields
        [Parameter()][hashtable]$Fields,
        
        # FieldName
        [Parameter(ValueFromPipelineByPropertyName)][string]$FieldName,
        [Parameter(ValueFromPipelineByPropertyName)][string]$Value,

        # Links
        # [Parameter()][Alias("NO")][string]$NotesLink,
        # [Parameter()][Alias("IM")][string]$IM_Link,
        # [Parameter()][Alias("SU")][string]$SupportLink,


        # Content
        [Parameter()][Alias("T")][string]$Title,
        [Parameter()][Alias("B")][string]$Body,
        # [Parameter()][Alias("C")][string]$Comment,
        # [Parameter()][Alias("Fl")][string]$Flag,

        # Comment

        # AddComment
        [Parameter()][Alias("AC")][string]$AddComment,

        # Flag

        #NCC / When / WhenDate
        # [Parameter()][ValidateSet([ValidWhenNames])][Alias("W")][string]$When,
        # [Parameter()][Alias("WD")][string]$WhenDate,

        # Status
        [Parameter()][ValidateSet([ValidStatus])][Alias("St")][string]$Status,

        # MyType
        # [Parameter()][ValidateSet([ValidMyType])][Alias("M")][string]$MyType,

        # Topic
        # [Parameter()][ValidateSet([ValidTopic])][Alias("To")][string]$Topic,

        # Priority
        # [Parameter()][ValidateSet([ValidPriority])][Alias("P")][string]$Priority,

        # Severity
        # [Parameter()][ValidateSet([ValidSeverity])][Alias("S")][string]$Severity,

        # Size
        # [Parameter()][ValidateSet([ValidSize])][Alias("Z")][string]$Size,

        # PendingOn
        [Parameter()][ValidateSet([ValidPendingOn])][Alias("PO")][string]$PendingOn,
        [Parameter()][Alias("POA")][string]$PendingOnAlias,

        # # Postpone
        # [Parameter()][ValidateSet([ValidWhenNames])][Alias("R")][string]$Postpone,
        # [Parameter()][Alias("RD")][string]$PostponeDate,

        # # Punded parameters
        [Parameter()][Alias("D")][switch]$DefaultValues,
        [Parameter()][switch]$Close,
        [Parameter()][switch]$Backlog,
        # [Parameter()][switch]$FollowUp,
        [Parameter()][switch]$Answered,
        # [Parameter()][switch]$Ready,
        # [Parameter()][switch]$ToReady,
        # [Parameter()][Alias("N")][switch]$Next,
        # [Parameter()][Alias("NR")][switch]$NextReset,
        [Parameter()][switch]$NormalizeTitle,
        
        [Parameter()][string]$AddSupportNumber

    )

    begin {

        if( $BodyLongText ) {
            $Body = Get-LongText -Text $Body
        }

        if( $AddCommentLongText ) {
            $AddComment = Get-LongText -Text $AddComment
        }

        # Add Support number
        if([string]::IsNullOrWhiteSpace($AddSupportNumber) -eq $false){
            $tag = "- Support: $AddSupportNumber"
            $Title  = "{{Title}} $tag"
        }

        # Default
        if($DefaultValues){
            # $Size     = [string]::IsNullOrWhiteSpace($Size)     ? 'M'              : $Size
            # $Topic    = [string]::IsNullOrWhiteSpace($Topic)    ? 'Client'         : $Topic
            # $MyType   = [string]::IsNullOrWhiteSpace($MyType)   ? 'Task'           : $MyType
            $Status   = [string]::IsNullOrWhiteSpace($Status)   ? 'Todo' : $Status
            # $Priority = [string]::IsNullOrWhiteSpace($Priority) ? 'Normal'         : $Priority
            # $Severity = [string]::IsNullOrWhiteSpace($Severity) ? 'High'           : $Severity
            
            # Do not edit but leave this parameters flow the edit process
        }

        # # Close
        # if ($Close) {
        #     $Status = "Done"
        #     $When = "None"
        #     $NextUp = "None"

        #     # Do not edit but leave this parameters flow the edit process
        # }

        # # Backlog
        # if ($Backlog) {
        #     $Status = "Todo"
        #     $When = "None"
        #     $NextUp = "None"

        #     # Do not edit but leave this parameters flow the edit process
        # }

        # # FollowUp
        # if ($FollowUp) {
        #     $Status = "Followup"
        #     $When = "None"
        #     $NextUp = "None"

        #     # Do not edit but leave this parameters flow the edit process
        # }

        # Answered
        if ($Answered) {
            $Status = "Answered"
            # $When = "None"
            # $NextUp = "None"
            # Do not edit but leave this parameters flow the edit process
        }

        # # NextUp
        # if ($Next) {
        #    $Status = "ActionRequired"
        #     $When = "None"
        #    $NextUp = "Bomb"

        #     # Do not edit but leave this parameters flow the edit process
        # }

        # # NextUp reset
        # if ($NextReset) {
        #     $NextUp = "None"

        #     # Do not edit but leave this parameters flow the edit process
        # }

        # # Ready
        # if ($Ready) {
        #     $When = "None"
        #     $Status = "ActionRequired"
        #     $NextUp = "None"

        #     # Do not edit but leave this parameters flow the edit process
        # }

        # # Postpone
        # if (-Not [string]::IsNullOrWhiteSpace($Postpone) -or -Not [string]::IsNullOrWhiteSpace($PostponeDate)) {
        #     $whenString = Get-When -When $Postpone -WhenDate $PostponeDate

        #     $Status = "Planned"
        #     $WhenDate = $whenString
        #     $NextUp = "None"

        #     # Do not edit but leave this parameters flow the edit process
        # }
    }

    process {

        # Begin determine that we should not run any pipe object
        if( $quit ){ return }

        # Resolve $item
        $item = Get-GcProjectItem -Id $Id
        # if item is null try if the $ID is the item url
        if(-not $item){ $item = Get-GcProjectItemByUrl -Url $Id }
        if(-not $item){ Write-MyError "Item with Id or Url '$Id' not found." ; return }

        $owner = $item.projectOwner
        $projectNumber = $item.projectNumber

        # Commit check
        if ($commmit) {
            $staged = ProjectHelper\Get-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber

            if ($staged) {
                throw "There are staged items on project $owner#$projectNumber. Please commit or reset them before updating items"
            }
        }

        # Get Item
        if($force){ Update-Project -Owner $owner -ProjectNumber $ProjectNumber }

        #Set default parameters for edit process
        $params = @{
            owner         = $Owner
            projectnumber = $ProjectNumber
        }

        # Focus on Id
        # TODO: Check for QQ command when it makes sense
        $params.Id = $item.Id # $params.Id = [string]::IsNullOrWhiteSpace($Id) ? $(Invoke-QQ_Get_G) : $Id

        if([string]::IsNullOrWhiteSpace($params.Id) ){
            Write-MyError "Id is required. Please provide it through pipeline, -Id parameter or set it as default using 'g' quick command"
            return
        }

        # Process parameters that are standard to an issue. Not specific to Sales project.
        # Inherit Edit-ProjectItem logic callinf it with specific parameters

        $editparams = @{}

        if ( ! [string]::IsNullOrEmpty($FieldName))          { $editparams.FieldName = $FieldName }
        if ( ! [string]::IsNullOrEmpty($Value))              { $editparams.Value = $Value }
        if ( ! [string]::IsNullOrEmpty($Fields))             { $editparams.Fields = $Fields }
        if ( ! [string]::IsNullOrEmpty($Title))              { $editparams.Title = $Title }
        if ( ! [string]::IsNullOrEmpty($Body))               { $editparams.Body = $Body }
        if ( ! [string]::IsNullOrEmpty($AddComment))         { $editparams.AddComment =$AddComment }
        if ( ! [string]::IsNullOrEmpty($Status))             { $editparams.Status = $Status }
        
        if ( $Force )              { $editparams.Force = $true}
        if ( $BodyLongText )       { $editparams.BodyLongText = $true}
        if ( $Close )              { $editparams.Close = $true}
        if ( $Backlog )            { $editparams.Backlog = $true}
        # if ( $Ready )              { $editparams.Ready = $true}
        if ( $NormalizeTitle )     { $editparams.NormalizeTitle = $true}
        if ( $AddCommentLongText ) { $editparams.AddCommentLongText = $true}
        if ( $DefaultValues )      { $editparams.DefaultValues = $true}

        # Check if there are parameters calls to call Edti-ProjectItem
        if($editparams.Count -gt 0){

            $editparams += $params

            "Edit-ProjectItem with parameters:" | Write-Mydebug -Section "Edit-ProjectItem" -Object $editparams
            
            editSalesProjectItem $editparams
        }

        # Process values not standard and unique to sales
        # all changes goes to the $fields variable for later call to Edit-ProjectItem

        $fields = @{}

        # function edit($params) { Invoke-MyCommand -Command 'Edit-ProjectItem' -Parameters $params }

        # # When
        # if (-Not [string]::IsNullOrWhiteSpace($When) -or -Not [string]::IsNullOrWhiteSpace($WhenDate)) {
        #     $fields."NCC" = Get-When -When $When -WhenDate $WhenDate
        # }

        # # MyType parameter
        # if (-Not [string]::IsNullOrWhiteSpace($MyType)) {
        #     $fields."MyType" = "$(Get-FieldOptionValue $MYTYPE_FIELD_INFO $MyType)"
        # }

        # # Topic parameter
        # if (-Not [string]::IsNullOrWhiteSpace($Topic)) {
        #     $fields."Topic" = "$(Get-FieldOptionValue $TOPIC_FIELD_INFO $Topic)"
        # }

        # # NextUp Field value
        # if (-Not [string]::IsNullOrWhiteSpace($NextUp)) {
        #     $fields."NextUp" = "$(Get-FieldOptionValue $NEXTUP_FIELD_INFO $NextUp)"
        # }

        # # Priority parameter
        # if (-Not [string]::IsNullOrWhiteSpace($Priority)) {
        #     $fields."Priority" = "$(Get-FieldOptionValue $PRIORITY_FIELD_INFO $Priority)"
        # }

        # # Severity parameter
        # if (-Not [string]::IsNullOrWhiteSpace($Severity)) {
        #     $fields."Severity" = "$(Get-FieldOptionValue $SEVERITY_FIELD_INFO $Severity)"
        # }

        # # Size parameter
        # if (-Not [string]::IsNullOrWhiteSpace($Size)) {
        #     $fields."Size" = "$(Get-FieldOptionValue $SIZE_FIELD_INFO $Size)"
        # }

        # Comment parameter
        if (-Not [string]::IsNullOrWhiteSpace($Comment)) {
            $fields."Comment" = $Comment
            $Comment = ""
        }

        # # Flag parameter
        # if (-Not [string]::IsNullOrWhiteSpace($Flag)) {
        #     $fields."Flag" = "$Flag"
        #     $Flag = ""
        # }

        # # NotesLink parameter
        # if (-Not [string]::IsNullOrWhiteSpace($NotesLink)) {
        #     $fields."NotesLink" = "$NotesLink"
        #     $NotesLink = ""
        # }

        # # IM_Link parameter
        # if ($IM_Link) {
        #     $fields."IM_Link" = "$IM_Link"
        #     $IM_Link = ""
        # }

        # # SupportLink parameter
        # if ($SupportLink) {
        #     $fields."SupportLink" = "$SupportLink"
        #     $SupportLink = ""
        # }

        # PendingOn parameter
        if (-Not [string]::IsNullOrWhiteSpace($PendingOn) -OR -Not [string]::IsNullOrWhiteSpace($PendingOnAlias)) {
            $fields."PendingOn" = Get-PendingOn -PendingOn $PendingOn -PendingOnAlias $PendingOnAlias
        }

        # Execute Feilds if they have content
        if($fields -and $fields.Count -gt 0){
            $params.fields = $fields
            "Edit-ProjectItem with parameters:" | Write-Mydebug -Section "Edit-ProjectItem" -Object $params 
            editSalesProjectItem $params
        }

        if ($OpenInBrowser) {
            $item = Get-SalesProjectItem -ItemId $Id
            if ($null -ne $item) {
                "opening $($item.Url) in browser" | Write-Verbose
    
                Open-Url -Url $item.url
            }
        }
    }

    end {
        # If Commit is specified, sync the staged items
        if ($Commit) {
            Sync-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
        }

    }

} Export-ModuleMember -Function Edit-GCProjectItem -Alias "ecpi"

function Get-PendingOn {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)][string]$PendingOn,
        [Parameter()][string]$PendingOnAlias
    )

    if (-Not [string]::IsNullOrWhiteSpace($PendingOnAlias)) {
        return $PendingOnAlias
    }

    # Return PendingOn based on input
    return $PendingOn
}

function editSalesProjectItem($params){

    $json = $params | ConvertTo-Json -compress

    $response = Invoke-MyCommand -Command "EditSalesProjectItem" -Parameters @{ json = $json }

    return $response

}

function Invoke-EditSalesProjectItem{
    [CmdletBinding()]
    param(
        [Parameter()][string] $Json
    )

    $params = $Json | ConvertFrom-Json -AsHashtable

    $result = ProjectHelper\Edit-ProjectItem @params

    return $result

} Export-ModuleMember -Function Invoke-EditSalesProjectItem