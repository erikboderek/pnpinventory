# pnpinventory
SharePoint Site Inventory Built Using PNP

For more detail about this script, go here: http://erikboderek.net/2018/02/26/sharepointpnpinventory/

# Known Issues and Limitations
Get-PNPSubwebs -Recurse fails when a web is a provider hosted app. For example, Nintex. I logged this as an issue. https://github.com/SharePoint/PnP-PowerShell/issues/1490
