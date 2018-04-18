# PnP Inventory Scripts
I've been writing SharePoint inventory scripts for a minute, so I'm placing them here in github for your pleasure. There are not a lot of PnP inventory scripts out there, so these scripts will be exclusively built using PNP.

For more detail about this script, go here: http://erikboderek.net/2018/02/26/sharepointpnpinventory/

# get-everyitemeveryfield.ps1
This script gets every field for every item everywhere. It's exhaustive. It does a pretty good job of getting Managed Metadata values too, but this can probably be tidied up a bit.

# get-sitecollectioninventory
This script gets the item count and size of each list in every subsite. It also has timestamps and subsite level. When doing site inventories, I'd recommend using this script as it's less information to parse and is nicely summarized. 

# Known Issues and Limitations
## Limitations
A major limitation in all the scripts is as follows:
  **Get-PNPSubwebs -Recurse** fails when a web is a provider hosted app. For example, if you have Nintex for Office 365, PNP views it as a subsite, even though it appears in your Lists/Apps. I logged this as an issue - https://github.com/SharePoint/PnP-PowerShell/issues/1490. This means the script cannot traverse all of the subsites effectively. There are clever ways around this, which I capture in my blog above. Until this is fixed, these scripts will do their best to inventory everything, but there are some caveats. I'll update as fixes or novel approaches become available.

## Issues
In get-sitecollectioninventory the sitecollection title is null, but subsites are not. 
