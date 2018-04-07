Param(
    [Parameter(Mandatory=$True)]
    [string]$FilePath
)

Import-Module "C:\Program Files\Azure\StorageSyncAgent\StorageSync.Management.ServerCmdlets.dll"
If (Get-Module | Where { $_.Name -eq "StorageSync.Management.ServerCmdlets" }) {
    if([System.IO.File]::Exists("$FilePath")){
        Write-Output "Tiering file: $FilePath"
        Invoke-StorageSyncCloudTiering -Path "$FilePath"
    } else {
        Write-Output "Could not find file: $FilePath"
    }
}
Pause