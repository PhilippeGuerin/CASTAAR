$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$server=$args[0]
$db_Name=$args[1]
$port=$args[2]
$user=$args[3]
$password=$args[4]

$infile = $($scriptPath + "\psql_plugin\generic\psql_plugin.json")
$outfile = $($scriptPath + "\psql_plugin\psql_plugin.json")

(Get-Content $infile) | ForEach-Object { $_ -replace "_SERVER", $server } | Set-Content $outfile

(Get-Content $outfile) | ForEach-Object { $_ -replace "_DB_NAME", $db_Name } | Set-Content $outfile
(Get-Content $outfile) | ForEach-Object { $_ -replace "_PORT", $port } | Set-Content $outfile

(Get-Content $outfile) | ForEach-Object { $_ -replace "_USER", $user } | Set-Content $outfile
(Get-Content $outfile) | ForEach-Object { $_ -replace "_PASSWORD", $password } | Set-Content $outfile
	
	 
	
	