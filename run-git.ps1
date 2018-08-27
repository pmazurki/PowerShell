$specific="pmazurki/PowerShell/master/Downloader.ps1"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$sourceurl = Invoke-WebRequest https://raw.githubusercontent.com/+ $specific
Invoke-Expression $($sourceurl.Content)
