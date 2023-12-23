function Export-Spec {
  $dir = ".\spec-$env:COMPUTERNAME"
  new-item -path $dir -ItemType Directory -Force | Out-Null

  $cim_classes = @(
    "CIM_ComputerSystem",
    "CIM_OperatingSystem",
    "CIM_BIOSElement",
    "CIM_Processor",
    "CIM_VideoController",
    "CIM_PhysicalMemory",
    "CIM_DiskDrive"
  )
  
  foreach ($class in $cim_classes) {
    Get-CimInstance $class | Select-Object * > "$dir\$class.txt"
  }
}

function Show-Spec {
  function gb($bytes) {
    "$([Math]::Ceiling($bytes / 1GB))GB"
  }

  function mb($bytes) {
    "$([Math]::Ceiling($bytes / 1MB))MB"
  }

  $comp = Get-CimInstance CIM_ComputerSystem
  $bios = Get-CimInstance CIM_BIOSElement
  Write-Output @(
    "* SystemFamily: $($comp.SystemFamily.trim())"
    "  * Model: $($comp.Model.trim())"
    "  * Manufacturer: $($comp.Manufacturer.trim())"
    "  * BIOS: $($bios.Name.trim()) (Version: $($bios.Version.trim()))"
  )

  $os = Get-CimInstance CIM_OperatingSystem
  Write-Output @(
    "* OS: $($os.Caption.trim())"
    "  * Version: $($os.Version.trim())"
    "  * Architecture: $($os.OSArchitecture.trim())"
  )

  $cpu = Get-CimInstance CIM_Processor
  Write-Output @(
    "* CPU: $($cpu.Name.trim())"
    "  * Max: $($cpu.MaxClockSpeed / 1000) GHz"
    "  * Cores: $($cpu.NumberOfCores) ($($cpu.ThreadCount) Threads)"
    "  * Cache Size: L2 $(mb ($cpu.L2CacheSize * 1KB)), L3 $(mb ($cpu.L3CacheSize * 1KB))"
  )

  Write-Output "* Graphics:"
  Get-CimInstance CIM_VideoController | ForEach-Object {
    Write-Output @(
      "  * $($_.VideoProcessor.trim()):"
      "    * RAM: $(gb $_.AdapterRAM)"
      "    * Connected Display: $($_.VideoModeDescription.trim()) ($($_.MaxRefreshRate) fps)"
    )
  }
  
  $mems = Get-CimInstance CIM_PhysicalMemory
  Write-Output "* Memories: $(gb $comp.TotalPhysicalMemory) (count:$($mems.count))"
  $mems | ForEach-Object {
    Write-Output @(
      "  * $($_.PartNumber.trim()) (Manufacturer: $($_.Manufacturer.trim())):"
      "    * Size: $(gb $_.Capacity)"
      "    * Speed: $($_.Speed) MHz (data width: $($_.DataWidth) bits)"
    )
  }

  Get-CimInstance CIM_DiskDrive | ForEach-Object {
    "* Storage: $($_.Model.trim())"
    "  * Size: $(gb $_.Size)"
  }
  Write-Output ""
}