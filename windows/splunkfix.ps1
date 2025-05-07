$source = Read-Host 'Source file name'
$csv = import-csv $source -header old,new
foreach ($line in $csv) {(Get-Content \\$($line.new)\c$\splunk\etc\system\local\inputs.conf) | ForEach-Object { $_ -replace "$($line.old)", "$($line.new)" } | Set-Content \\$($line.new)\c$\splunk\etc\system\local\inputs.conf}
foreach ($line in $csv) {(Get-Content \\$($line.new)\c$\splunk\etc\system\local\server.conf) | ForEach-Object { $_ -replace "$($line.old)", "$($line.new)" } | Set-Content \\$($line.new)\c$\splunk\etc\system\local\server.conf}
