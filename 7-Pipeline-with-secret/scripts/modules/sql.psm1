$ErrorActionPreference = "Stop"

class SqlRunner {
  
  [string] $environment

  SqlRunner([string] $parameters_file) {
    $content = (Get-Content $parameters_file -Raw) | ConvertFrom-Json
    $this.environment = $content.parameters[0].environment.value
  }

  [void] Init() {
    $file_path = $PSScriptRoot + "/../data/init.sql"
    Invoke-Sqlcmd -ConnectionString $this.GetConnectionString() -InputFile $file_path
  }

  hidden [string] GetConnectionString(){
    return $this.GetSecretValue("sqlconnectionstringgenerated-$($this.environment)")
  }

  hidden [string] GetSecretValue([string] $secret_name){
    $secret_id = $this.GetSecretId($secret_name)
    $res = (az keyvault secret show --id $secret_id) | ConvertFrom-Json | Select-Object value

    return $res.value
  }

  hidden [string] GetSecretId([string] $secret_name) {
    $keyVaultName = "kv-bicepsession-main"
    $secretEntry = (az keyvault secret show --name $secret_name --vault-name $keyVaultName | ConvertFrom-Json) | Select-Object id
    return $secretEntry.id
  }
}