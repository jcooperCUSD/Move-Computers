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

# AD Domain Controller Session
$adCmdLets = 'Get-ADcomputer','Move-ADObject'
$adSession = New-PSSession -ComputerName $DomainController -Credential $ADCredential
Import-PSSession -Session $adSession -Module ActiveDirectory -CommandName $adCmdLets -AllowClobber

$sourceOU = "CN=Computers,DC=CHICO,DC=USD"
$targetOU = "OU=KACE IMAGING,OU=STUDENTS,OU=DESKTOPS,OU=COMPUTERS,OU=Domain_Root,DC=chico,DC=usd"

$endTime = "11:30pm"
if (!$WhatIf) { "Running until $endTime" }
do {
 $computerObjs = Get-ADcomputer -Filter * -SearchBase $sourceOU
 foreach ($obj in $computerObjs){
  # Move Object to TargetPath
  $obj | Move-ADObject -TargetPath $targetOU -Whatif:$WhatIf
 }
} until ( $WhatIf -or ( (Get-Date) -ge (Get-Date $endTime) ) )

Write-Verbose "Tearing down sessions"
Get-PSSession | Remove-PSSession
 
