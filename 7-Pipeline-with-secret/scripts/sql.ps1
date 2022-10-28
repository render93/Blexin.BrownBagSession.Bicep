using module "modules/sql.psm1"

param ([string] $parameters_file)
$ErrorActionPreference = "Stop"

$runner = [SqlRunner]::new($parameters_file)
$runner.Init()