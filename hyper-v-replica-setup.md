# Windows Server: Hyper-V Replica setup

> This guide explains how to configure Hyper-V Replica using SSL

1. Complete IP settings configuration using static IPv4/IPv6 
2. Configure server names with suffixes

```r
# Computer name for vhost1
wmic computersystem where name="%COMPUTERNAME%" rename "vhost1"
# Computer name for vhost2
wmic computersystem where name="%COMPUTERNAME%" rename "vhost2"
```

And on both servers (replace `domain.local` with appropriate value)

```r
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters]
"NV Domain"="domain.local"
```

3. Save lines to ```hosts``` (```C:\Windows\System32\drivers\etc```) files on both servers

```cmd
192.168.1.1 vhost1.domain.local
192.168.1.2 vhost2.domain.local
```

4. Make sure registry value updated to allow self-signed certificates usage

```r
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization\Replication]
"DisableCertRevocationCheck"=dword:00000001
```

5. Configure Firewall on target replica server

```cmd
netsh advfirewall firewall add rule name = "Hyper-V Replica" dir = in protocol = tcp action = allow localport = 443 remoteip = localsubnet profile = Any
```

6 (OPTIONAL). On remote/offsite target replica server use ```remoteip = any``` or better define addresses ```remoteip = 157.60.0.1,172.16.0.0/16``` for example

```cmd
netsh advfirewall firewall add rule name = "Hyper-V Replica" dir = in protocol = tcp action = allow localport = 443 remoteip = any profile = Any
```

7. Install Root certificate on both servers using .pfx file, including *Extended properties* and make it *Exportable*, Root certificate generation script below. THis certificate should be placed on each computer to Trusted Root Certificate Authority

```powershell
$authority = "Hyper-V Replica Root Certificate"

New-SelfSignedCertificate `
-Type Custom `
-KeyExportPolicy Exportable `
-Subject $authority `
-CertStoreLocation "Cert:\LocalMachine\My" `
-KeySpec "Signature" `
-KeyUsage "CertSign" `
-NotAfter (Get-Date).AddDays(3650)
```

8. Install host certificates signed by Root certificate on corresponding host. Hosts certificate generation script below

```powershell
$subject1 = "vhost1.domain.local"
$subject2 = "vhost2.domain.local"
$issuer = "Hyper-V Replica Root Certificate"

$root = Get-ChildItem -Path cert:\LocalMachine\My `
| Where-Object -Property Subject -EQ "CN=$issuer" `
| Select-Object -Property Thumbprint -ExpandProperty Thumbprint

New-SelfSignedCertificate `
-Type "Custom" `
-KeyExportPolicy "Exportable" `
-Subject "CN=$subject1" `
-CertStoreLocation Cert:\LocalMachine\My `
-KeySpec KeyExchange `
-TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.1,1.3.6.1.5.5.7.3.2") `
-Signer Cert:\LocalMachine\My\$root `
-Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" `
-NotAfter (Get-Date).AddDays(3650)

New-SelfSignedCertificate `
-Type "Custom" `
-KeyExportPolicy "Exportable" `
-Subject "CN=$subject2" `
-CertStoreLocation Cert:\LocalMachine\My `
-KeySpec KeyExchange `
-TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.1,1.3.6.1.5.5.7.3.2") `
-Signer Cert:\LocalMachine\My\$root `
-Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" `
-NotAfter (Get-Date).AddDays(3650)
```
