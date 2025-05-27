cd "C:\Users\jnjohnson\Documents\dev\salesforce\QueryResult"

$daveStates = @("ND", "MN", "WI", "SD", "IA", "NE", "IL", "KS", "MO", "ME", "NH", "VT", "MA", "CT", "RI", "NY", "PA", "NJ", "DE", "MD", "DC", "NC", "SC", "GA", "FL")
$kenStates = @("WA", "OR", "CA", "NV", "ID", "MT", "WY", "UT", "AZ")
$michaelStates = @("MI", "IN", "OH", "WV", "KY", "VA", "TN", "MS", "AL")
$scottStates = @("NM", "CO", "OK", "TX", "AR", "LA")
$derekStates = @("AK", "HI")

$daveId = "005j000000BXaJDAA1"
$derekId = "005j000000C2WWEAA3"
$kenId = "005f100000Hazh3AAB"
$michaelId = "005f100000H665ZAAR"
$scottId = "005f100000H5hX4AAJ"

$daveDel = $($daveStates | % {write "'$_'"}) -join ","
$kenDel = $($kenStates | % {write "'$_'"}) -join ","
$michaelDel = $($michaelStates | % {write "'$_'"}) -join ","
$scottDel = $($scottStates | % {write "'$_'"}) -join ","
$derekDel = $($derekStates | % {write "'$_'"}) -join ","

$queriedDave = "SELECT Id, OwnerId FROM Contact WHERE MailingState in ($($daveDel)) AND OwnerId != '$($daveId)' AND GovernmentLU__c = true"
$queriedKen = "SELECT Id, OwnerId FROM Contact WHERE MailingState in ($($kenDel)) AND OwnerId != '$($kenId)' AND GovernmentLU__c = true"
$queriedMichael = "SELECT Id, OwnerId FROM Contact WHERE MailingState in ($($michaelDel)) AND OwnerId != '$($michaelId)' AND GovernmentLU__c = true"
$queriedScott = "SELECT Id, OwnerId FROM Contact WHERE MailingState in ($($scottDel)) AND OwnerId != '$($scottId)' AND GovernmentLU__c = true"
$queriedDerek = "SELECT Id, OwnerId FROM Contact WHERE MailingState in ($($derekDel)) AND OwnerId != '$($derekId)' AND GovernmentLU__c = true"

sf data export bulk --query "$queriedDave" --result-format='csv' -w 20 --output-file='daveoutput.csv'
sf data export bulk --query "$queriedKen" --result-format='csv' -w 20 --output-file='kenoutput.csv'
sf data export bulk --query "$queriedMichael" --result-format='csv' -w 20 --output-file='michaeloutput.csv'
sf data export bulk --query "$queriedScott" --result-format='csv' -w 20 --output-file='scottoutput.csv'
sf data export bulk --query "$queriedDerek" --result-format='csv' -w 20 --output-file='derekoutput.csv'

$queryDataDave = ipcsv .\daveoutput.csv
$queryDataKen = ipcsv .\kenoutput.csv
$queryDataMichael = ipcsv .\michaeloutput.csv
$queryDataScott = ipcsv .\scottoutput.csv
$queryDataDerek = ipcsv .\derekoutput.csv

$setToDaveArr = @()
$setToKenArr = @()
$setToMichaelArr = @()
$setToScottArr = @()
$setToDerekArr = @()

foreach($item in $queryDataDave)
{
    $setToDaveArr += [PSCustomObject]@{
        Id = $item.Id
        OwnerId = $daveId
    }
}
foreach($item in $queryDataKen)
{
    $setToKenArr += [PSCustomObject]@{
        Id = $item.Id
        OwnerId = $kenId
    }
}
foreach($item in $queryDataMichael)
{
    $setToMichaelArr += [PSCustomObject]@{
        Id = $item.Id
        OwnerId = $michaelId
    }
}
foreach($item in $queryDataScott)
{
    $setToScottArr += [PSCustomObject]@{
        Id = $item.Id
        OwnerId = $scottId
    }
}
foreach($item in $queryDataDerek)
{
    $setToDerekArr += [PSCustomObject]@{
        Id = $item.Id
        OwnerId = $derekId
    }
}

if ($setToDaveArr.Count -gt 1) 
{
    $setToDaveArr | Export-Csv -Path "davefile.csv"
    sf data update bulk --file "davefile.csv" --sobject Contact -w 30
}
if ($setToKenArr.Count -gt 1) 
{
    $setToKenArr | Export-Csv -Path "kenfile.csv"
    sf data update bulk --file "kenfile.csv" --sobject Contact -w 30
}
if ($setToMichaelArr.Count -gt 1) 
{
    $setToMichaelArr | Export-Csv -Path "michaelfile.csv"
    sf data update bulk --file "michaelfile.csv" --sobject Contact -w 30
}
if ($setToScottArr.Count -gt 1) 
{
    $setToScottArr | Export-Csv -Path "scottfile.csv"
    sf data update bulk --file "scottfile.csv" --sobject Contact -w 30
}
if ($setToDerekArr.Count -gt 1) 
{
    $setToDerekArr | Export-Csv -Path "derekfile.csv"
    sf data update bulk --file "derekfile.csv" --sobject Contact -w 30
}