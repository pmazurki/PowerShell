  $SQLServer ="ip\instace"
 $SQLDBName ="DBName"
 $uid ="sa"
 $pwd ="password"
 $SQLDBName="master"
 $ConnTimeout=15

 $ConnectionString = "Server={0};Database={1};User ID={2};Password={3};Trusted_Connection=False;Connect Timeout={4}"`
    -f $SQLServer,$SQLDBName,$uid,$pwd,$ConnTimeout
    $sqlconn = New-Object System.Data.SqlClient.SQLConnection
    $sqlconn.ConnectionString = $ConnectionString
    $sqlConn.Open() 
        if ($sqlConn.State -eq 'Open'){
        $sqlConn.Close();
        CLS
        "Opened successfully."

        $SqlQuery="SELECT name FROM master.dbo.sysdatabases"
        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $SqlCmd.CommandText = $SqlQuery
        $SqlCmd.Connection = $SqlConn
        $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $SqlAdapter.SelectCommand = $SqlCmd
        $DataSet = New-Object System.Data.DataSet
        $c=$SqlAdapter.Fill($DataSet)
        $SqlConnection.Close()
        return $DataSet.Tables[0] |ft -HideTableHeaders

        } 
