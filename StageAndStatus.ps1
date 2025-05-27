cd "C:\Users\jnjohnson\Documents\dev\salesforce\SalesforceCLISnippets"


$queryAccountStatus = "select Status__c, count(Id) from Account group by Status__c order by count(Id)"
$queryLeadStatus = "select Status, count(Id) from Lead group by Status order by count(Id)"
$queryOppStage = "select StageName, count(Id) from Opportunity group by StageName order by count(Id)"

#ni -Path "../QueryResult" -Name "AccountStatus.csv" -ItemType "file" -Force
#ni -Path "../QueryResult" -Name "LeadStatus.csv" -ItemType "file" -Force
#ni -Path "../QueryResult" -Name "OppStage.csv" -ItemType "file" -Force

sf data query --query "$queryAccountStatus" --result-format='csv' --output-file='../QueryResult/AccountStatus.csv'
sf data query --query "$queryLeadStatus" --result-format='csv' --output-file='../QueryResult/LeadStatus.csv'
sf data query --query "$queryOppStage" --result-format='csv' --output-file='../QueryResult/OppStage.csv'

#$AccountStatus = ipcsv .\../QueryResult/AccountStatus.csv
#$LeadStatus = ipcsv .\../QueryResult/LeadStatus.csv
#$OppStage = ipcsv .\../QueryResult/OppStage.csv

#$setData = [Tuple]::Create($AccountStatus, $LeadStatus, $OppStage)

#$setData | epcsv -Path "../QueryResult/StageAndStatus.csv" -Force
