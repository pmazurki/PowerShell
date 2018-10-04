$Yes = new-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes";
$No = new-Object System.Management.Automation.Host.ChoiceDescription "&No", "No";
$Choices = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No);

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
Import-Module BitsTransfer
$sysDiaPro = New-Object System.Diagnostics.Process

$time = Get-Date
$DestDownload = [Environment]::GetFolderPath("User") + "\Downloads"
$downloads = @{

    1 = @{File = 'app.exe'; Arg = ""; Source = '\\192.168.1.100\folder\install\appfolder'; Dest = '\appfolder'; }
    2 = @{File = 'JumpDesktopConnect.exe'; Arg = ''; Source = 'https://jumpdesktop.com/downloads/connect/win'; Dest = ''}
    3 = @{File = 'firefox64inst.exe'; Arg = ''; Source = 'https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=pl'; Dest = ''}
    4 = @{File = '7z1805-x64.exe'; Arg = ''; Source = 'https://www.7-zip.org/a/7z1805-x64.exe'; Dest = ''}
  
}
$downloads.GETENUMERATOR()| Sort-Object name | % {
    $Dest = ''
    $Source = $_.Value.Source
    $Dest = $_.Value.Dest
    if ($Dest -ne '') {$Dest = $DestDownload + $_.Value.Dest}
    $File = $_.Value.File
    $Arg = $_.Value.Arg
    
    Try {
        if ($Dest -eq '') {
            $Dest = $DestDownload
            If (Test-Path $($Dest + '\' + $File)) {  
                $mes = "Do you want to remove file $File"
                $ans = $host.ui.PromptForChoice($caption, $mes, $Choices, 0)                        
                If ($ans -eq 0) { 
                    Remove-Item $($Dest + '\' + $File) 
                    Write-Host -ForegroundColor Yellow "$(Get-Date -Format G) Removing previous $File"
                }
            
            }
            Start-BitsTransfer -Source $Source -Destination $($Dest + '\' + $File) -DisplayName $File  -ErrorAction Stop
            Write-Host "Download2 $File Completed in: $((Get-Date).Subtract($time).Seconds) Seconds" -ForegroundColor Green
        }
        Else {
            $folders = Get-ChildItem -Name -Path $Source -Recurse
            If (Test-Path $Dest) {  
                $mes = "Do you want to remove file $Dest"
                $ans = $host.ui.PromptForChoice($caption, $mes, $Choices, 0)                        
                If ($ans -eq 0) { 
                    Remove-Item $Dest -Force
                    Write-Host -ForegroundColor Yellow "$(Get-Date -Format G) Removing previous $File"
                }
            }
            New-Item $Dest -ItemType Directory
            foreach ($i in $folders) {
                Start-BitsTransfer -Source $Source\$i -Destination $Dest -DisplayName $i  -ErrorAction Stop
                Write-Host "Download $i Completed in: $((Get-Date).Subtract($time).Seconds) Seconds" -ForegroundColor Green
            }
        }
        $mes = "Do you want to install the program? $File"
        $ans = $host.ui.PromptForChoice($caption, $mes, $Choices, 0)
        If ($ans -eq 0) {  
            If (Test-Path $Dest) {
                Write-Host -ForegroundColor Yellow "$(Get-Date -Format G) Start installation $File"
                $ProcessStartInfo = New-Object System.Diagnostics.ProcessStartInfo($($Dest + '\' + $File), $Arg )
                $sysDiaPro.StartInfo = $ProcessStartInfo
                $on = $sysDiaPro.Start() 
                $sysDiaPro.WaitForExit()
                Write-Host -ForegroundColor Yellow "$(Get-Date -Format G) End installation $File"
            } 
        }
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "Download $File $ErrorMessage" -ForegroundColor Red
    }         
}

  
