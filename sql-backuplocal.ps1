$server = $Env:ComputerName
$apfHost = $server 

$SystemDir = [System.Environment]::SystemDirectory
$sql1 = [System.Data.Sql.SqlDataSourceEnumerator]::Instance.GetDataSources()| Where-Object {$_.ServerName -eq $server} 
$SQLPathTs = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Microsoft SQL Server\Instance Names"

foreach ($SQLPathT in $SQLPathTs) {
    if ((Test-Path $SQLPathT) -eq $True) {


        $Sqlinstance = (get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances
        $SQLPathSetup = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$sqlinstance\Setup"
        if ((Test-Path $SQLPathSetup) -eq $True) {
            $SQLPath = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$sqlinstance\Setup").SQLPath
        }
        Else {
            $Sqlinstance = (get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL').$Sqlinstance
            $SQLPath = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$sqlinstance\Setup").SQLPath
        }
        break
    }
    Else {
        $Sqlinstance = (get-itemproperty 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Microsoft SQL Server').InstalledInstances
        $SQLPath = (Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Microsoft SQL Server\$Sqlinstance\Setup").SQLPath
        break
    }

}


if ($sql1.InstanceName -like $null) {

    $sql = ("SQLSERVER:\SQL\" + $server + "\DEFAULT\" + "Databases")
}
else {
    $sql = ("SQLSERVER:\SQL\" + $server + "\" + $sqlinstance + "\" + "Databases")
}
$SQLPathBack = $SQLPath + "\Backup"


[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null

$Svr = New-Object ('Microsoft.SqlServer.Management.Smo.Server') ($server + "\" + $sql1.InstanceName)


Import-Module sqlps -DisableNameChecking
Set-Location $sql;

foreach ($Svr in $Svr.Databases) {

    $dbName = $Svr.Name


    If (-not($Svr.Status -eq "RecoveryPending" -or $Svr.Status -eq "Offline" -or $Svr.Status -eq "Suspect" -or $dbName -eq "master" –or $dbName -eq "model" –or $dbName -eq "msdb" –or $dbName -eq "tempdb" )) {
        $SQLPathBackdb = $SQLPathBack + "\" + $Svr.Name
        $FileExists = Test-Path $SQLPathBackdb

        If ($FileExists -eq $True) {
            Remove-Item $SQLPathBackdb
            ##Write-Host -ForegroundColor Gray "$(Get-Date -Format G) " -NoNewline
            ##Write-Host -ForegroundColor Green " Removing the old copy of the database $Database from $server"  
        }
        $Database = $Svr.Name
   
   
        Backup-SqlDatabase -Database $Svr.Name   -BackupAction Files -BackupFile ($SQLPathBackdb)
        Write-Host -ForegroundColor Gray "$(Get-Date -Format G) " -NoNewline
        Write-Host -ForegroundColor Green " A copy of the database $Database from $apfHost started" 
   
 
    }

}
Set-Location $SystemDir;


Write-Host -ForegroundColor Gray "$(Get-Date -Format G) " -NoNewline
Write-Host -ForegroundColor Green " Stop"
### Copy of Database local sklepy end 

