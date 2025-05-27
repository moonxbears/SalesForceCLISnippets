param (
    [string[]]$fields,
    [switch]$help
)

if ($help)
{
    echo -sobject "object name"
    echo -fields "fields to look for same values"
}
else
{
    $selectQuery = "select Id, Name, Email, Phone from Contact limit 10000"
    sf data export bulk --query "$selectQuery" --result-format='csv' -w 10 --output-file='outputAllContacts.csv'


    if ($null -eq $fields -or $fields.Length -eq 0)
    {
        $fields = @("Name", "Email")
    }
    $queryData = ipcsv .\outputAllContacts.csv

    $setData = @{}

    for (($i = 0); $i -lt $queryData.Length; $i++)
    {
        for (($j = $i+1); $j -lt $queryData.Length; $j++)
        {
            if ($i -eq $j)
            {
                continue
            }
            if ($setData.ContainsKey($i))
            {
                continue
            }
            $isSame = $true
            foreach($field in $fields)
            {
                if ($queryData[$i]."$field" -ne $queryData[$j]."$field")
                {
                    $isSame = $false
                    break
                }
            }
            if ($isSame -eq $true)
            {
                $setData.Add($i, [Tuple]::Create($queryData[$i], $queryData[$j]))
                break
            }
        }
    }
    $setData.Values | epcsv -Path "possible_duplicates.csv"
}