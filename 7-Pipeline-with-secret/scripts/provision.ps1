using module "modules/provision.psm1"

param ([string] $resource_group, [string] $template_file, [string] $parameters_file)
$ErrorActionPreference = "Stop"

$runner = [ProvisionRunner]::new()
$runner.CreateResources($resource_group, $template_file, $parameters_file)