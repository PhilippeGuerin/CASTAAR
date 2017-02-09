$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$account=$args[0]

$infile = $($scriptPath + "\storage_plugin\generic\storage_plugin.json")
$outfile = $($scriptPath + "\storage_plugin\storage_plugin.json")

(Get-Content $infile) | ForEach-Object { $_ -replace "CLIENT", $account } | Set-Content $outfile