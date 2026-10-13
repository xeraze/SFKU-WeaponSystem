$root = "D:\Codding\SFKU"
$batches = @(
    @{id=1; files=@(
        @{path="ReplicatedStorage\Modules\Config.lua"; parent="RS:WaitForChild('Modules')"; name="Config"; class="ModuleScript"},
        @{path="ReplicatedStorage\Modules\DataStore.lua"; parent="RS:WaitForChild('Modules')"; name="DataStore"; class="ModuleScript"}
    )},
    @{id=2; files=@(
        @{path="ReplicatedStorage\Modules\Weapon\WeaponConfig.lua"; parent="RS:WaitForChild('Modules'):WaitForChild('Weapon')"; name="WeaponConfig"; class="ModuleScript"},
        @{path="ReplicatedStorage\Modules\Weapon\WeaponParser.lua"; parent="RS:WaitForChild('Modules'):WaitForChild('Weapon')"; name="WeaponParser"; class="ModuleScript"},
        @{path="ReplicatedStorage\Modules\Weapon\WeaponValidator.lua"; parent="RS:WaitForChild('Modules'):WaitForChild('Weapon')"; name="WeaponValidator"; class="ModuleScript"}
    )},
    @{id=3; files=@(
        @{path="ServerScriptService\Server\System\DoorSystem.lua"; parent="SSS:WaitForChild('Server'):WaitForChild('System')"; name="DoorSystem"; class="ModuleScript"},
        @{path="ServerScriptService\Server\System\RoleSystem.lua"; parent="SSS:WaitForChild('Server'):WaitForChild('System')"; name="RoleSystem"; class="ModuleScript"},
        @{path="ServerScriptService\Server\System\ControlRoom.lua"; parent="SSS:WaitForChild('Server'):WaitForChild('System')"; name="ControlRoom"; class="ModuleScript"},
        @{path="ServerScriptService\Server\System\WantedSystem.lua"; parent="SSS:WaitForChild('Server'):WaitForChild('System')"; name="WantedSystem"; class="ModuleScript"},
        @{path="ServerScriptService\Server\System\BriefcaseSystem.lua"; parent="SSS:WaitForChild('Server'):WaitForChild('System')"; name="BriefcaseSystem"; class="ModuleScript"},
        @{path="ServerScriptService\Server\System\ManagerComputer.lua"; parent="SSS:WaitForChild('Server'):WaitForChild('System')"; name="ManagerComputer"; class="ModuleScript"},
        @{path="ServerScriptService\Server\System\SurveillanceSystem.lua"; parent="SSS:WaitForChild('Server'):WaitForChild('System')"; name="SurveillanceSystem"; class="ModuleScript"},
        @{path="ServerScriptService\Server\System\HealthSystem.lua"; parent="SSS:WaitForChild('Server'):WaitForChild('System')"; name="HealthSystem"; class="ModuleScript"},
        @{path="ServerScriptService\Server\System\VirologySystem.lua"; parent="SSS:WaitForChild('Server'):WaitForChild('System')"; name="VirologySystem"; class="ModuleScript"}
    )},
    @{id=4; files=@(
        @{path="ServerScriptService\Server\System\Weapon\WeaponSystem.lua"; parent="SSS:WaitForChild('Server'):WaitForChild('System'):WaitForChild('Weapon')"; name="WeaponSystem"; class="ModuleScript"}
    )},
    @{id=5; files=@(
        @{path="ServerScriptService\Server\MainServer.lua"; parent="SSS:WaitForChild('Server')"; name="MainServer"; class="Script"}
    )},
    @{id=6; files=@(
        @{path="StarterPlayerScripts\ClientController.lua"; parent="SP:WaitForChild('StarterPlayerScripts')"; name="ClientController"; class="ModuleScript"},
        @{path="StarterPlayerScripts\WeaponClient.lua"; parent="SP:WaitForChild('StarterPlayerScripts')"; name="WeaponClient"; class="ModuleScript"},
        @{path="StarterPlayerScripts\Init.client.lua"; parent="SP:WaitForChild('StarterPlayerScripts')"; name="Init"; class="LocalScript"},
        @{path="StarterGui\MainMenu\MainMenuClient.lua"; parent="SG:WaitForChild('MainMenu')"; name="MainMenuClient"; class="ModuleScript"}
    )}
)

$setup = @"
local RS = game:GetService('ReplicatedStorage')
local SSS = game:GetService('ServerScriptService')
local SG = game:GetService('StarterGui')
local SP = game:GetService('StarterPlayer')
local function ensureFolder(parent, name)
  local f = parent:FindFirstChild(name)
  if not f then f = Instance.new('Folder') f.Name = name f.Parent = parent end
  return f
end
local function ensureModule(parent, name, className, content)
  local m = parent:FindFirstChild(name)
  if not m then m = Instance.new(className) m.Name = name m.Parent = parent end
  m.Source = content
  print('OK: ' .. name)
end
ensureFolder(RS, 'Modules')
ensureFolder(RS:WaitForChild('Modules'), 'Weapon')
ensureFolder(SSS, 'Server')
ensureFolder(SSS:WaitForChild('Server'), 'System')
ensureFolder(SSS:WaitForChild('Server'):WaitForChild('System'), 'Weapon')
ensureFolder(SG, 'MainMenu')
ensureFolder(SP, 'StarterPlayerScripts')
"@

foreach ($batch in $batches) {
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine($setup)
    foreach ($f in $batch.files) {
        $fullPath = Join-Path $root $f.path
        if (Test-Path $fullPath) {
            $content = Get-Content -Path $fullPath -Raw -Encoding UTF8
            $escaped = $content.Replace('\', '\\').Replace("'", "\'").Replace("`r`n", "\n").Replace("`n", "\n").Replace("`r", "\n")
            [void]$sb.AppendLine("ensureModule($($f.parent), '$($f.name)', '$($f.class)', '$escaped')")
        }
    }
    [void]$sb.AppendLine("print('BATCH $($batch.id) DONE')")
    $outPath = Join-Path $root "cmd_$($batch.id).lua"
    [System.IO.File]::WriteAllText($outPath, $sb.ToString())
    $size = (Get-Item $outPath).Length
    Write-Host "cmd_$($batch.id).lua - $size bytes"
    if ($size -gt 95000) { Write-Host "WARNING: cmd_$($batch.id).lua exceeds 95KB!" -ForegroundColor Red }
}
