$Yes = new-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes";
$No = new-Object System.Management.Automation.Host.ChoiceDescription "&No", "No";
$Choices = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No);

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
Import-Module BitsTransfer
$sysDiaPro = New-Object System.Diagnostics.Process

$time = Get-Date
$DestDownload = [Environment]::GetFolderPath("User") + "\Downloads"
$downloads = @{

    #1 = @{Url = "\\192.168.1.29\file\install\App.exe"; File = "App.exe"; Arguments = "/q"}
    2 = @{Url = "https://jumpdesktop.com/downloads/connect/win"; File = "JumpDesktopConnect.exe"; Arguments = ""}
    3 = @{Url = "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=pl"; File = "firefox64inst.exe"; Arguments = ""}
    4 = @{Url = "https://www.7-zip.org/a/7z1805-x64.exe"; File = "7z1805-x64.exe"; Arguments = ""}
   
}

$downloads.GETENUMERATOR()| Sort-Object name | % {
    $Url = $_.Value.Url
    $Dest = $DestDownload + "\" + $_.Value.File
    $File = $_.Value.File
    $Arg = $_.Value.Arguments
   
    Try {
        If (Test-Path $Dest) {  
            $mes = "Do you want to remove file $Dest"
            $ans = $host.ui.PromptForChoice($caption, $mes, $Choices, 0)                        
            If ($ans -eq 0) { 
                Remove-Item $Dest -Force
                Write-Host -ForegroundColor Yellow "$(Get-Date -Format G) Removing previous $File"
            }
        }

        Start-BitsTransfer -Source $Url -Destination $Dest -DisplayName $File  -ErrorAction Stop 
        Write-Host "Download $File Completed in: $((Get-Date).Subtract($time).Seconds) Seconds" -ForegroundColor Green
        
        #$mes = "Do you want to install the program? $File"
        #$ans = $host.ui.PromptForChoice($caption, $mes, $Choices, 0)

        If ($ans -eq 0) {  
            If (Test-Path $Dest) {
                Write-Host -ForegroundColor Yellow "$(Get-Date -Format G) Start installation $File"
                $ProcessStartInfo = New-Object System.Diagnostics.ProcessStartInfo($Dest, $Arg )
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
 
