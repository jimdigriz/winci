reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v Type /d NoSync /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /t REG_QWORD /d 1 /f

E:\virtio-win-gt-x64.msi /quiet /passive /norestart
E:\virtio-win-guest-tools.exe /quiet /passive /norestart

@rem https://docs.microsoft.com/en-US/windows/deployment/update/waas-wu-settings#configuring-automatic-updates-by-editing-the-registry
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f

@rem https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse
@rem ...does not work due to https://github.com/MicrosoftDocs/windowsserverdocs/issues/2074
@rem powershell.exe -Command "Add-WindowsCapability -Online -Name OpenSSH.Server"
@rem powershell.exe -Command "Start-Service sshd"
@rem powershell.exe -Command "Set-Service -Name sshd -StartupType Automatic"
@rem powershell.exe -Command "if (!(Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) { New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 }"
@rem https://github.com/PowerShell/Win32-OpenSSH/wiki/Install-Win32-OpenSSH-Using-MSI
curl -f -o C:\\Windows\\Temp\\OpenSSH-Win64.msi http://%PACKER_HTTP_ADDR%/OpenSSH-Win64.msi
msiexec.exe /i C:\Windows\Temp\OpenSSH-Win64.msi
del C:\Windows\Temp\OpenSSH-Win64.msi

@rem disable screensaver and power saving
reg add "HKCU\Control Panel\Desktop" /v ScreenSaveActive /t REG_DWORD /d 0 /f
powercfg -x -monitor-timeout-ac 0
powercfg -x -monitor-timeout-dc 0

@rem https://docs.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/shutdown-clear-virtual-memory-pagefile
@rem this is perfect as we use the image in snapshot mode and want that file zero'd out to make the image smaller
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 1 /f

@rem no need to hibernate in a VM
powercfg.exe /hibernate off

@rem qcow2 image is compressed with zlib which is better than the NTFS method
@rem with compactos:always/sdelete 30min build and +10% larger qcow2
@rem with compactos:never 25min build and +5% larger qcow2
@rem not run at all, 20min build
@rem compact.exe /compactos:never

@rem use powershell version as we get better running status (Defrag automatically does ReTrim)
powershell.exe -Command "Optimize-Volume -Verbose -DriveLetter C -Defrag -NormalPriority"

@rem DISABLED - retrim makes this unnecessary, sdelete actually makes the output image larger!
@rem https://docs.microsoft.com/en-us/sysinternals/downloads/sdelete
@rem reg add "HKCU\Software\Sysinternals\SDelete" /v EulaAccepted /t REG_DWORD /d 1 /f
@rem A:\Autounattend\sdelete64.exe -nobanner -z C:
