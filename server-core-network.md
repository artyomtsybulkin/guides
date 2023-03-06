# Windows Server: Network configuration

> First of all install drivers updates using HP Service Pack or Dell Support Assistance application

1. Workgroup: ```DOMAIN```
2. Computer name: ```vhostX``` (where ```X``` as number for Hyper-V host)
3. Configure Remote Management: ```Enable``` (for Windows Admin Center)
4. Windows Update Settings: ```Manual```
5. Remote Desktop: ```Disabled```
6. Network settings: ```IPv4 static``` and ```IPv6 auto```
7. Date and time: ```Eastern``` time via one of these NTP servers

```cmd
0.ca.pool.ntp.org
1.ca.pool.ntp.org
129.6.15.28
129.6.15.29
```

*Sources: [ntppool.org](https://www.ntppool.org/zone/ca), [tf.nist.gov](https://tf.nist.gov/tf-cgi/servers.cgi)*

8. Telemetry: ```Security```

9. Edit registry key to change primary DNS suffix:

```cmd
Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters
String NV Domain: domain.local
```

10. UPDATE: Starting from Windows Server 2016 we got ability to configure [SET (Switch Embedded Teaming) Hyper-V switch](https://docs.microsoft.com/en-us/azure-stack/hci/concepts/host-network-requirements#set)

```powershell
New-VMSwitch -Name "vSwitch" -NetAdapterName "Eth1","Eth2","Eth3" `
    -EnableIov $true -EnableEmbeddedTeaming $true

Set-VMSwitchTeam -Name "vSwitch" -LoadBalancingAlgorithm Dynamic
```

11. Set Hyper-V host OS VLAN for management OS

```powershell
Get-VMNetworkAdapter -SwitchName vSwitch -ManagementOS `
    | Set-VMNetworkAdapterVlan -Access -VlanId 32
```

12. Disable VMQ and offloading

```powershell
Disable-NetAdapterVmq *
Disable-NetAdapterChecksumOffload *
Disable-NetAdapterIPsecOffload *
Disable-NetAdapterLso *
```

13. (Optional) Add ```Eth4``` adapter to switch team

```powershell
Set-VMSwitchTeam -Name "vSwitch" -NetAdapterName "Eth1","Eth2","Eth3","Eth4"
```

Fianlly start `sconfig` and setup IP for adapter using UI.

---

## Archive: LACP NIC Team for Windows Server 2012 R2 and earlier

1. Next let's configure NIC Team in LACP mode using PowerShell

2. Сreate NIC Team and connect to LAN.

```powershell
Get-NetAdapter
Rename-NetAdapter -Name "Ethernet" -NewName "Ethernet 1"
New-NetLbfoTeam -Name "vLACP" `
    -TeamMembers "Ethernet 1","Ethernet 2","Ethernet 3","Ethernet 4" `
    -TeamNicName "vLACP" -TeamingMode Lacp `
    -LoadBalancingAlgorithm Dynamic
```

3. Create vSwitch

```powershell
New-VMSwitch -Name vSwitch -AllowManagementOS $True `
    -NetAdapterName "vLACP"
Rename-NetAdapter -Name "vEthernet (vSwitch)" `
    -NewName "vEthernet"
Get-VMNetworkAdapter -SwitchName vSwitch -ManagementOS `
    | Set-VMNetworkAdapterVlan -Access -VlanId 32
```
