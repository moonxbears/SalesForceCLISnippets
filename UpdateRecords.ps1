$noInput = @("", "Texas")

$statesArr = @("OR", "WA", "CA", "AZ", "NV", "UT", "ID", "MT", "WY", "AR", "LA", "TX", "OK", "CO", "NM", "MI", "WV", "IN", "AL", "VA", "KY", "MS", "OH", "TN", "ME", "MD", "DE", "IL", "FL", "NC", "MA", "RI", "NE", "WI", "MO", "PA", "SD", "NY", "NJ", "KS", "ND", "VT", "NH", "SC", "CT", "MN", "GA", "IA", "AK", "HI")
$correctedStatesMap = @{
    'North Dakota' = 'ND'
    'NB,' = 'NB'
    '90502' = 'CA'
    'Virginia' = 'VA'
    'Washington' = 'WA'
    #'Hot Springs' = 'AR' #MailingCity needs to Hot Springs, MailingState needs to be AR
    'Alaska' = 'AK'
    'NEBRASKA' = 'NE'
    'Florida' = 'FL'
    'Kentucky' = 'KY'
    'Kansas' = 'KS'
    'MA.' = 'MA'
    'IL.' = 'IL'
    'Oregon' = 'OR'
    'AL.' = 'AL'
    'PA.' = 'PA'
    
    '74450' = 'OK'
    '18103' = 'PA'
    '40209-9129' = 'KY'
    '20877' = 'MD'
    'Auburn' = 'AL'
    '06260' = 'CT'
    '07710' = 'NJ'
    'Fielding' = 'CA'
    'Eagleswood Township' = 'NJ'
    '07711-1093' = 'NJ'

    'NJ.' = 'NJ'
    'MI.' = 'MI'
    'Pennsylvania' = 'PA'
    'California' = 'CA'
    'North Carolina' = 'NC'
    'New York' = 'NY'
    'Massachusetts' = 'MA'
    'Missouri' = 'MO'
    'IN.' = 'IN'
    'CA.' = 'CA'
    'ME.' = 'ME'
    'Colorado' = 'CO'
    'NV,' = 'NV'
    'Illinois' = 'IL'
    'MD.' = 'MD'
    'Arizona' = 'AZ'
    'Juneau, AK' = 'AK'
    'Indiana' = 'IN'
    'Georgia' = 'GA'
    'ON.' = 'ON'
    'Idaho' = 'ID'
    'Louisiana' = 'LA'
    'South Carolina' = 'SC'
    'NC 27623' = 'NC'
    'Texas' = 'TX'
    'FL.' = 'FL'
    'CT.' = 'CT'
    'Maryland' = 'MD'
    'Ohio' = 'OH'
    'Connecticut' = 'CT'
    'New Mexico' = 'NM'
    'UT.' = 'UT'
    'MA,' = 'MA'
}
$statesArrDel = $($statesArr | % {write "'$_'"}) -join ","

$queried = "SELECT Id, MailingState FROM Contact WHERE MailingState not in ($($statesArrDel))"
echo $queried
sf data export bulk --query "$queried" --result-format='csv' -w 10 --output-file='outputStatesWrong.csv'
$queryData = ipcsv .\outputStatesWrong.csv

$setToArr = @()

foreach($item in $queryData)
{
    if ($correctedStatesMap.ContainsKey($item.MailingState))
    {
        $setToArr += [PSCustomObject]@{
            Id = $item.Id
            MailingState = $correctedStatesMap[$item.MailingState]
        }
    }
}

if ($setToArr.Count -gt 1) 
{
    $setToArr | Export-Csv -Path "contactStateCorrection.csv"
    sf data update bulk --file "contactStateCorrection.csv" --sobject Contact --async
}


