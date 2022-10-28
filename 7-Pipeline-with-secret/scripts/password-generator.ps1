using module "modules/password-generator.psm1"
$ErrorActionPreference = "Stop"

$res = [PasswordGenerator]::Generate(11)
# set variable that use in future task
Write-Host "##vso[task.setvariable variable=sql-password;issecret=true]$res"