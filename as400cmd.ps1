<#
from https://pastebin.com/sHgRBpXX
The whole reason this works is because IBM implemented a stored proecure called
QCMDEXC which executes commands on the AS400 via SQL
 
The query has to be prepared in a certain way:
 
call qsys.qcmdexc('command',0000000007.00000)
 
The main thing is the second argument passed; which is the length of the command string.
It has to be in this (15,5) format with all the leading and trailing zeros... whatever.
 
Also since this is, after all, an AS400 command wrapped in a SQL statement any single quotes
inside the command string have to be esacped like so: 'derp' --> ''derp''
#>
function Build-Query([String] $command) {
    #Build first chunk of query, replaces any single quotes in command string with ''
    $query = "call qsys.qcmdexc('" + ($command -replace "'","''") + "',"
   
    #This bit builds the command length portion of the query
    $len1 = [String]$command.length    #Lets say $command.length = 93
    $len2 = "0"*(10-$len1.length)      #93 is 2 characters long so we need to pad 93 with (10-2) zeros to the left
    $len = $len2 + $len1 + ".00000"    #Puts it all together along with the trailing .00000
   
    $query = $query + $len + ")"
    echo $query
}
 
function AS400-Command([String] $command) {
    $query = Build-Query $command
   
    #Open connection to AS400
    $conn = New-Object System.Data.Odbc.OdbcConnection
    $conn.ConnectionString = "Driver={iSeries Access ODBC Driver};System=AS400;Uid=USER;Pwd=PASS;"
    $conn.Open()
   
    $cmd = new-object System.Data.Odbc.OdbcCommand($query,$conn)
    $cmd.ExecuteNonQuery()
   
    $conn.Close()
}
 
AS400-Command "FNDSTRPDM STRING('DERP') FILE(TSTLIB/QRPGLESRC) MBR(*ALL) OPTION(*NONE) PRTMBRLIST(*YES)"
