$account=$args[0]
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

$filespath = Get-ChildItem $($scriptPath + "\views\generic")
$add = "\views\generic"
$view = "\views\"
$ext = ".json"
$files= $filespath + $add

$afterout="""}"

$creationof = "Creation of "
$etc = "..."


for ($i=0; $i -lt ($files.Count-1); $i++) {
 
 $infile = $files[$i].FullName 
 $outfile = $scriptPath + $view + $files[$i].BaseName + $ext
 $comment =  $creationof + $files[$i].BaseName + $etc
 echo $comment
 
 $st1 = "{""queryType"":""SQL"", ""query"": ""create or replace view ``dfs``.``"

 $st2 = " Views``."

 $st3 = " as "
 
 $preout = $st1 + $account + $st2 + $files[$i].BaseName + $st3
 
$content = Get-Content $infile
 
 $finaloutfile = $preout + $content + $afterout
 
 Set-Content -Path $outfile -Value $finaloutfile
 
  (Get-Content $outfile) | ForEach-Object { $_ -replace "XXX", $account } | Set-Content $outfile
 
 
 echo OK! 
 }