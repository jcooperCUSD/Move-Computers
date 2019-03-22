<#
The scripts is to be run regularly. Its purpose it to move
computers to a more agreeable OU so that GPO's can be applied
without extra effort.
#>
[cmdletbinding()] 
param (
 [Parameter(Position=1,Mandatory=$True)]
 [Alias('ADCred','ADCReds')]
 [System.Management.Automation.PSCredential]$ADCredential,
 [switch]$WhatIf
)

Write-Verbose "Running $($MyInvocation.MyCommand.Name)"

$SiteOULookupTable = Import-CSV ".\SiteOU-Lookuptable.1.0.csv"-Delim "|"
$SourceOU = "CN=Computers,DC=CHICO,DC=USD"
$TargetPath = "OU=KACE IMAGING,OU=STUDENTS,OU=DESKTOPS,OU=COMPUTERS,OU=Domain_Root,DC=chico,DC=usd"
$Common = "\\mirage\Scripts\CommonFunctions"

. "$Common\Check-ADModule.3.0.ps1"
Check-ADModule $PDC = (Get-ADDomain).InfraStructureMaster
$ComputerObjects = Get-ADcomputer -Filter * -SearchBase $SourceOU

foreach ($Object in $ComputerObjects)
{
	$ObjectPrefix = $Object.Name.substring(0,3)
	$TargetSite = $SiteOULookupTable | where { $_.SiteNameMask -eq "$ObjectPrefix" }
	# Add SiteName to Description Attribute
	if ($TargetSite)
	{
		Write-Verbose $TargetSite.SiteName
		try
		{
			$Object | Set-AdObject -Desc $TargetSite.SiteName -Whatif:$WhatIf
		}
		catch
		{
			Write-Error -Exception "Unable to set attribute(s) for $($Object.Name)"
		}
	}
	# Move Object to TargetPath
	try 
	{
		$Object | Move-ADObject -TargetPath $TargetPath -Whatif:$WhatIf
	}
	catch
	{
		Write-Error -Exception "Unable to move $($Object.Name) to $TargetPath"
	}
	if ($Slow) { Write-Verbose "Pausing"; read-host }
}


 
