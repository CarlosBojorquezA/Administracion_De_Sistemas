# Desactivar advertencias de IE para instalación
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -Value 1 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "WarnOnHTTPSToHTTPRedirect" -Value 0 -ErrorAction SilentlyContinue

# Verificar si hMailServer ya está instalado
$hMailPath = "C:\Program Files (x86)\hMailServer\Bin\hMailServer.exe"
if (Test-Path $hMailPath) {
    Write-Host "hMailServer ya está instalado. Procediendo con la configuración..."
} else {
    # 1. Instalar características necesarias
    Install-WindowsFeature -Name "SMTP-Server", "Web-Server", "Web-Mgmt-Console" -IncludeManagementTools

    # 2. Descargar e instalar hMailServer
    $hMailServerURL = "https://www.hmailserver.com/files/hMailServer-5.6.8-B2574.exe"
    $hMailServerInstaller = "$env:TEMP\hMailServer.exe"

    try {
        Write-Host "Descargando hMailServer..."
        Invoke-WebRequest -Uri $hMailServerURL -OutFile $hMailServerInstaller -UseBasicParsing
        Start-Process -FilePath $hMailServerInstaller -Wait
    }
    catch {
        Write-Host "Error al descargar o ejecutar hMailServer: $_"
        exit 1
    }
}

# 3. Registrar componente COM
$hMailServerDLL = "C:\Program Files (x86)\hMailServer\Bin\hMailServer.dll"
if (Test-Path $hMailServerDLL) {
    Write-Host "Registrando componente COM de hMailServer..."
    Start-Process "regsvr32.exe" -ArgumentList "/s `"$hMailServerDLL`"" -Wait -NoNewWindow
} else {
    Write-Host "No se encontró hMailServer.dll, pero el componente COM parece estar registrado. Continuando..."
}

# 4. Iniciar servicio de hMailServer
$serviceName = "hMailServer"
if ((Get-Service $serviceName -ErrorAction SilentlyContinue).Status -ne "Running") {
    Start-Service $serviceName -ErrorAction Stop
    Start-Sleep -Seconds 10
}

# 5. Configurar hMailServer
$maxRetries = 3
$retryCount = 0
$success = $false

while (-not $success -and $retryCount -lt $maxRetries) {
    try {
        $retryCount++
        Write-Host "Configurando hMailServer (Intento $retryCount)..."

        $hMail = New-Object -ComObject hMailServer.Application
        $hMail.Authenticate("Administrador", "ZTEv1326")

        # Crear dominio si no existe
        $domainName = "midominio.local"
        $domain = $hMail.Domains | Where-Object { $_.Name -eq $domainName }
        if (-not $domain) {
            $domain = $hMail.Domains.Add()
            $domain.Name = $domainName
            $domain.Active = $true
            $domain.Save()
        }

        # Crear cuentas de correo
        @(
            @{Name="usuario1"; Password="P@ssw0rd1"},
            @{Name="usuario2"; Password="P@ssw0rd2"}
        ) | ForEach-Object {
            $account = $domain.Accounts | Where-Object { $_.Address -eq "$($_.Name)@$domainName" }
            if (-not $account) {
                $account = $domain.Accounts.Add()
                $account.Address = "$($_.Name)@$domainName"
                $account.Password = $_.Password
                $account.Active = $true
                $account.MaxSize = 100
                $account.Save()
                Write-Host "Cuenta creada: $($account.Address)"
            }
        }

        # Configurar protocolos
        $hMail.Settings.Protocols.IMAP.Enabled = $true
        $hMail.Settings.Protocols.POP3.Enabled = $true
        $hMail.Settings.Protocols.SMTP.Enabled = $true
        $hMail.Settings.Protocols.Save()

        Write-Host "Configuración de hMailServer completada"
        $success = $true
    }
    catch {
        Write-Host "Intento $retryCount falló: $_"
        if ($retryCount -lt $maxRetries) {
            Start-Sleep -Seconds 10
            Restart-Service $serviceName -Force
            Start-Sleep -Seconds 10
        }
        else {
            Write-Host "No se pudo configurar hMailServer después de $maxRetries intentos"
            exit 1
        }
    }
}

# 6. Configurar firewall
Write-Host "Configurando reglas de firewall..."
New-NetFirewallRule -DisplayName "Allow SMTP" -Direction Inbound -Protocol TCP -LocalPort 25 -Action Allow -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "Allow POP3" -Direction Inbound -Protocol TCP -LocalPort 110 -Action Allow -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "Allow IMAP" -Direction Inbound -Protocol TCP -LocalPort 143 -Action Allow -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "Allow HTTP" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow -ErrorAction SilentlyContinue

# 7. Instalar y configurar SquirrelMail
$squirrelPath = "C:\inetpub\wwwroot\squirrelmail"
$squirrelUrl = "https://github.com/squirrelmail/squirrelmail/releases/download/1.4.22/squirrelmail-1.4.22.zip"

if (!(Test-Path $squirrelPath)) {
    try {
        Write-Host "Instalando SquirrelMail..."
        New-Item -Path $squirrelPath -ItemType Directory -Force
        Invoke-WebRequest -Uri $squirrelUrl -OutFile "$env:TEMP\squirrelmail.zip" -UseBasicParsing
        Expand-Archive -Path "$env:TEMP\squirrelmail.zip" -DestinationPath $squirrelPath -Force

        @"
<?php
\$imap_server_type = 'hmailserver';
\$imap_server_address = 'localhost';
\$imap_server_port = 143;
\$smtp_server_address = 'localhost';
\$smtp_server_port = 25;
\$domain = 'midominio.local';
?>
"@ | Out-File "$squirrelPath\config\config.php" -Encoding UTF8 -Force

        icacls $squirrelPath /grant "NT AUTHORITY\IUSR:(OI)(CI)F"
    }
    catch {
        Write-Host "Error al instalar SquirrelMail: $_"
        exit 1
    }
}

# 8. Configurar IIS
Import-Module WebAdministration
New-WebApplication -Name "squirrelmail" -Site "Default Web Site" -PhysicalPath $squirrelPath -ApplicationPool "DefaultAppPool"

# 9. Iniciar servicios
Start-Service $serviceName -ErrorAction SilentlyContinue
Start-Service SMTPSVC -ErrorAction SilentlyContinue
Start-Service W3SVC -ErrorAction SilentlyContinue

Write-Host "Configuración completada. Accede a: http://localhost/squirrelmail"
