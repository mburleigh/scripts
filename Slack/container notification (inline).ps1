$message = '$(Build.SourceVersionMessage)'
$branch = '$(Build.SourceBranch)'
$username = 'AzDO'
$webhookuri = '$(slackWebhook)'
$containerUrl = '$(containerUrl)'
Write-Host "container url =" $containerUrl
$imageName = '$(imageName)'
$buildId = '$(Build.BuildId)'
$cleanupUrl = '$(cleanupUrl)' 
$title = 'BaltoMSDN September 2019 Demo'
$acrRegistry = '$(acrRegistry)'
$acrRepository = '$(acrRepository)'
$acrAuth = '$(acrAuth)'
$aciResourceGroup = '$(aciResourceGroup)'
$project = '$(system.teamProject)'
$targetBranch = 'master'
$team = 'BaltoMSDN Team'
$callbackUrl = '$(cleanupCallbackUrl)'
$pat = '$(pat)'
$org = 'matthewburleigh'

$text = "Container (ACI) for branch _$branch _ deployed:\n\n*$message*"
Write-Host $text

if ($branch -eq 'master')
{
    $notification = "{
        ""username"": ""$username"",
        ""text"": ""$text"",
        ""attachments"": [
            {
                ""text"": ""$message"",
                ""actions"": [
                    {
                    ""name"": ""action"",
                    ""type"": ""button"",
                    ""text"": ""Launch Container"",
                    ""url"": ""http://$containerUrl""
                    }
                ]
            }
        ]
    }"
}
else
{
    # these query string parameters match the inputs to the cleanup function
    $url = [uri]::EscapeUriString("$cleanupUrl&title=$title&container=$containerUrl&image=$imageName&buildId=$buildId&"+
      "acrRegistry=$acrRegistry&acrRepository=$acrRepository&acrAuth=$acrAuth&aciResourceGroup=$aciResourceGroup&"+
      "project=$project&targetBranch=$targetBranch&team=$team&callbackUrl=$callbackUrl&pat=$pat&org=$org")
    Write-Host $url

    $notification = "{
        ""username"": ""$username"",
        ""blocks"": [
            {
                ""type"": ""section"",
                ""text"": {
                    ""type"": ""mrkdwn"", ""text"": ""$text""
                }
            },
            {
                ""type"": ""divider""
            },
            {
                ""type"": ""actions"",
                ""elements"": [
                    {
                        ""type"": ""button"",
                        ""text"": {
                            ""type"": ""plain_text"", ""text"": ""Launch""
                        },
                        ""url"": ""http://$containerUrl""
                    }
                ]
            },
            {
                ""type"": ""section"",
                ""text"": {
                    ""type"": ""mrkdwn"",
                    ""text"": ""*Passed QA*; delete container & image and complete Pull Request""
                },
                ""accessory"": {
                    ""type"": ""button"",
                    ""text"": {
                        ""type"": ""plain_text"", ""text"": ""OK""
                    },
                    ""style"": ""primary"",
                    ""url"": ""$url&passed=true""
                }
            },
            {
                ""type"": ""section"",
                ""text"": {
                    ""type"": ""mrkdwn"",
                    ""text"": ""*Failed QA*; Create Bug""
                },
                ""accessory"": {
                    ""type"": ""button"",
                    ""text"": {
                        ""type"": ""plain_text"", ""text"": ""OK""
                    },
                    ""style"": ""danger"",
                    ""url"": ""$url&passed=false""
                }
            }
        ]
    }"
}

Write-Host $notification
Invoke-RestMethod -Uri $webhookuri -Method POST -Body $notification
