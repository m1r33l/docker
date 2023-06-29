$ErrorActionPreference = "Stop"

[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$webClient = new-object System.Net.WebClient


echo "install certificates"
Set-Location -Path "C:\certs"
[array]$certsArtifacts = Get-ChildItem -File;

foreach ($certsArtifact in $certsArtifacts) {
    $destinationPath = [System.IO.Path]::Combine("C:\certs", 'current');
    Write-Output ${destinationPath};
    Write-Host ${destinationPath};
    Expand-Archive -Path ${certsArtifact} -DestinationPath ${destinationPath};
    $cert = Get-ChildItem -Path ${destinationPath} -File;
    $certPath = [System.IO.Path]::Combine($destinationPath, $cert.name);
    Push-Location -Path Cert:\LocalMachine\Root\;
    Import-Certificate -FilePath $certPath;
    Pop-Location;
    Write-Output ${destinationPath};
    Remove-Item -Path ${destinationPath} -Recurse -Force;
}

[System.IO.Path]::Combine("C:\certs", '..') | Resolve-Path | Push-Location;
[System.IO.Path]::Combine("C:\certs", '*') | Remove-Item -Recurse -Force;


echo "install logmonitor"
cd /LogMonitor
$webClient.DownloadFile("https://nexus.alm.europe.cloudcenter.corp/repository/scq-iac-releases/CCOE/LogMonitor.zip","C:\LogMonitor\logmonitor.zip");
Expand-Archive logmonitor.zip .;
del logmonitor.zip

echo "install powershell core"
New-Item -Path 'C:\temp' -ItemType Directory
cd /temp
$webClient.DownloadFile("https://nexus.alm.europe.cloudcenter.corp/repository/scq-iac-releases/CCOE/pwsCore.zip","C:\temp\pwsCore.zip");
Expand-Archive pwsCore.zip;
Start-Process msiexec -ArgumentList '/i', 'pwsCore\PowerShell-7.3.2-win-x64.msi', '/quiet' -Wait -PassThru;
Remove-Item pwsCore\PowerShell-7.3.2-win-x64.msi

echo "config service"
Set-Service -Name "w3svc" -StartupType "Manual"


echo "install Oracle client"
New-Item -Path 'C:\temp\oracle' -ItemType Directory
cd /temp/oracle
$webClient.DownloadFile("https://nexusmaster.alm.europe.cloudcenter.corp/repository/scq-3rd-party-raw/oracle/database/oracle19c/windows/client/193000/NT_193000_client.zip","C:\temp\oracle\NT_193000_client.zip");
\scripts\InstallOracleClient.ps1
