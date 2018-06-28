    Param
    (
    [String]$AlertName,
    [String]$SubscriptionID,
    [String]$AlertID,
    [String]$AlertPath,
    [String]$AlertDisplayName,
    [String]$TicketId,
    [String]$ResolutionState,
    [String]$StopEscapingChar,
    [String]$AlertDescription
    )
<#
    $AlertName = "NomeDoAlerta"
    $SubscriptionID = "123"
    $AlertID = "12345678-1234-1234-1234-123456789012"         
    $AlertDescription = "TesteDeAlertaDoSCOM"
    $AlertPath = "CaminhoPath"
    $AlertDisplayName = "AlertDisplayName___"
    $TicketId = "Ticket4567890"
    $ResolutionState = "New"
    $TicketId = $null
#>   

    # Chave do DBaaS Intera
    $SK = "ba9eab0b45cc4a29bff9807c8fd7c34b"
    $URL = "https://events.pagerduty.com/generic/2010-04-15/create_event.json"

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"

    $headers.Add("Accept", '*/*')
    $headers.Add("accept-encoding", 'gzip, deflate')
    $headers.Add("content-type", 'application/json')
    $headers.Add("content-length", '140')

    <# Detect if TickedId parameter is passed if not set it to null to generate a new incident_key in PagerDuty#>
    If ($TicketId -eq "Not Present") {$TicketId = $null}

    <# Detect if ResolutionState is NEW or Closed to create a new Incident or Resolve a Incident in PagerDuty #>
    If ($ResolutionState -eq "Closed") {$Event_Type = "resolve"} else {$Event_Type = "trigger"}

    $body=@{}

    $body["service_key"] = $SK 
    $body["event_type"] = $Event_Type 
    $body["incident_key"] = $TicketId
    $body["description"] = $AlertName
    $body["details"] = "State: " + $ResolutionState + " Description: " + $AlertDescription + " Path: " + $AlertPath + "  Display Name: " + $AlertDisplayName
    $body["client"] = "TOTVS" 
    
    $bodyJSON = ConvertTo-Json $body
    



    # Write-EventLog -LogName "Operations Manager" -Source "PagerDuty" -EventId 1973 -EntryType Error -Message "Alert test connector"
    # New-EventLog -LogName "Operations Manager" -Source "Slack"
    Write-EventLog -LogName "Operations Manager" -Source "PagerDuty" -EventId 1973 -EntryType Information -Message $bodyJSON.ToString()

    try
    {
        $message = "`nParametros: " + $AlertName+" "+$SubscriptionID+" "+$AlertID+" "+$AlertDescription+" AlertPath: "+$AlertPath+" AlertID: " + $AlertID + " " + $AlertDisplayName+" TicketID: "+$TicketId+" ResolutionState: "+$ResolutionState
        Write-EventLog -LogName "Operations Manager" -Source 'PagerDuty' -EventId 1973 -EntryType Information -Message $message

        $response = Invoke-RestMethod -Uri $URL -Headers $header -Body $bodyJSON -Method Post

        $message =  $bodyJSON.ToString() + "`nIncident Key / Ticket ID: " + $response.incident_key + "`nAlertID: " + $AlertID
        Write-EventLog -LogName "Operations Manager" -Source 'PagerDuty' -EventId 1973 -EntryType Information -Message $message
        
        Import-Module OperationsManager
        if ($ResolutionState -eq "New") 
        {
            Get-SCOMAlert -Id $AlertID | Set-SCOMAlert -TicketId $response.incident_key.ToString() -ResolutionState 246
        }
    }
    Catch [Exception]{
        $message = $_.Exception.GetType().FullName +"`n"+ $_.Exception.Message + "`n PagerDuty: " + $response; 
        Write-EventLog -LogName "Operations Manager" -Source 'PagerDuty' -EventId 1973 -EntryType Error -Message $message 
        write-host $_.Exception.GetType().FullName; 
        write-host $_.Exception.Message; 
        throw $_
    }

