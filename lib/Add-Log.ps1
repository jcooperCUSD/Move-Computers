function Add-Log {
	[cmdletbinding()]
	Param ( 
		[Parameter(Position=0,Mandatory=$True)]
		[STRING]$Type,
  [Parameter(Position=1,Mandatory=$True)]
  [Alias("Msg")]
		[STRING]$Message,
  [Parameter(Position=2,Mandatory=$false)]
  [SWITCH]$Test )
 $date = Get-Date -Format s
 $type = "[$($type.toUpper())]"
 $testString = if ($Test){"[TEST] "}
 $logMsg = "$testString$date,$type,$message"
 Write-Output $logMsg
}