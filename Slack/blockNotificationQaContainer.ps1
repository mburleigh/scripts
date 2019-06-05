# this script should be included in a build pipeline using a PowerShell script task

param (
    $message,           # notification message (typically Build.SourceVersionMessage)
    $branch,            # Build.SourceBranch
    $username,          # the user name that shows on the Slack message
    $webhookuri,        # the Slack web hook to call
    $containerUrl,      # should be set by a prior task (typically the one that creates the instance in ACI)
    $imageName,         # the ACI image name
    $buildId,           # AzDO build id
    $cleanupUrl,        # the entry point to the cleanup function (including the function authentication code)
    $title,             # the title that will be presented on the confirmation web page
    $acrRegistry,       # the target Azure Container Registry
    $acrRepository,     # the target repository in the acrRegistry
    $acrAuth,           # authentication token for target repository in the acrRegistry
    $aciResourceGroup,  # the target resource group for the ACI instance of the image
    $project,           # the AzDO team project
    $targetBranch,      # the target branch for the merge
    $team,              # the name of the AzDO team where the work is being assigned (used to determine the current iteration)
    $callbackUrl        # endpoint called to complete the confirmation
)

$text = "Container (ACI) for branch _$branch _ deployed:\n\n*$message*"
#Write-Host $text

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
                    ""url"": ""https://$containerUrl""
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
      "project=$project&targetBranch=$targetBranch&team=$team&callbackUrl=$callbackUrl")
    #Write-Host $url

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
                        ""url"": ""https://$containerUrl""
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

#Write-Host $notification
Invoke-RestMethod -Uri $webhookuri -Method POST -Body $notification