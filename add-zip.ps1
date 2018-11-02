$Path='C:\Files'
$Destipath='\\ip\folder\Backup\' 
$Sources= Get-ChildItem $path |sort LastWriteTime -Descending| Select-Object -Skip 1 | Select-Object FullName
$dtstamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
$Destination = Join-path -path $Destipath -ChildPath "$dtstamp.zip"
[Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') 
If(Test-path $Destination) {Remove-item $Destination}
Foreach ($Source in $Sources){Compress-Archive -Path $Source.fullname -DestinationPath $Destination -Update} 
