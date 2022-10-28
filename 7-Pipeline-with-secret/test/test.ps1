$ErrorActionPreference = "Stop"

[string] $resource_group = "bb-gherard"
[string] $template_file = "$PSScriptRoot/../main.bicep"
[string] $parameters_file = "$PSScriptRoot/../main.parameters.json"
[string] $sql_password = "Qwerty123!"
[securestring] $sql_password_secure = ConvertTo-SecureString $sql_password -AsPlainText -Force

[string] $runner_path = "$PSScriptRoot/../scripts/provision.ps1"

& $runner_path $resource_group $template_file $parameters_file $sql_password_secure