Param(

[parameter(Mandatory=$true)]
 [string]$sitecollection
)

#update credentials based on your system. If in doubt, remove credentials param
Connect-PnPOnline -Url $sitecollection -Credentials 'outlook.office365.com'

#create variables for output file
$date = get-date -format yyyy-MM-dd
$time = get-date -format HH-mm-ss
$outputfilename = "SiteInventory" + $date + "_" + $time + ".csv"
$outputpath = "c:\scripts\"+$outputfilename

Write-Host "Connected to SharePoint site:" $sitecollection -ForegroundColor Green

function InventorySite($web){
#Create array variables to store data
$fieldvalues = $null
$fieldvalues = @()
$array = $null
$array = @()
#additional vars
$siteurl = $site.url
$weburl = $web.url
write-host "Performing inventory on " $weburl -foregroundcolor Yellow
#is this the root or not. If not, get lists
 if($weburl -eq $siteUrl){
	$lists = get-pnplist
 }
 else { 
	$lists = get-pnplist -web $web
 }
 
 #go through every list
 foreach ($list in $lists)
 { 
	 write-host "List:" $list.title -foregroundcolor White
	 #get all items
	 #if this is the root, don't use web property. if subsite, use web
	 if($weburl -eq $siteUrl){
		$items = get-pnplistitem -list $list -PageSize 1000
	 }
	 else { 
		$items = get-pnplistitem -list $list -Web $web -PageSize 1000
	 } 
		#go through every item
		foreach ($item in $items)
		{
			 $obj = New-Object PSObject
			 $fieldvalues = $item.FieldValues 
				 foreach ($field in $fieldvalues){
					 $keys = @()
					 $values = @()
					#work on the keys aka field names
					 foreach ($key in $field.keys){
					 $keys += $key
					 }
					#work on the field values
					 foreach ($value in $field.values){
						#if lookup value, do this
						if($value.lookupvalue -ne $null){
						$values += $value.lookupvalue
						}
						#not a lookup
						else{$values += $value}
					 }
					 #add values to obj array
					 For ($j = 0; $j -lt $keys.count;$j++)
					 {
						$obj | Add-Member -MemberType noteproperty -Name ($keys[$j]).tostring() -Value $values[$j] 
						$array += $obj
					 } 
				 #close field in fields
				 }
		#close item in items
		}
#close list in lists
}
 $filter = $array | Get-Unique -AsString
 $filter | Export-Csv $outputpath -noType -Encoding UTF8 -Append -Force
}

#load site collection, and lists at site collection
$site = Get-PnPSite -includes RootWeb.Lists
#call inventory function
InventorySite $site

#load subsites
$subwebs = Get-PnPSubWebs -Recurse
#call inventory function for each subsite
foreach ($web in $subwebs){
 InventorySite $web
}
write-host "Script complete! Exported file to " $outputpath -foregroundcolor green

#additional instructions here
#http://erikboderek.net/2018/02/26/sharepointpnpinventory/

#references
#https://veenstra.me.uk/2017/11/03/microsoft-teams-get-all-your-team-sites-using-pnp-powershell/
#https://blog.kloud.com.au/2018/02/01/quick-start-guide-for-pnp-powershell/
#https://github.com/SharePoint/PnP-PowerShell/blob/master/Documentation/readme.md
