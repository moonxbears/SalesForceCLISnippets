param (
    [Parameter(Mandatory=$true)][string]$sobject,
    [string[]]$fields,
    [switch]$display,
    [switch]$help,
    [switch]$output
)

if ($help)
{
    echo -sobject "object name"
    echo -fields "fields to display according to sf sobject describe"
    echo -display "display field options"
}
elseif ($display)
{
    $objectQuery = sf sobject describe --sobject Contact | ConvertFrom-Json
    $arr = @()
    $members = $objectQuery.fields[0] | gm
    foreach ($member in $members)
    {
        if ($member.MemberType -eq "NoteProperty")
        {
            $arr += $member
        }
    }
    echo $arr.Name
}
else
{
    $objectQuery = sf sobject describe --sobject $sobject | ConvertFrom-Json

    if ($fields.Count -gt 0)
    {
        echo $fields.Count
        echo $fields
        if ($output)
        {
            $objectQuery.fields | select $($fields) | epcsv -Path "$sobject - details.csv"
        }
        else 
        {    
            $objectQuery.fields | select $($fields)
        }
    }
    else
    {
        if ($output)
        {
            $objectQuery.fields | select label, name, type | epcsv -Path "$sobject - details.csv"
        }
        else 
        {
            $objectQuery.fields | select label, name, type
        }
    }
}