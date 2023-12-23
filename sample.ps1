function system_info(){
  $res = ""
  $mother = Get-WmiObject Win32_ComputerSystemProduct
  $bios = Get-WmiObject Win32_BIOS
  $cpu = Get-WmiObject Win32_Processor
  $mem = Get-WmiObject Win32_PhysicalMemory
  $disk = Get-WmiObject Win32_LogicalDisk

  $lines = 
  "メーカー: $($mother.Vendor)",
  "製品: $($mother.Name) (version:$($mother.Version), $($mother.IdentifyingNumber))",
  "BIOS: $($bios.Manufacturer) ($($bios.Name))"
  "CPU: $($cpu.Name) (Socket: $($cpu.SocketDesignation))",

  $lines -join "`n"
}

function Get-SystemInfo {
  # システム情報を取得
  $computerSystem = Get-CimInstance -ClassName CIM_ComputerSystem
  $os = Get-CimInstance -ClassName CIM_OperatingSystem
  $cpu = Get-CimInstance -ClassName CIM_Processor
  $rams = Get-CimInstance -ClassName CIM_PhysicalMemory
  $disks = Get-CimInstance -ClassName Win32_DiskDrive
  $gpus = Get-CimInstance -ClassName Win32_VideoController

  # 出力用の文字列を初期化
  $output = "メーカー名: $($computerSystem.Manufacturer)`n"
  $output += "型番: $($computerSystem.Model)`n"
  $output += "OS: $($os.Caption)`n"
  $output += "CPU: $($cpu.Name), コア数: $($cpu.NumberOfCores)`n"

  # RAM情報
  $totalRam = 0
  $ramDetails = ""
  foreach ($ram in $rams) {
      $totalRam += $ram.Capacity
      $ramDetails += "RAM: [容量: $([math]::Round($ram.Capacity / 1GB, 2)) GB, 型番: $($ram.PartNumber)]`n"
  }
  $totalRamGB = [math]::Round($totalRam / 1GB, 2)
  $output += "合計RAM: ${totalRamGB}GB`n"
  $output += $ramDetails

  # ストレージ情報
  foreach ($disk in $disks) {
      $diskSizeGB = "{0:N2}" -f ($disk.Size / 1GB)
      $output += "ストレージ: [モデル: $($disk.Model), 容量: ${diskSizeGB} GB]`n"
  }

  # GPU情報
  foreach ($gpu in $gpus) {
      $output += "GPU: [名前: $($gpu.Name), ドライバーバージョン: $($gpu.DriverVersion)]`n"
  }

  # 結果の表示
  Write-Host $output
}

echo $(system_info)