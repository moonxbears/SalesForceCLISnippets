$statesArr = @("OR", "WA", "CA", "AZ", "NV", "UT", "ID", "MT", "WY", "AR", "LA", "TX", "OK", "CO", "NM", "MI", "WV", "IN", "AL", "VA", "KY", "MS", "OH", "TN", "ME", "MD", "DE", "IL", "FL", "NC", "MA", "RI", "NE", "WI", "MO", "PA", "SD", "NY", "NJ", "KS", "ND", "VT", "NH", "SC", "CT", "MN", "GA", "IA", "AK", "HI")

$statesArrDel = $($statesArr | % {write "'$_'"}) -join ","

$queried = "SELECT Id, MailingState, Name, Email, Phone FROM Contact WHERE MailingState not in ($($statesArrDel))"
echo $queried
sf data export bulk --query "$queried" --result-format='csv' -w 10 --output-file='outputStatesWrong.csv'
$queryData = ipcsv .\outputStatesWrong.csv

foreach($item in $queryData)
{
    echo "$($item.MailingState) = $($item.MailingState.Length)"
}