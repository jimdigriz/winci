@rem https://docs.microsoft.com/en-US/windows/deployment/update/waas-wu-settings#configuring-automatic-updates-by-editing-the-registry
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f

reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v Type /d NoSync /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /t REG_QWORD /d 1 /f

@rem https://docs.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/shutdown-clear-virtual-memory-pagefile
@rem this is perfect as we use the image in snapshot mode and want that file zero'd out to make the image smaller
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 1 /f

@rem for our needs Windows Defender is not needed
powershell.exe -Command "Set-MpPreference -DisableRealTimeMonitoring $true"

E:\virtio-win-gt-x64.msi /quiet /passive /norestart
E:\virtio-win-guest-tools.exe /quiet /passive /norestart

@rem disable screensaver and power saver
powershell.exe -Command "Set-ItemProperty 'HKCU:\Control Panel\Desktop' -Name ScreenSaveActive -Value 0 -Type DWord"
powercfg -x -monitor-timeout-ac 0
powercfg -x -monitor-timeout-dc 0

@rem no need to hibernate in a VM
powercfg.exe /hibernate off

compact.exe /compactos:always

@rem retrims too
defrag.exe C: /u /v /h

@rem https://docs.microsoft.com/en-us/sysinternals/downloads/sdelete
reg add "HKCU\Software\Sysinternals\SDelete" /v EulaAccepted /t REG_DWORD /d 1 /f
A:\Autounattend\sdelete64.exe -nobanner -z C:
