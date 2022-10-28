$ErrorActionPreference = "Stop"

class PasswordGenerator {
  
  static [string] Generate([int] $length) {
    $charSet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.ToCharArray()
    $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $bytes = New-Object byte[]($length)
     
    $rng.GetBytes($bytes)
     
    $result = New-Object char[]($length)
     
    for ($i = 0 ; $i -lt $length ; $i++) {
      $result[$i] = $charSet[$bytes[$i] % $charSet.Length]
    }
    $res = (-join $result)
    return $res + "%!"
    
    # return ConvertTo-SecureString $result -AsPlainText -Force
  }
}