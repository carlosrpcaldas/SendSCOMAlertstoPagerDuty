# SendSCOMAlertstoPagerDuty
Powershell Script to send alerts from a SCOM notificiation channel to PagerDuty (or any REST service out there).

Full path of the command file:
c:\windows\system32\windowspowershell\v1.0\powershell.exe

Command line parameters:
"C:\Scripts\PagerDutty.ps1" ‘$Data/Context/DataItem/AlertName$’ ‘<<YOUR SERVICE KEY>>’ ‘$Data/Context/DataItem/AlertId$’ ‘$Data[Default='Not Present']/Context/DataItem/ManagedEntityPath$’ ‘$Data[Default='Not Present']/Context/DataItem/ManagedEntityDisplayName$’ ‘$Data[Default='Not Present']/Context/DataItem/TicketId$’ ‘$Data[Default='Not Present']/Context/DataItem/ResolutionStateName$’ --% ‘$Data[Default='Not Present']/Context/DataItem/AlertDescription$’

Startup folder for the command line?
c:\windows\system32\windowspowershell\v1.0
