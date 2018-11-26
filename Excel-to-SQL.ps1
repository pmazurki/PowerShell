$SQLServer = ip
$SQLDBName = nameDB
$uid = user
$pwd = password
$file= Import-Excel .\FileXls.xlsx -DataOnly

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Server = $SQLServer; Database = $SQLDBName; User Id = $uid; Password = $pwd;"
$sqlConnection.Open()

$Command = New-Object System.Data.SQLClient.SQLCommand
$Command.Connection = $SqlConnection
$Command.CommandText = "INSERT INTO [nameDB].[dbo].[Tabel] (Nr,UserName,UserSurname)  
                       VALUES (@Nr,@UserName,@UserSurname"

$Command.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Nr",           [Data.SQLDBType]::Char,      4)))   | Out-Null $Command.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@UserName",     [Data.SQLDBType]::NVarChar, 64)))   | Out-Null
$Command.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@UserSurname",  [Data.SQLDBType]::NVarChar, 64)))   | Out-Null

$file|`
   ForEach-Object{	
   
   $Command.Parameters[0].Value= if($_.NR      -eq $null){''} else{$_.NR};   
   $Command.Parameters[1].Value= if($_.Name    -eq $null){''} else{$_.Name}; 
   $Command.Parameters[2].Value= if($_.SURNAME -eq $null){''} else{$_.SURNAME};
  
   $Command.ExecuteNonQuery();

} | Out-Null

if ($sqlConnection.State -eq [Data.ConnectionState]::Open) {$sqlConnection.Close()}  
