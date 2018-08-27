$specific ="pmazurki/PowerShell/master/Downloader.ps1"

$url= "https://raw.githubusercontent.com/"+ $specific

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$sourceurl = Invoke-WebRequest $url

Invoke-Expression $($sourceurl.Content)
