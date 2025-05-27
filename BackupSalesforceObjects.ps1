param (
    [Parameter(Mandatory=$true)][string[]]$sobjects,
    [string]$path,
    [switch]$help
)

# ACCESS TOKEN
$accessToken = "<Salesforce Access Token>" 
$apiUrl = "https://asphaltzipper.my.salesforce.com"
$jobsUrl = "/services/data/v63.0/jobs/query"

if ($help)
{
    echo -sobjects "list of object names"
    echo -path "pathway to save backup csv file"
    echo -help "display help options"
}
else
{

    $SavedDateTime = Get-Date

    if ($path)
    {
        cd $path
    }
    else {
        $path = "$HOME\Downloads"
    }
    foreach ($sobject in $sobjects)
    {
        write "backing up $sobject"
        $objectQuery = sf sobject describe --sobject $sobject | ConvertFrom-Json

        #updateable (grabs all the fields that are able to be updated)
        $fields = $objectQuery.fields | ? createable -eq $true | select name
        $fieldsArr = $($fields | % {write "$($_.name)"}) -join ", "
        sf data export bulk --query "SELECT Id, $($fieldsArr) FROM $sobject" --result-format='csv' --output-file="$path\$sobject backup $(Get-Date -Format "MM-dd-yyyy HH-mm-ss").csv"
    }

    $recordsToProcess = New-Object System.Collections.ArrayList
    
    $response = curl -X GET "$($apiUrl)$($jobsUrl)" -H "Authorization: Bearer $accessToken" -H "Content-Type: application/json"
    $jsonResponse = $response | ConvertFrom-Json
    
    # find relevant records that need to be processed
    foreach ($record in $jsonResponse.records)
    {
        $date = [datetime]::Parse($record.createdDate)
        if ($date -gt $SavedDateTime)
        {
            $recordsToProcess.Add($record)
        }
    }
    
    $processedRecords = @{}
    $AllCompleted = $false
    $jobsList = New-Object System.Collections.ArrayList
    # when job is completed, extract it to file
    while ($AllCompleted -eq $false)
    {
        $AllCompleted = $true
        foreach ($rec in $recordsToProcess)
        {
            if ($processedRecords.ContainsKey($rec.id))
            {
                continue
            }
            $AllCompleted = $false
            $jobResult = curl -X GET "$($apiUrl)$($jobsUrl)/$($rec.id)" -H "Authorization: Bearer $accessToken" -H "Content-Type: application/json"
            $jobJson = $jobResult | ConvertFrom-Json
            if ($jobJson.state -eq "JobComplete")
            {
                $processedRecords.Add($rec.id, $rec)
                sf data export resume --job-id $rec.id &
            }
        }
        sleep -Seconds 5
    }
}