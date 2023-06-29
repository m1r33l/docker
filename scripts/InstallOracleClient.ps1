Write-Host "Installing Oracle Client...";
######################################################
# INSTALL ORACLE DATA ACCESS COMPONENTS 12.1.0.2.4 (64bit) #
######################################################
$ORACLE_CLIENT_ZIP_FILE="NT_1200_client.zip"
$ORACLE_TEMP="C:\temp\oracle"
$ORACLE_TEMP_CLIENT="C:\temp\oracle\client64"
$ORACLE_HOME="C:\oracle\Product\12.0.0\Client64"
$ORACLE_BASE="c:\oracle"
$ODP_NET="C:\oracle\Product\12.0.0\Client\ODP.NET\bin\4.x"
$ORACLE_GAC="C:\Windows\assembly\GAC_64\Oracle.DataAccess\v4.0_4.121.1.0__89b483f429c47342"
New-Item -Type Directory -Path $ORACLE_GAC -Force
Push-Location  $ORACLE_TEMP;
Expand-Archive -Path $ORACLE_CLIENT_ZIP_FILE -DestinationPath .; 
# INSTALL ORACLE CLIENT
Set-Location $ORACLE_TEMP_CLIENT; 
Write-Output "INSTALING ORACLE DATABASE CLIENT VIA setup.exe process..."; 
# See: https://silentinstallhq.com/oracle-database-19c-client-silent-install-how-to-guide/
Start-Process "$ORACLE_TEMP_CLIENT\setup.exe" -ArgumentList @('-silent',
    '-nowait',
    '-ignoreSysPrereqs',
    '-ignorePrereqFailure',
    '-waitForCompletion',
    '-force',
    "ORACLE_HOME=$ORACLE_HOME",
    "ORACLE_BASE=$ORACLE_BASE",
    "oracle.install.IsBuiltInAccount=true",
    "oracle.install.client.installType=Runtime"
) -NoNewWindow -Wait; 
Write-Output "ORACLE DATABASE CLIENT INSTALLATION FINISHED."; 
# REGISTER CONFIG and GAC
Set-Location $ODP_NET; 
Write-Output "REGISTERING CONFIG AND GAG..."; 
.\OraProvCfg.exe  /action:config  /force /product:odp /frameworkversion:v4.0.30319 /providerpath:"Oracle.DataAccess.dll";
.\OraProvCfg.exe /action:gac /providerpath:"Oracle.DataAccess.dll"; 
Set-Location  $ORACLE_GAC;
    
Get-ChildItem -Filter *.dll -Recurse | Select-Object -ExpandProperty VersionInfo;
    
Write-Output "CONFIG AND GAG REGISTER PROCESS FINISHED."; 
Set-Location $ORACLE_HOME;
    
# SET ORACLE_HOME permissions (Avoid "System.Data.OracleClient requires Oracle client" exception)
$acl = Get-Acl $ORACLE_HOME; 
$accessRule = [System.Security.AccessControl.FileSystemAccessRule]::new(
    'Everyone', 
    [System.Security.AccessControl.FileSystemRights]::ReadAndExecute,
    'ContainerInherit,ObjectInherit', 
    [System.Security.AccessControl.PropagationFlags]::None,
    [System.Security.AccessControl.AccessControlType]::Allow 
); 
$acl.AddAccessRule($accessRule);
    
Set-Acl $ORACLE_HOME $acl; 
Get-Acl $ORACLE_HOME; 
# ADD the ODAC install directory and ODAC install directory's bin subdirectory to the system PATH environment variable before any other Oracle directories.
$pathContent = [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::Machine);
    
$pathContentBuilder = [System.Text.StringBuilder]::new(); 
$oracleHomeSegment = "$ORACLE_HOME;"; 
$pathContentBuilder.Append($oracleHomeSegment); 
$oracleBinPath = Join-Path -Path "$ORACLE_HOME" -ChildPath "bin" -Resolve; 
$oracleBinPath += ';'; 
$pathContentBuilder.Append(${oracleBinPath}); 
$pathContentBuilder.Append(${pathContent});
    
[System.Environment]::SetEnvironmentVariable('PATH', $pathContentBuilder.ToString(), [System.EnvironmentVariableTarget]::Machine); 
# REMOVE install scripts and files
[System.IO.Path]::Combine($ORACLE_TEMP,'..') | Resolve-Path | Push-Location; 
#[System.IO.Path]::Combine($ORACLE_TEMP,'*') | Remove-Item -Recurse -Force;
Get-ChildItem C:\Windows\assembly\GAC_64\Oracle.DataAccess\v4.0_4.121.1.0__89b483f429c47342
Pop-Location;
Write-Host "Oracle Client installed.";
