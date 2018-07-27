$Yes = new-Object System.Management.Automation.Host.ChoiceDescription "&Yes","Yes";
$No = new-Object System.Management.Automation.Host.ChoiceDescription "&No","No";
$Choices = [System.Management.Automation.Host.ChoiceDescription[]]($Yes,$No);

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}


$time = Get-Date
Import-Module BitsTransfer

$downloads = @{


1=@{Url="https://jumpdesktop.com/downloads/connect/win";File = "JumpDesktopConnect.exe"}
# 2=@{Url="https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=pl";File = "firefox64inst.exe"}
# 3=@{Url="https://download.mozilla.org/?product=firefox-latest-ssl&os=win&lang=pl";File = "firefox32inst.exe"}


}

$UserDownload = [Environment]::GetFolderPath("User")+"\Downloads"
$downloads.GETENUMERATOR() | %{
    $Url    = $_.Value.Url
    $Dest   = $UserDownload+"\"+$_.Value.File
    $File   = $_.Value.File
        Try{
                If (Test-Path $Dest){  
                                        $mes = "Do you want to remove file $Dest"
                                        $ans = $host.ui.PromptForChoice($caption,$mes+$NazwaApp,$Choices,0)                        
                                        If ($ans -eq 0){ 
                                                        Remove-Item $Dest -Force
                                                        Write-Host -ForegroundColor Yellow "$(Get-Date -Format G) Removing previous $File"
                                                      }
                                    }

                Start-BitsTransfer -Source $Url -Destination $Dest -DisplayName $File  -ErrorAction Stop

                Write-Host "Download $File Completed in: $((Get-Date).Subtract($time).Seconds) Seconds" -ForegroundColor Green

                If (Test-Path $Dest){
                           Write-Host -ForegroundColor Yellow "$(Get-Date -Format G) Start installation $File"
                           Invoke-Expression ($Dest+" /q") -ErrorAction Stop
                           Write-Host -ForegroundColor Yellow "$(Get-Date -Format G) End installation $File"
            } 



            }
    Catch{
                $ErrorMessage = $_.Exception.Message
                Write-Host "Download $File $ErrorMessage" -ForegroundColor Red
            }         
}
 

