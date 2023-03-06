# Windows: Volume Shadow Copy

You can find pre-configured Windows Task in Tasks folder. Ensure that Task running with user "NT AUTHORITY\SYSTEM" permissions and "Next Run Time" is correct

## 1. Configure Volume Shadow Copy (for Workstations and Servers instances as well)

```cmd
vssadmin Resize ShadowStorage /For=C: /On=C: /MaxSize=20%
vssadmin Resize ShadowStorage /For=D: /On=D: /MaxSize=20%
```

## 2. Create snapshot on **Windows 7/10/11** (24 hours by default, and reduced to 4 hours using registry value below), save to `*.reg` file and merge

```cmd
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore]
"SystemRestorePointCreationFrequency"=dword:00000168
```

> On Windows Server machines we processing 2 snapshots per day and 1 snapshot on Windows Workstations

```cmd
wmic /Namespace:\\root\DEFAULT Path SystemRestore Call CreateRestorePoint "<Daily snapshot>", 100, 7
```

## 3. Create snapshot on ```Windows Server 2008-2022``` (easy to configure using GUI)

```cmd
wmic ShadowCopy Call Create Volume="C:\"
wmic ShadowCopy Call Create Volume="D:\"
```

## 4. Monitor snapshot counter using Zabbix

```cmd
wmic ShadowCopy get Count | findstr [0-9] | find /c /v ""
```

## 5 (Optional). Other ways to create snapshots

```powershell
# 1. Prior Windows 10 and Windows Server 2019
(Get-WmiObject -List "Win32_ShadowCopy").Create("C:\","ClientAccessible")

# 3. After Windows 10 and Windows Server 2019
Invoke-CimMethod -MethodName Create -ClassName Win32_ShadowCopy -Arguments @{ Volume= "C:\\" }

# 4. On Windows 10 and 11
Checkpoint-Computer -Description "Daily"
```
