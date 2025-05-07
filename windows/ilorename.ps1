$source = Read-Host 'Source file name'
$csv = import-csv $source -header old,new
foreach ($line in $csv) {(Get-Content \\chc-filidx\public\amurray\storage\ilorename.xml) | ForEach-Object { $_ -replace "HOSTNAME", "$($line.new)" } | Set-Content \\$($line.new)\c$\temp\ilorename.xml}
foreach ($line in $csv) {psexec \\$($line.new) "C:\program files\hp\hponcfg\hponcfg.exe" /f c:\temp\ilorename.xml}