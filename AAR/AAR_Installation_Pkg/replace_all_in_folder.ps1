$input_folder=$args[0]
$search=$args[1]
$toreplace=$args[2]

$files = Get-ChildItem $input_folder
for ($i=0; $i -lt $files.Count; $i++) {
 $outfile = $files[$i].FullName
 (Get-Content $outfile) | ForEach-Object { $_ -replace "`"$search`"", "$toreplace"} | Set-Content $outfile
 }