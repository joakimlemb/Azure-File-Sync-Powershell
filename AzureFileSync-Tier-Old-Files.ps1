$days_old = 14
$path = "d:\afs01"

Import-Module "C:\Program Files\Azure\StorageSyncAgent\StorageSync.Management.ServerCmdlets.dll"

add-type -type  @'
using System;
using System.Runtime.InteropServices;
using System.ComponentModel;
 
namespace Disk
{
    public class SizeInfo
    {
        [DllImport("kernel32.dll", SetLastError=true, EntryPoint="GetCompressedFileSize")]
        static extern uint GetCompressedFileSizeAPI(string lpFileName, out uint lpFileSizeHigh);
 
        public static ulong GetCompressedFileSizeFunction(string FileName,bool SizeInMB)
        {
            uint HighOrder;
            uint LowOrder;
            LowOrder = GetCompressedFileSizeAPI(FileName, out HighOrder);
            int error = Marshal.GetLastWin32Error();
            if (HighOrder == 0 && LowOrder == 0xFFFFFFFF && error != 0)
                throw new Win32Exception(error);
            else
                if (SizeInMB)
                    return ((((ulong)HighOrder << 32) + LowOrder)/1024)/1024;
                else
                    return ((ulong)HighOrder << 32) + LowOrder;
        }
    }
}
'@

$i = 0
Get-ChildItem -File -Path "$path" -Recurse | Where-Object { ($_.LastWriteTime -lt (get-date).AddDays(-$days_old)) -and ([Disk.SizeInfo]::GetCompressedFileSizeFunction($_.FullName,$false) -gt 65536) } | % {
    $i++
    $_.FullName +" "+ [Disk.SizeInfo]::GetCompressedFileSizeFunction($_.FullName,$false)
    Invoke-StorageSyncCloudTiering -Path $_.FullName
}
Write-Output "Tiered $i files"