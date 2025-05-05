cd "C:\Users\jnjohnson\Documents\dev\salesforce\QueryResult"

$merlStates = @("AL", "CT", "DC", "DE", "FL", "GA", "IL", "IN", "KY", "MA", "MD", "ME", "MI", "MS", "NC", "NH", "NJ", "NY", "OH", "PA", "RI", "SC", "TN", "VA", "VT", "WI", "WV")
$shaneStates = @("AK", "AZ", "AR", "CA", "CO", "HI", "ID", "IA", "KS", "LA", "MN", "MO", "MT", "NE", "NV", "NM", "ND", "OK", "OR", "SD", "TX", "UT", "WA", "WY")


$merlId = "005j000000BZuNaAAL"
$shaneId = "005j000000BZuHSAA1"

$merlDel = $($merlStates | % {write "'$_'"}) -join ","
$shaneDel = $($shaneStates | % {write "'$_'"}) -join ","

$queriedMerl = "SELECT Id, OwnerId FROM Account WHERE BillingState in ($($merlDel)) AND OwnerId != '$($merlId)' AND Government__c = False"
$queriedShane = "SELECT Id, OwnerId FROM Account WHERE BillingState in ($($shaneDel)) AND OwnerId != '$($shaneId)' AND Government__c = False"

echo $queriedMerl
echo $queriedShane

sf data export bulk --query "$queriedMerl" --result-format='csv' -w 20 --output-file='merloutput.csv'
sf data export bulk --query "$queriedShane" --result-format='csv' -w 20 --output-file='shaneoutput.csv'

$queryDataMerl = ipcsv .\merloutput.csv
$queryDataShane = ipcsv .\shaneoutput.csv

$setToMerlArr = @()
$setToShaneArr = @()

foreach($item in $queryDataMerl)
{
    $setToMerlArr += [PSCustomObject]@{
        Id = $item.Id
        OwnerId = $merlId
    }
}
foreach($item in $queryDataShane)
{
    $setToShaneArr += [PSCustomObject]@{
        Id = $item.Id
        OwnerId = $shaneId
    }
}

if ($setToMerlArr.Count -gt 1) 
{
    $setToMerlArr | Export-Csv -Path "merlfile.csv"
    sf data update bulk --file "merlfile.csv" --sobject Account --async -w 10
}
if ($setToShaneArr.Count -gt 1) 
{
    $setToShaneArr | Export-Csv -Path "shanefile.csv"
    sf data update bulk --file "shanefile.csv" --sobject Account --async -w 10
}
