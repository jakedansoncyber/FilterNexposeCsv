# Will only filter assets that have a risk score greater than $riskscore
$riskscore = 100000

# Currently set to if older than 3 months from current date, include in our results
$olderthanmonths = -3

# param: takes in filtered $csvData (older than 3 months)
# if: csvData risk score is gt $riskscore,
# then: write to csv called highrisk.csv
function ExportToCsv ($csvData) {
    $results = $csvData | where {[int]$_.Risk -gt $riskscore }
    $results | Export-Csv highrisk.csv -Append
}

# Add all csv files
# Make sure to rename header Last Scan to LastScan
$listofsites = New-Object -TypeName 'System.Collections.ArrayList';
$listofsites.Add(".\csvfiles\EXAMPLE.csv")

# Silence the ParseExact errors from try catch
$ErrorActionPreference = "SilentlyContinue"

# Set old date to be 3 months older than current date
$oldDate = (Get-Date).AddMonths($olderthanmonths)

# Loop through LastScan dates in csv file
# if: older than 3 months & risk score higher than $riskscore
# then: write to csv file called highrisk.csv
foreach($file in $listofsites)
{
    # Make data the information we will loop through
    # data is the whole spread sheet in ps object form
    $data = Import-Csv $file

    # Only take the data that has risk score greater than $riskscore
    $results = $data | where {[int]$_.Risk -gt $riskscore }
    
    foreach($row in $data)
    {
        # Precautionary take out of special characters
        $newdata = $row.LastScan -replace '[a-z+\\]',''

        # There are two formats of date time that is exported unfortunately so
        # try the first one M/dd/yy
        try {
            $compareDates = [datetime]::ParseExact($newdata, "M/dd/yy", $null)
            if($compareDates -lt $oldDate)
            {
                # Append to csv file
                ExportToCsv -csvData $row
            }
        }
        # if exception, then it's the second date format MM/dd/yy
        catch {
            $compareDates = [datetime]::ParseExact($newdata, "MM/dd/yy", $null)
            if($compareDates -lt $oldDate)
            {
                ExportToCsv -csvData $row
            }
        }    
    }
}