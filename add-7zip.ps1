  $list = @{

1= @{Path='C:\in';Destipath= '\\ip\folder\Backup\';Name='in'}
2= @{Path='C:\out';Destipath= \\ip\folder\Backup\';Name='out'}
}
$list.GETENUMERATOR()| Sort-Object name | % {

$Path=$_.Value.Path
$Destipath=$_.Value.Destipath
$Name=$_.Value.Name 




Try{
Write-Host -ForegroundColor Gray "$(Get-Date -Format G) " -NoNewline
        Write-Host -ForegroundColor Green " Start script $Name " 

if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) {throw "$env:ProgramFiles\7-Zip\7z.exe needed"} 
set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"  


$Sources= Get-ChildItem $path |sort LastWriteTime -Descending| Select-Object -Skip 1 | Select-Object FullName |Select-Object -Last 100
$dtstamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
$Destination = Join-path -path $Destipath -ChildPath $Name"$dtstamp.zip"

if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) {throw "$env:ProgramFiles\7-Zip\7z.exe needed"} 
set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"  

If(Test-path $Destination) {Remove-item $Destination}
Foreach ($Source in $Sources){sz a -mx=9 $Destination $Source.fullname }
Foreach ($Source in $Sources){If(Test-path $Destination) {Remove-Item $Source.fullname} } 

}


Catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "Download $File $ErrorMessage" -ForegroundColor Red
    }

 Write-Host -ForegroundColor Gray "$(Get-Date -Format G) " -NoNewline
        Write-Host -ForegroundColor Green " Stop script $Name " 
}  
