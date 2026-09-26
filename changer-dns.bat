@echo off
setlocal enabledelayedexpansion
title Changer le serveur DNS

set "SCRIPT_VERSION=1.0.1"
set "VERSION_URL=https://raw.githubusercontent.com/dydy13014/changer-dns-windows/main/VERSION"
set "REPO_URL=https://github.com/dydy13014/changer-dns-windows"

:: --- Verification des droits administrateur, elevation auto si besoin ---
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Ce script a besoin des droits administrateur, relancement en cours...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: --- Verification de mise a jour (notification uniquement) ---
:: N'ecrit, ne telecharge et ne remplace jamais rien automatiquement -- juste
:: un signal si une version plus recente existe sur GitHub, pour rester
:: coherent avec la consigne du post original (relire le script avant de le
:: relancer). Timeout court (3s) + erreurs masquees : si curl est absent
:: (Windows < 10 1803) ou hors ligne, la verification est silencieusement
:: sautee, le script continue normalement.
set "latestVersion="
for /f "usebackq delims=" %%v in (`curl -s -m 3 "%VERSION_URL%" 2^>nul`) do set "latestVersion=%%v"
if not "%latestVersion%"=="" if not "%latestVersion%"=="%SCRIPT_VERSION%" (
    echo.
    echo ============================================
    echo   Nouvelle version disponible : %latestVersion%  ^(vous avez %SCRIPT_VERSION%^)
    echo   %REPO_URL%
    echo ============================================
    echo.
    pause
)

:menu
cls
echo ============================================
echo   Choisissez un serveur DNS
echo ============================================
echo  1. Google Public DNS      (IPv4 + IPv6)
echo  2. OpenDNS                (IPv4 uniquement)
echo  3. Cloudflare DNS         (IPv4 + IPv6)
echo  4. Quad9                  (IPv4 + IPv6)
echo  5. Comodo Secure DNS      (IPv4 uniquement)
echo  6. Yandex.DNS             (IPv4 uniquement)
echo  7. AdGuard DNS            (IPv4 + IPv6)
echo  0. Quitter
echo ============================================
set "choice="
set /p choice="Votre choix : "

set "primaryDNSv4="
set "secondaryDNSv4="
set "primaryDNSv6="
set "secondaryDNSv6="

if "%choice%"=="1" (
    set primaryDNSv4=8.8.8.8
    set secondaryDNSv4=8.8.4.4
    set primaryDNSv6=2001:4860:4860::8888
    set secondaryDNSv6=2001:4860:4860::8844
) else if "%choice%"=="2" (
    set primaryDNSv4=208.67.222.222
    set secondaryDNSv4=208.67.220.220
) else if "%choice%"=="3" (
    set primaryDNSv4=1.1.1.1
    set secondaryDNSv4=1.0.0.1
    set primaryDNSv6=2606:4700:4700::1111
    set secondaryDNSv6=2606:4700:4700::1001
) else if "%choice%"=="4" (
    set primaryDNSv4=9.9.9.9
    set primaryDNSv6=2620:fe::fe
) else if "%choice%"=="5" (
    set primaryDNSv4=8.26.56.26
    set secondaryDNSv4=8.20.247.20
) else if "%choice%"=="6" (
    set primaryDNSv4=77.88.8.8
    set secondaryDNSv4=77.88.8.1
) else if "%choice%"=="7" (
    set primaryDNSv4=94.140.14.14
    set secondaryDNSv4=94.140.15.15
    set primaryDNSv6=2a10:50c0::ad1:ff
    set secondaryDNSv6=2a10:50c0::ad2:ff
) else if "%choice%"=="0" (
    exit /b
) else (
    echo.
    echo Choix invalide, appuyez sur une touche pour reessayer.
    pause >nul
    goto menu
)

:: --- Liste des interfaces reseau reellement actives (fiable, via PowerShell) ---
:: netsh+findstr sur "netsh interface show interface" capture la ligne entiere
:: (etat + type + nom) et non le nom seul -> on evite ce piege en interrogeant
:: directement Get-NetAdapter, qui renvoie un nom d'interface propre et exact.
set "interfaceList=%temp%\dns_interfaces.txt"
powershell -NoProfile -Command "(Get-NetAdapter -Physical | Where-Object Status -eq 'Up').Name" > "%interfaceList%"

set /a count=0
for /f "usebackq delims=" %%i in ("%interfaceList%") do (
    set /a count+=1
    set "iface!count!=%%i"
)

if %count%==0 (
    echo Aucune interface reseau active trouvee. Verifiez votre connexion.
    del "%interfaceList%" >nul 2>&1
    pause
    exit /b
)

echo.
echo Application des DNS a %count% interface(s) active(s) :

for /l %%n in (1,1,%count%) do (
    set "iface=!iface%%n!"
    echo  - !iface!

    netsh interface ipv4 set dns name="!iface!" source=static addr=%primaryDNSv4% >nul
    if not "%secondaryDNSv4%"=="" netsh interface ipv4 add dns name="!iface!" addr=%secondaryDNSv4% index=2 >nul

    if not "%primaryDNSv6%"=="" (
        netsh interface ipv6 set dns name="!iface!" source=static addr=%primaryDNSv6% >nul
        if not "%secondaryDNSv6%"=="" netsh interface ipv6 add dns name="!iface!" addr=%secondaryDNSv6% index=2 >nul
    )
)

del "%interfaceList%" >nul 2>&1

echo.
echo ============================================
echo   Configuration DNS mise a jour :
echo ============================================
ipconfig /all | findstr /c:"Serveurs DNS" /c:"DNS Servers"

echo.
pause
exit /b
