Param(
[parameter(Mandatory=$true)]
 [string]$sitecollection
)

#update credentials based on your system. If in doubt, remove credentials param
Connect-PnPOnline -Url $sitecollection -Credentials 'outlook.office365.com'

#set variable for tenant
$tenant = $sitecollection.Split('.')[0]
$tenant = $tenant.Split('/')[2]
#add a dash to end of tenant. All provider-hosted apps have url tenant-some GUID
$tenant = $tenant + '-'


#create variables for output file
$date = get-date -format yyyy-MM-dd
$time = get-date -format HH-mm-ss
$outputfilename = "SiteInventory" + $date + "_" + $time + ".csv"
$outputpath = "c:\scripts\"+$outputfilename

Write-Host "Connected to SharePoint site:" $sitecollection -ForegroundColor Green

function InventorySite($web){
$array = $null
$array = @()
$sitelevel = 0;

write-host "Performing inventory on "$web.url -foregroundcolor Yellow


#is this the root or not. If not, get lists
 if($web.ParentWeb -eq $null){
	$lists = get-pnplist
    #set site url to be site collection URL
	$spurl = $site.url
 }
 else { 
	$lists = get-pnplist -web $web
	#set site url to be site collection URL
	$spurl = $web.url
    $sitelevel++
 }
 
 #go through every list
 foreach ($list in $lists)
 { 
	write-host "List:" $list.title -foregroundcolor White
    
    $listsize = 0
    
    if($web.url -eq $site.Url){
        try
            {
		    $items = get-pnplistitem -list $list -PageSize 1000
            }
        catch
            {
            write-host "Error getting items for list" $list.title
            }
		}
	    else {
            try
                {        
                $items = get-pnplistitem -list $list -Web $web -PageSize 1000
                }
            catch
                {
                write-host "Error getting items for list" $list.title
                }
	    }
            foreach ($item in $items)
		{
            $listsize += $item.FieldValues.File_x0020_Size
        }
        $listSize= [Math]::Round(($listSize/1MB),2)  
      
    
    
    $props = @{
		'Site Collection' = $site.url;
        'Site Address' = $spurl;
        'Site Title' = $web.title;
        'List' = $list.title;
        'Created' = $list.created;
        'Item Count' = $list.itemcount;
        'Last Modified' = $list.lastitemmodifieddate;
        'Last Item User Modifed' = $list.LastItemUserModifiedDate;
        'Size of List (in MB)' = $listsize;
        'Subsite Level' = $sitelevel;
        }
    $obj = New-Object PSObject -Property $props
    #$obj | Add-Member -MemberType noteproperty -Name $props 
	$array += $obj

#close list in lists
}
 $filter = $array | Get-Unique -AsString
 $filter | Export-Csv $outputpath -noType -Encoding UTF8 -Append -Force
}

function GetSubsites{
	foreach ($web in $subwebs | ?{ $_.url -notmatch $tenant  }){

				
						InventorySite $web

            #until get-pnpsubwebs -recurse is fixed, mothball this
			#$tertiarysites = Get-PnPSubWebs -web $web.Url
			#	foreach ($tertiarysite in $tertiarysites | ?{ $_.url -notmatch $tenant  })
			#		{
            #            #write-host "starting inventory on " $tertiarysite  $_.url -ForegroundColor DarkRed
			#			InventorySite $tertiarysite
			#		}

       
}
}


#load site collection, and lists at site collection
$site = Get-PnPSite -includes RootWeb.Lists
#call inventory function
InventorySite $site

#load first level subsites
$subwebs = Get-PnPSubWebs

#call inventory function for each subsite
GetSubsites $subwebs



write-host "Script for complete! Exported file to " $outputpath -foregroundcolor green

#additional instructions here
#http://erikboderek.net/2018/02/26/sharepointpnpinventory/

#references
#https://veenstra.me.uk/2017/11/03/microsoft-teams-get-all-your-team-sites-using-pnp-powershell/
#https://blog.kloud.com.au/2018/02/01/quick-start-guide-for-pnp-powershell/
#https://github.com/SharePoint/PnP-PowerShell/blob/master/Documentation/readme.md
