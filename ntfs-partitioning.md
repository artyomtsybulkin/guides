# Windows Server: NTFS partitioning

*Partition configuration sequence you can find below, and full output is after.*

## General partitioning sequence

### 1. Run PowerShell session via Task Manager interactive menu using Ctrl+Alt+Del

### 2. Start ```diskpart``` utility and use ```list disk``` command

```cmd
C:\powershell
PS C:\Windows\system32> diskpart
DISKPART> list disk
```

### 3. Select Disk 1 for partitioning and then bring it Online

```cmd
DISKPART> select disk 1
DISKPART> online disk
```

### 4. Create Primary partition on Disk 1. If error `The media is write protected.` occurs clear Read-Only attribute use commands in this snippet

```cmd
DISKPART> attr disk clear readonly
DISKPART> create partition primary
```

### 5. Continue working with Partition 2 (Partition 1 is reserved space)

```cmd
DISKPART> list partition
DISKPART> select partition 2
```

### 6. Format volume with Cluster size 32K (for example, but next use table belowas guidance). Source: [Microsoft Support Pages](https://support.microsoft.com/en-us/topic/default-cluster-size-for-ntfs-fat-and-exfat-9772e6f1-e31a-00d7-e18f-73169155af95)

| Volume size, Tb | Cluster size, Kb | Unit value |
| :--- | :--- | :--- |
| 1..16 | 4K | 4096 |
| 16..32 | 8K | 8192 |
| 32..64 | 16K | 16384 |
| 64..128 | 32K | 32768 |
| 128..256 | 64K | 65536 |

```cmd
DISKPART> format fs=ntfs label="Data" quick unit=32768
```

### 7. Assign drive letter for new volume

```cmd
DISKPART> assign letter=D
DISKPART> exit
```

### 8. Finally checking volume settings via PowerShell (output suppressed)

```powershell
PS C:\Windows\system32> get-volume -DriveLetter D | select *
```

### 9 (Optional). Partition to store backup files, archives or other oversized files as well as VHD/VHDX files

```powershell
PS C:\Windows\system32> Format-Volume -DriveLetter D -FileSystem NTFS -AllocationUnitSize 32KB -UseLargeFRS
```

> Tip: Sometimes it's impossible to delete partition of unknown type without force flag. To accomplish this use this command: `DISKPART> delete partition override`

## Full output

```cmd
PS C:\Windows\system32> diskpart

Microsoft DiskPart version 10.0.17763.1

Copyright (C) Microsoft Corporation.
On computer: localhost

DISKPART> list disk

  Disk ###  Status         Size     Free     Dyn  Gpt
  --------  -------------  -------  -------  ---  ---
  Disk 0    Online          465 GB      0 B
  Disk 1    Online           18 TB    18 TB

DISKPART> select disk 1

Disk 1 is now the selected disk.

DISKPART> online disk

Online a disk that is currently marked as offline.

DISKPART> create partition primary

Disk is uninitialized, initializing it to GPT.

DiskPart has encountered an error: The media is write protected.
See the System Event Log for more information.

DISKPART> attr disk clear readonly

Disk attributes cleared successfully.

DISKPART> create partition primary

Disk is uninitialized, initializing it to GPT.

DiskPart succeeded in creating the specified partition.

DISKPART> list partition

  Partition ###  Type              Size     Offset
  -------------  ----------------  -------  -------
  Partition 1    Reserved            15 MB    17 KB
* Partition 2    Primary             18 TB    16 MB

DISKPART> select partition 2

Partition 2 is now the selected partition.

DISKPART> list disk

  Disk ###  Status         Size     Free     Dyn  Gpt
  --------  -------------  -------  -------  ---  ---
  Disk 0    Online          465 GB      0 B
* Disk 1    Online           18 TB      0 B        *

DISKPART> list partition

  Partition ###  Type              Size     Offset
  -------------  ----------------  -------  -------
  Partition 1    Reserved            15 MB    17 KB
* Partition 2    Primary             18 TB    16 MB

DISKPART> format fs=ntfs label="Data" quick unit=32768

  100 percent completed

DiskPart successfully formatted the volume.

DISKPART> assign letter=D

DiskPart successfully assigned the drive letter or mount point.

DISKPART> exit

Leaving DiskPart...

PS C:\Windows\system32> get-volume -DriveLetter D | select *

OperationalStatus     : OK
HealthStatus          : Healthy
DriveType             : Fixed
FileSystemType        : NTFS
DedupMode             : NotAvailable
...
AllocationUnitSize    : 32768
DriveLetter           : D
FileSystem            : NTFS
FileSystemLabel       : Data
Size                  : 20001577730048
SizeRemaining         : 20001354678272
...

PS C:\Windows\system32> Format-Volume -DriveLetter D -FileSystem NTFS -AllocationUnitSize 32KB -UseLargeFRS
```
