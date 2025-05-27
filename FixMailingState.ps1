$noInput = @("")

$statesArr = @("OR", "DC", "WA", "CA", "AZ", "NV", "UT", "ID", "MT", "WY", "AR", "LA", "TX", "OK", "CO", "NM", "MI", "WV", "IN", "AL", "VA", "KY", "MS", "OH", "TN", "ME", "MD", "DE", "IL", "FL", "NC", "MA", "RI", "NE", "WI", "MO", "PA", "SD", "NY", "NJ", "KS", "ND", "VT", "NH", "SC", "CT", "MN", "GA", "IA", "AK", "HI")
$correctedStatesMap = @{
    'Alabama' = 'AL'
    'Alaska' = 'AK'
    'Arizona' = 'AZ'
    'Arkansas' = 'AR'
    'California' = 'CA'
    'Colorado' = 'CO'
    'Connecticut' = 'CT'
    'Delaware' = 'DE'
    'District of Columbia' = 'DC'
    'Florida' = 'FL'
    'Georgia' = 'GA'
    'Hawaii' = 'HI'
    'Idaho' = 'ID'
    'Illinois' = 'IL'
    'Indiana' = 'IN'
    'Iowa' = 'IA'
    'Kansas' = 'KS'
    'Kentucky' = 'KY'
    'Louisiana' = 'LA'
    'Maine' = 'ME'
    'Maryland' = 'MD'
    'Massachusetts' = 'MA'
    'Michigan' = 'MI'
    'Minnesota' = 'MN'
    'Mississippi' = 'MS'
    'Missouri' = 'MO'
    'Montana' = 'MT'
    'Nebraska' = 'NE'
    'Nevada' = 'NV'
    'New Hampshire' = 'NH'
    'New Jersey' = 'NJ'
    'New Mexico' = 'NM'
    'New York' = 'NY'
    'North Carolina' = 'NC'
    'North Dakota' = 'ND'
    'Ohio' = 'OH'
    'Oklahoma' = 'OK'
    'Oregon' = 'OR'
    'Pennsylvania' = 'PA'
    'Rhode Island' = 'RI'
    'South Carolina' = 'SC'
    'South Dakota' = 'SD'
    'Tennessee' = 'TN'
    'Texas' = 'TX'
    'Utah' = 'UT'
    'Vermont' = 'VT'
    'Virginia' = 'VA'
    'Washington' = 'WA'
    'West Virginia' = 'WV'
    'Wisconsin' = 'WI'
    'Wyoming' = 'WY'
    
    # Other inputs to be corrected
    'NB,' = 'NB'
    '90502' = 'CA'
    'MA.' = 'MA'
    'IL.' = 'IL'
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
    'IN.' = 'IN'
    'CA.' = 'CA'
    'ME.' = 'ME'
    'NV,' = 'NV'
    'MD.' = 'MD'
    'Juneau, AK' = 'AK'
    'ON.' = 'ON'

    'UT.' = 'UT'
    'MA,' = 'MA'
    'NC 27623' = 'NC'
    'FL.' = 'FL'
    'CT.' = 'CT'
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
    sf data update bulk --file "contactStateCorrection.csv" --sobject Contact -w 10
}


