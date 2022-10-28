$ErrorActionPreference = "Stop"

class ProvisionRunner{
  [void] CreateResources([string] $resource_group, [string] $template_file, [string] $parameters_file){
    $bicep_configuration_path = $PSScriptRoot + "/../../bicep_configuration/configuration.json"

    $configuration = (Get-Content $bicep_configuration_path -Raw) | ConvertFrom-Json
    $configuration.sqlAdministratorPasswordGenerated = $env:SQL_PASSWORD
    $configuration = $configuration | ConvertTo-Json -Compress | Out-File $($bicep_configuration_path)

    Write-Host "Start provisioning"
    az deployment group create --resource-group $resource_group --template-file $template_file --parameters $parameters_file
    Write-Host "Provision done" -ForegroundColor Green

    $configuration = (Get-Content $bicep_configuration_path -Raw) | ConvertFrom-Json
    $configuration.sqlAdministratorPasswordGenerated = ""
    $configuration = $configuration | ConvertTo-Json -Compress | Out-File $($bicep_configuration_path)
  }
}
